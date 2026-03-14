---
name: user-interview
description: |
  End-to-end user interview workflow for ImmCore B2C discovery. Covers: (1) interview prep —
  create Notion page from template with profile, tailored questions, and hypotheses based on
  LinkedIn + CRM + Value Factory dashboard data, (2) post-interview — extract transcript via
  Granola MCP, analyze insights, update Notion page with findings, draft Slack summary for
  #team-marketing. Use when: user explicitly says "prepare for interview", "process interview
  transcript", "interview prep", "fill the interview page", or references a Discovery interview
  page by name/number. Do NOT trigger just because a Granola link is shared — Granola links
  are used for many purposes.
author: Claude Code
version: 1.0.0
date: 2026-03-14
---

# User Interview Workflow

## Problem
Running user discovery interviews requires consistent prep, structured note-taking, and
post-interview analysis. Without a repeatable process, insights get lost and quality varies.

## Context / Trigger Conditions
- User says "prepare for interview" or "interview prep" + provides a LinkedIn URL
- User shares a Granola transcript link after an interview
- User asks to "process the interview" or "extract insights"
- Any mention of creating interview pages in the Discovery section of Notion

## Workflow

### Phase 1: Interview Prep

**Inputs needed:** Interviewee name, LinkedIn URL. Optional: CRM record, Value Factory dashboard.

**Steps:**
1. **Fetch LinkedIn profile** via WebFetch — extract: name, role, company, education, origin, experience
2. **Check CRM** — fetch Notion B2C Leads Pipeline record if URL provided (stage, visa status, consult history, logs)
3. **Check Value Factory dashboard** — fetch `dashboard.immcore.ai/{slug}` if exists (scores, gaps, strengths)
4. **Create Notion page** under Discovery parent page (`320026e8f99680148085f08a4b2d3f39`) with:
   - Profile table (name, LinkedIn, email, role, origin, education, visa path, stage, segment, interview date, sourcing context)
   - Pre-Interview Notes (what we know, why valuable, what to probe)
   - Interview Notes section with **tailored questions** based on their specific situation
   - Solution Reactions section (Value Factory dashboard + Evidence Tracker concepts)
   - Key Takeaways section (top pain, surprise finding, best quote, hypothesis check table, new insights)
   - Follow-Up checklist
5. **Classify segment** per Prep Framework: Completed | In Process | Early Exploration | Failed/Withdrew
6. **Select 3 hypotheses** to test from the master list, tailored to this person's situation

**Key principle:** Tailor questions to the person. A drop-off lead gets "why did you go silent?"
questions. An immigration-fatigued person gets "what broke you?" questions. Don't use the
generic template verbatim.

### Phase 2: Interview Opening Script

Standard intro (adapt name):
> "Hey [Name], thanks for making the time. My name is Vadim, I'm Head of Marketing at ImmCore.
> We're building a company around talent-based immigration — O-1, EB-1, NIW visas. Two tracks:
> partnering with experienced attorneys like Kevin Andrews, and building a self-service platform
> to make the visa process clear, simple, and about 2x cheaper. This call isn't to sell you
> anything. I genuinely want to hear about your experience. Everything stays between us."

### Phase 3: Post-Interview Processing

**Inputs needed:** Granola meeting link or meeting ID.

**Steps:**
1. **Extract transcript** via `mcp__claude_ai_Granola__get_meeting_transcript` using meeting UUID
   - The UUID is in the Granola URL: `notes.granola.ai/t/{UUID}-{suffix}` — use just the UUID part
   - WebFetch does NOT work on Granola links (returns React RSC payload, not transcript)
2. **Analyze transcript** — extract:
   - Immigration timeline (table format, like Julian Blair example)
   - Career timeline
   - Key pain points with direct quotes
   - Information sources they used
   - Reactions to solutions/concepts shown
   - Emotional moments
   - Advice they gave (unprompted insights are often the most valuable)
3. **Update Notion page** with findings using `update_content` (search-and-replace on placeholder sections)
4. **Update profile table** — correct visa path, stage, segment, interview date based on actual interview data
5. **Fill hypothesis check** — Confirmed / Contradicted / Neutral with evidence
6. **Draft Slack message** for #team-marketing (`C089JFMPZ9B`) with:
   - One-line profile summary
   - Top finding (1-2 sentences)
   - Best quote (blockquote)
   - Key blockers (bullet list)
   - Hypotheses confirmed (bullet list)
   - Action items
   - Link to full Notion notes

**Slack message rules:**
- Don't include negative comments about Kevin's consult quality (sensitive — he's a partner)
- Keep it factual, not interpretive
- Vadim will review and may ask to edit before posting — be ready to revise and repost
- Use Slack markdown: `*bold*`, `_italic_`, `>` for quotes, `•` for bullets

### Phase 4: Cross-Interview Pattern Analysis

After 3+ interviews, look for patterns:
- Which hypotheses are consistently confirmed/contradicted?
- What segments are represented vs. missing?
- What new insights emerged that weren't in the original hypothesis list?

## Key References

- **Interview Template**: `https://www.notion.so/320026e8f9968197bdc8db1f47147077`
- **Prep Framework**: `https://www.notion.so/320026e8f99680729f63dfefd065d47c`
- **Julian Blair (#1)**: `https://www.notion.so/320026e8f996813889edefc963a52a3c` (reference example)
- **Discovery parent page**: `320026e8f99680148085f08a4b2d3f39`
- **#team-marketing Slack**: `C089JFMPZ9B`
- **Interview Guide**: `AI OS/Immcore Projects/immcore-b2c-discovery/docs/interview-guide.md`
- **Interview Tracker**: `AI OS/Immcore Projects/immcore-b2c-discovery/docs/interview-tracker.md`
- **Hypotheses**: `AI OS/Immcore Projects/immcore-b2c-discovery/context/hypotheses.md`

## Master Hypothesis List

| ID | Hypothesis | What it validates |
|----|-----------|-------------------|
| H1 | Self-assessment gap ("do I qualify?") | Value Factory |
| H2 | Would pay for evidence roadmap pre-attorney | Pre-consult tooling |
| H3 | Transparency gap is biggest pain | Post-consult experience |
| H4 | Evidence collection is most time-consuming | Evidence tracker tool |
| H5 | Attorney selection is referral-driven | Marketing channel strategy |
| H6 | People underestimate their own workload | Attorney + tools model |
| H7 | Emotional burden is underserved | Community / support features |

## Interview Numbering

Interviews are numbered sequentially: #1 Julian Blair, #2 Kashish Kumar, #3 Naveen R.
Continue the sequence for future interviews.

## Verification
- Notion page created under Discovery with all sections populated
- Slack message posted to #team-marketing and confirmed by Vadim
- Interview tracker updated

## Notes
- Granola transcript quality varies — speaker labels are "Me" and "Them", names get mangled
- Always confirm visa path details from the transcript (pre-interview assumptions are often wrong)
- Value Factory dashboard company tier can be wrong — verify against actual company size
- $50 Amazon gift card is standard interview incentive
- Preferred scheduling: varies per person, ask in outreach
- UPL rules apply: never say "assessment", "qualify", "eligible" in any materials
