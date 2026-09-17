#!/usr/bin/env python3
"""Print file:line for every line containing Cyrillic in the given files; exit 1 if any. Portable
replacement for `grep -P '[\\x{0400}-\\x{04FF}]'`, which BSD grep on macOS does not support."""
import re, sys
cyr = re.compile("[\\U00000400-\\U000004FF]")
hits = 0
for path in sys.argv[1:]:
    try:
        with open(path, encoding="utf-8", errors="ignore") as f:
            for n, line in enumerate(f, 1):
                if cyr.search(line):
                    print(f"{path}:{n}: {line.rstrip()[:100]}"); hits += 1
    except (OSError, IsADirectoryError):
        continue
sys.exit(1 if hits else 0)
