#!/usr/bin/env python3
"""secretscan.classify: known formats, key = value shapes and high-entropy tokens are caught; commit
hashes, URLs, identifiers, placeholders and short ids are not."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "hooks"))
from secretscan import classify

TOKEN48 = "aZ3kQ9mT2xL8vB1nR7cY4wE6uP0sD5fG2hJ9kM3pN6qS7tV1"
positives = [
    "PIPEDRIVE_API_TOKEN=0123456789abcdef0123456789abcdef01234567",
    '"NOTION_TOKEN": "ntn_' + "A1b2C3d4E5" * 5 + '"',
    "Authorization: Bearer " + TOKEN48,
    "https://mcp.exa.ai/mcp?exaApiKey=0f2b6c1e-1a2b-4c3d-8e9f-0a1b2c3d4e5f",
    'token = "' + TOKEN48 + '"',
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.abc",
    "aws key AKIAABCDEFGHIJKLMNOP in the export",
    "unknown provider: " + TOKEN48,
]
negatives = [
    "commit 3f2a1b4c5d6e7f8091a2b3c4d5e6f7a8b9c0d1e2 fixed the bug",
    "see https://github.com/Vadim2090/ai-agent-os/blob/main/template/CLAUDE.md for the rule",
    "The token budget is 200 lines; secret sauce is not a credential",
    'integrity="sha512-' + TOKEN48 + TOKEN48 + '"',
    "password: <your-password>",
    "access_token=${ACCESS_TOKEN}",
    "ThisIsAVeryLongCamelCaseIdentifierName123456 = compute()",
    "Sheet 1bOjKYBaQwErTyUiOpAsDfGhJkLzXcVbNm123 holds the funnel",
    "risk-adjusted, task-based, desk-side",
]
bad = 0
for line in positives:
    if not classify(line):
        print("MISSED:", line[:70]); bad += 1
for line in negatives:
    kind = classify(line)
    if kind:
        print("FALSE POSITIVE:", kind, "|", line[:70]); bad += 1
sys.exit(1 if bad else 0)
