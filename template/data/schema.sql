-- Operational data the agent queries. Narrative stays in markdown; anything you would put in a
-- spreadsheet goes here. Sync from your systems of record with sync_csv.py or your own job.
-- Apply: sqlite3 ai-os.db < schema.sql

CREATE TABLE IF NOT EXISTS campaigns (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  channel     TEXT NOT NULL,          -- e.g. outbound, paid, referral, events
  started_on  DATE,
  ended_on    DATE,
  budget_usd  REAL
);

CREATE TABLE IF NOT EXISTS funnel_daily (
  day          DATE NOT NULL,
  campaign_id  TEXT NOT NULL REFERENCES campaigns(id),
  sent         INTEGER DEFAULT 0,
  replies      INTEGER DEFAULT 0,
  meetings     INTEGER DEFAULT 0,
  qualified    INTEGER DEFAULT 0,
  spend_usd    REAL    DEFAULT 0,
  PRIMARY KEY (day, campaign_id)
);

CREATE TABLE IF NOT EXISTS experiments (
  id          TEXT PRIMARY KEY,
  hypothesis  TEXT NOT NULL,
  arm         TEXT,                   -- A, B, control ...
  started_on  DATE,
  ended_on    DATE,
  metric      TEXT,                   -- what decides it, with its denominator
  result      TEXT,
  decision    TEXT                    -- ship, kill, extend
);

-- The question the agent gets asked most: what did a channel cost per qualified lead, by month.
CREATE VIEW IF NOT EXISTS funnel_monthly AS
SELECT substr(day, 1, 7)            AS month,
       campaign_id,
       SUM(sent)                     AS sent,
       SUM(replies)                  AS replies,
       SUM(meetings)                 AS meetings,
       SUM(qualified)                AS qualified,
       ROUND(SUM(spend_usd), 2)      AS spend_usd,
       CASE WHEN SUM(qualified) > 0
            THEN ROUND(SUM(spend_usd) / SUM(qualified), 2) END AS cost_per_qualified
FROM funnel_daily
GROUP BY 1, 2;
