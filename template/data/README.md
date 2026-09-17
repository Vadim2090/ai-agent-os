# `data/` — the structured half of the memory model

Markdown holds narrative: decisions, plans, session logs. Anything you would put in a spreadsheet goes
into SQLite here, so the agent can answer "which campaigns had a cost per qualified lead under $100 in
Q3?" with a query instead of reading twelve files.

- `schema.sql`: campaigns, daily funnel counts, experiments, and a monthly view with cost per qualified lead.
- `sync_csv.py`: upserts a CSV export into a table; safe to re-run. Schedule it after each export:

```
# crontab: every morning at 06:30, sync yesterday's funnel export
30 6 * * * cd "$HOME/AI OS/data" && python3 sync_csv.py ai-os.db funnel_daily ~/Downloads/funnel.csv >> sync.log 2>&1
```

- The agent queries with `sqlite3 ai-os.db "SELECT ... FROM funnel_monthly"`; the database file is
  gitignored data, the schema is code.

Rule of thumb: if you would write it as a paragraph, it stays in markdown; if you would put it in a
spreadsheet, it belongs here.
