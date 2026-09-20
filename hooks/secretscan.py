#!/usr/bin/env python3
"""Credential detector shared by done-gate.sh (Stop) and publish-guard.sh (PreToolUse).

Two layers, so a provider this file has never heard of is still caught:
  1. known formats by brand: fast and precise (OpenAI, Notion, AWS, GitHub, Slack, Google, JWT,
     private keys, Make webhook ids);
  2. shape: a key-ish name followed by a value (`api_key=`, `"TOKEN": "..."`, `Authorization: Bearer`),
     and long high-entropy tokens that mix cases and digits without the long same-class runs an
     identifier has.

CLI: secretscan.py FILE...  prints path:line:kind for every hit and exits 1 if there were any.
Library: classify(line) -> kind or None.
"""
import math
import re
import sys

BRAND = re.compile(
    r"(\bsk-[A-Za-z0-9_-]{20,}"                          # OpenAI, word-anchored: never "risk-" or "task-"
    r"|\bntn_[A-Za-z0-9]{40,}"                           # Notion integration
    r"|AKIA[0-9A-Z]{16}"                                 # AWS access key id
    r"|\bghp_[A-Za-z0-9]{36}|\bgithub_pat_[A-Za-z0-9_]{22,}"
    r"|\bxox[abprs]-[A-Za-z0-9-]{10,}"                   # Slack
    r"|\bAIza[0-9A-Za-z_-]{35}"                          # Google API key
    r"|-----BEGIN [A-Z ]*PRIVATE KEY-----"
    r"|\beyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}"      # JWT
    r"|make\.com/mcp/server/[0-9a-f]{8}-[0-9a-f]{4})"    # Make webhook id
)
KEYED = re.compile(
    r"(?i)(?:api[_-]?key|apikey|access[_-]?token|auth[_-]?token|token|secret|passw(?:or)?d|authorization"
    r"|bearer|credential)[A-Za-z0-9_]{0,24}[\"']?\s*[:=]\s*[\"']?(?:Bearer\s+)?([A-Za-z0-9_\-./+=]{16,})"
)
CANDIDATE = re.compile(r"[A-Za-z0-9_-]{40,}")
URL = re.compile(r"https?://\S+")
SAFE_LINE = re.compile(r"(?i)sha(?:256|512)-|integrity=|data:image|base64,|\bcommit\b|\bsha1?\b|\bhash\b|\bchecksum\b")
PLACEHOLDER = re.compile(r"(?i)xxx|your[_-]|example|placeholder|<[^>]+>|\$\{|\{\{|\.\.\.|changeme|redacted")


def entropy(s):
    counts = {}
    for ch in s:
        counts[ch] = counts.get(ch, 0) + 1
    n = len(s)
    return -sum(c / n * math.log2(c / n) for c in counts.values())


def longest_class_run(s):
    """Longest run of characters from one class (lower / upper / digit / other)."""
    def cls(ch):
        return "l" if ch.islower() else "u" if ch.isupper() else "d" if ch.isdigit() else "o"
    best = run = 0
    prev = None
    for ch in s:
        c = cls(ch)
        run = run + 1 if c == prev else 1
        prev = c
        best = max(best, run)
    return best


def classify(line):
    """Return a kind for the first credential found in the line, or None."""
    if BRAND.search(line):
        return "credential (known format)"
    m = KEYED.search(line)
    if m:
        value = m.group(1)
        if not PLACEHOLDER.search(value) and entropy(value) >= 3.0:
            return "credential (key = value)"
    if SAFE_LINE.search(line):
        return None
    for cand in CANDIDATE.findall(URL.sub(" ", line)):
        if not (re.search(r"[a-z]", cand) and re.search(r"[A-Z]", cand) and re.search(r"[0-9]", cand)):
            continue  # hex, uuids and bare words are handled by the keyed rule, not by entropy
        if entropy(cand) >= 3.5 and longest_class_run(cand) <= 6:
            return "credential (high-entropy token)"
    return None


def is_test_fixture(path):
    """Test fixtures plant fake credentials on purpose; both gates skip them and say so."""
    import os
    base = os.path.basename(path).lower()
    return (base.startswith(("test-", "test_")) or base.rsplit(".", 1)[0].endswith(("_test", "-test"))
            or any(seg in ("tests", "test", "fixtures", "evals", ".tmp") for seg in path.split(os.sep)))


def scan_file(path, max_bytes=2_000_000):
    """Yield (line_no, kind) for a text file; binaries and oversized files yield nothing."""
    try:
        with open(path, "rb") as f:
            head = f.read(8192)
        if b"\x00" in head:
            return
        import os
        if os.path.getsize(path) > max_bytes:
            return
        with open(path, encoding="utf-8", errors="ignore") as f:
            for n, line in enumerate(f, 1):
                kind = classify(line)
                if kind:
                    yield n, kind
    except OSError:
        return


if __name__ == "__main__":
    hits = 0
    for path in sys.argv[1:]:
        for n, kind in scan_file(path):
            print(f"{path}:{n}: {kind}")
            hits += 1
    sys.exit(1 if hits else 0)
