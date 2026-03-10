#!/usr/bin/env python3
"""
Capture Learning Hook — runs on UserPromptSubmit.
Detects correction patterns in user messages and queues them
for later processing via /reflect.

Reads user message from stdin, writes to ~/.claude/learnings-queue.json.
"""

import json
import os
import re
import sys
from datetime import datetime, timezone

QUEUE_FILE = os.path.expanduser("~/.claude/learnings-queue.json")

# High-confidence correction patterns
HIGH_PATTERNS = [
    r"\bno,?\s+(use|always|never|don't|do not)\b",
    r"\bactually[,.]",
    r"\binstead of\b",
    r"\buse\s+\w+\s+not\s+\w+",
    r"\bremember:",
    r"\bdon't\s+(ever|use|do)\b",
    r"\balways\s+(use|do|prefer)\b",
    r"\bnever\s+(use|do)\b",
    r"\bi\s+meant\b",
]

# Medium-confidence patterns
MEDIUM_PATTERNS = [
    r"\bthat's\s+(wrong|incorrect|not right)\b",
    r"\bprefer\s+\w+\s+over\b",
    r"\bstop\s+(using|doing)\b",
    r"\bwe\s+(use|prefer|need)\b",
]


def detect_correction(message: str) -> tuple[str, str] | None:
    """Returns (confidence, matched_pattern) or None."""
    msg_lower = message.lower()

    for pattern in HIGH_PATTERNS:
        if re.search(pattern, msg_lower):
            return ("high", pattern)

    for pattern in MEDIUM_PATTERNS:
        if re.search(pattern, msg_lower):
            return ("medium", pattern)

    return None


def load_queue() -> list:
    if os.path.exists(QUEUE_FILE):
        try:
            with open(QUEUE_FILE, "r") as f:
                return json.load(f)
        except (json.JSONDecodeError, IOError):
            return []
    return []


def save_queue(queue: list):
    os.makedirs(os.path.dirname(QUEUE_FILE), exist_ok=True)
    with open(QUEUE_FILE, "w") as f:
        json.dump(queue, f, indent=2)


def main():
    try:
        message = sys.stdin.read().strip()
    except Exception:
        sys.exit(0)

    if not message:
        sys.exit(0)

    result = detect_correction(message)
    if result is None:
        sys.exit(0)

    confidence, pattern = result

    # Determine scope heuristic
    cwd = os.getcwd()
    suggested_scope = "project" if "/projects/" in cwd.lower() else "global"

    entry = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "raw_message": message[:500],  # Truncate long messages
        "confidence": confidence,
        "matched_pattern": pattern,
        "suggested_scope": suggested_scope,
        "working_dir": cwd,
    }

    queue = load_queue()
    queue.append(entry)
    save_queue(queue)

    # Silent — no output to user
    sys.exit(0)


if __name__ == "__main__":
    main()
