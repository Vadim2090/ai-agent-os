# Reddit Comment Drafter

Draft a Reddit comment from Kevin Andrews' perspective and post it to #feedback-reddit-comments for his approval.

## Trigger
User shares a Reddit post URL, or says /reddit-comment <URL>

## Input
A Reddit post URL (e.g., https://www.reddit.com/r/EB2_NIW/comments/...)

## Instructions

### Step 1: Fetch the Reddit post

Use curl to fetch the post as JSON and parse it:

```bash
curl -s -L -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" "[URL].json" | python3 -c "
import json, sys
data = json.load(sys.stdin)

post = data[0]['data']['children'][0]['data']
print('=== POST ===')
print(f\"Title: {post['title']}\")
print(f\"Author: {post['author']}\")
print(f\"Score: {post['score']}\")
print(f\"Subreddit: r/{post['subreddit']}\")
print()
print(post['selftext'])
print()

print('=== COMMENTS ===')
comments = data[1]['data']['children']
for c in comments:
    if c['kind'] == 't1':
        d = c['data']
        print(f\"--- {d['author']} (score: {d['score']}) ---\")
        print(d['body'])
        print()
        if d.get('replies') and isinstance(d['replies'], dict):
            for r in d['replies']['data']['children']:
                if r['kind'] == 't1':
                    rd = r['data']
                    print(f'  > {rd[\"author\"]} (score: {rd[\"score\"]})')
                    print(f'  > {rd[\"body\"]}')
                    print()
"
```

### Step 2: Analyze the post

Read the post carefully. Identify:
- What visa type (EB-1A, O-1A, NIW, H-1B)?
- What's the person's situation (RFE, denial, self-filed, attorney-filed, considering filing)?
- What specific questions are they asking?
- What have other commenters already said? Don't repeat their points.

### Step 3: Draft the comment

Write a comment in Kevin's voice following these rules:

**Length:**
- ~80% of comments should be long: 70-100 words
- ~20% should be short: 30-50 words
- NEVER exceed 100 words
- Vary length — don't make every comment the same size

**Voice & Openers:**
- Signal attorney expertise implicitly (e.g., "I've handled hundreds of NIW cases", "In my experience with EB-1A RFEs...")
- NEVER open with "Immigration attorney here" or "A few things stand out"
- Vary openers across comments — each must feel organic
- Be direct, helpful, slightly informal — match Reddit tone
- Use specific legal frameworks when relevant (Dhanasar prongs for NIW, EB-1A criteria, etc.)

**Content:**
- Address the OP's specific situation — reference their details
- Provide genuinely useful insight, not generic advice
- End with reassurance or an engagement hook when natural (not forced)
- If other commenters gave wrong info, gently correct it

**Compliance (HARD RULES):**
- No links, no CTA, no "DM me", no "book a call"
- No ImmCore branding
- No "specialist", "expert", "best", "top", "guaranteed" (Maryland Rule 19-307.4)
- No specific legal advice — keep it general information
- No predictions about case outcomes
- Pure value — the comment IS the product
- Profile click-through is the only conversion path

### Step 4: Get user approval

Show the draft to Vadim. Wait for confirmation before posting.

### Step 5: Post to Slack

Post to **#feedback-reddit-comments** (channel ID: `C0AM22GLNGM`) using this exact Slack format:

```
*Reddit post:* <[full Reddit URL]>
*Comment:*
[comment text as plain paragraph — NO markdown formatting, no bold, no italic, no bullets, no blockquotes]
```

Slack formatting reminders:
- `*text*` = bold in Slack (not `**text**`)
- `<URL>` = clickable link in Slack (not `[text](URL)`)
- Comment body must be plain text only

## Kevin's Background (for drafting context)

- Immigration attorney, 15+ years experience
- Focus: EB-1A, O-1A, NIW cases
- 1,000+ cases handled, 90%+ approval rate
- Licensed in Maryland
- Key positioning: "RFE rescue specialist" — nobody else owns this lane on Reddit
- Common references: Dhanasar framework (NIW), Mukherji v. Miller (EB-1A litigation), USCIS policy manual
- His view: most RFEs are presentation problems, not qualification problems
- His view: premium processing correlates with fewer RFEs
- His view: self-filed cases get hit hardest in current environment
- His view: recommendation letters carry enormous weight, especially independent ones
- His view: refiling with restructured strategy is usually better than motions to reopen/reconsider

## Target Subreddits
- r/USCIS (primary — highest volume)
- r/EB2_NIW (NIW-specific)
- r/O1VisasEB1Greencards (O-1/EB-1 specific)
- r/eb_1a (caution — moderator is a competitor)
- r/h1b (pipeline to talent visas)
