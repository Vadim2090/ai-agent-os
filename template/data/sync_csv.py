#!/usr/bin/env python3
"""Upsert a CSV export into a table of the AI OS SQLite database. Standard library only.

    python3 sync_csv.py ai-os.db funnel_daily export.csv

The CSV header names the columns; columns the table does not have are ignored, missing ones stay NULL
or default. Rows are matched on the table's primary key (INSERT OR REPLACE), so re-running a sync is
safe. The schema is applied first if the table does not exist yet (schema.sql next to this file).
Run it from cron or a scheduled task after each export; the agent then queries facts instead of
reading spreadsheets.
"""
import csv, os, sqlite3, sys

if len(sys.argv) != 4:
    sys.exit(__doc__)
db_path, table, csv_path = sys.argv[1:]
con = sqlite3.connect(db_path)
with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "schema.sql"), encoding="utf-8") as f:
    con.executescript(f.read())
cols = {row[1] for row in con.execute(f"PRAGMA table_info({table})")}
if not cols:
    sys.exit(f"unknown table {table!r}; tables: " + ", ".join(r[0] for r in con.execute("SELECT name FROM sqlite_master WHERE type='table'")))
with open(csv_path, newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    use = [c for c in reader.fieldnames if c in cols]
    if not use:
        sys.exit(f"no CSV column matches {table}: {reader.fieldnames}")
    rows = [[r[c] if r[c] != "" else None for c in use] for r in reader]
sql = f"INSERT OR REPLACE INTO {table} ({', '.join(use)}) VALUES ({', '.join('?' * len(use))})"
con.executemany(sql, rows)
con.commit()
print(f"{len(rows)} rows into {table} ({', '.join(use)})")
