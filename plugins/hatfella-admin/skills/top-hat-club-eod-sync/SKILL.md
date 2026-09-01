---
name: top-hat-club-eod-sync
description: "End-of-day Top Hat Club sync — pull every active club subscriber from Stripe, make sure each has \"The Top Hat Club\" pricing plan (10% discount) on their Aryeo profile, apply where missing, verify, and report. Use for \"run the end of day Top Hat sync\", \"EOD club sync\", or \"make sure today's Top Hat signups got their 10% in Aryeo\"."
---

# Top Hat Club End-of-Day Sync

A fixed, five-step pipeline run at the end of the day: find everyone paying
for the Top Hat Club in Stripe, confirm each has the club pricing plan (the
10% discount) on their Aryeo profile, apply it where it's missing, verify,
and report. The steps and their done-rules are pre-baked and do not change
between runs — only the toggle below changes how the run behaves.

## ⚙️ Loop Training Mode — TOGGLE

```
LOOP TRAINING MODE: OFF
```

Flip the word `ON`/`OFF` above to change how this skill runs. Read it fresh
every time this skill is invoked — do not assume last run's setting.

- **ON** (default): pause after every step and wait for the user's explicit
  go-ahead before starting the next one. Before running a step, check its
  done-rule first — if it already passes, skip the step (say so) and move
  on without pausing on it. Only steps that actually ran and failed get
  retried. Retries are capped (see below); never loop a step forever.
- **OFF**: run all five steps back-to-back with no pauses for approval.
  Still check each step's done-rule before running it (skip if already
  passing) and still enforce the retry cap. Report the end state once, at
  the finish.

**Retry cap: 3 attempts per step**, ON or OFF. If a step still fails its
done-rule after 3 attempts, stop the run and tell the user exactly which
step failed and why — do not silently mark it done, and do not keep
retrying past the cap. Step 5 (the report) still runs after any stop, so a
failed run is always reported, never silent.

## Browser

Use **Claude in Chrome** (the user's real, already-logged-in Chrome), not
the sandboxed in-app Browser pane — Chrome is logged into both Stripe and
Aryeo, and there is no working API path today. The browser is the way.

## Goal

Every client who pays for the Top Hat Club through Stripe ends the day with
the "The Top Hat Club" pricing plan — the 10% club discount — applied on
their Aryeo customer profile, so no paying member keeps getting charged
standard prices.

## Skill-level done-rule (the Verification)

Every active Top Hat Club subscriber in Stripe either (a) shows "The Top
Hat Club" under User Pricing Plan Override on their Aryeo Billing tab —
verified by reading it, not assumed from a submitted form — or (b) is
explicitly listed in the report as unmatched/ambiguous for the user to
resolve. No subscriber is left in an unknown state.

## Steps

Each step: what to do, and the done-rule that lets it be skipped on a rerun.

**1. Pull the member list from Stripe**
Action: open
`https://dashboard.stripe.com/acct_1NgSZFFgt54xnYUv/subscriptions?status=active`
and collect customer name + email for every **active** Top Hat Club
subscription (any variant — Annual, Founder, etc.). Ignore canceled/paused.
Done-rule: a list of active club subscribers (name + email each) is
recorded for this run.

**2. Check each member's current state in Aryeo**
Action: for each member, open
`https://hat-fella-productions-2.aryeo.com/admin/customer-users`, search by
name (fall back to email or partial name — spellings occasionally differ),
open the profile → Billing tab, and read the User Pricing Plan Override.
Record one state per member: **already has "The Top Hat Club"**, **needs
the plan**, or **no/ambiguous Aryeo match** (match ambiguity is resolved by
email, never by name alone — never guess).
Done-rule: every Step 1 member has exactly one recorded state.

**3. Apply the plan to members who need it**
Action: for each "needs the plan" member only: Billing tab → "User Pricing
Plan Override" → select **"The Top Hat Club"** (exact name — not "Top
Producer 2026", "PRB", or anything similar) → click "Update Customer
Pricing Plan" → confirm the green toast "Pricing plan assigned to customer
successfully." This is the per-customer override path — do not use team or
account settings; the owner confirmed those don't work on this account.
This changes live billing: never apply the plan to anyone not confirmed
active in Stripe in Step 1.
Done-rule: every "needs the plan" member has a confirmed success toast (or
is moved to the unmatched/failed list with the reason).

**4. Verify — the 10% is actually on**
Action: for each member Step 3 changed, reload their Billing tab and read
the override fresh. It must display "The Top Hat Club". A submitted form
without this re-read does not count as verified.
Done-rule: every changed member re-read and showing "The Top Hat Club".

**5. Report**
Action: tell the user, briefly: members newly applied (name → plan
verified), members already set (skipped), members with no Aryeo customer at
all (user must create them first), and any unmatched/ambiguous/failed
members with the reason. If every subscriber already had the plan, say so
explicitly — never leave it ambiguous whether the check ran. This step
always runs, even after a retry-cap stop, reporting how far the run got.
Done-rule: the report is delivered and accounts for every Step 1 member.

## Quick reference

| Item | Value |
|---|---|
| Stripe subscriptions | https://dashboard.stripe.com/acct_1NgSZFFgt54xnYUv/subscriptions?status=active |
| Aryeo customers | https://hat-fella-productions-2.aryeo.com/admin/customer-users |
| Plan to apply | "The Top Hat Club" (exact name) via Billing → User Pricing Plan Override |
| Success signal | green toast: "Pricing plan assigned to customer successfully." |
| Verification | re-read the Billing tab — override displays "The Top Hat Club" |
| Match rule | resolve ambiguity by email, never name alone; never guess |
| Safety rule | never apply the plan to anyone not active in Stripe or named by the user |
| Retry cap | 3 attempts per step (Step 5 still runs after any failure) |
| Loop Training Mode default | ON |
## Self-improvement

At the end of every run of this skill, before finishing, review:
- Did any step fail or need a workaround?
- Did the user correct or reject anything meaningful?
- Did you discover something a future run of this skill would need?

If (and only if) a change is meaningful, propose the specific edit to this SKILL.md to the user. Never edit the skill without the user's approval.
