---
name: top-hat-club-sync
description: Sync new Top Hat Club members from Stripe into Aryeo by applying "The Top Hat Club" pricing plan override to their Aryeo customer profile. Use whenever the user says a new Top Hat Club member signed up, asks to "add someone to Top Hat pricing", "sync Stripe subscribers to Aryeo", "apply the club pricing plan", mentions a new Stripe subscription that needs Aryeo setup, or asks to check that all active Top Hat Club subscribers have the right pricing in Aryeo.
---

# Top Hat Club → Aryeo Pricing Sync

When someone joins the Top Hat Club, they pay through Stripe (Hatfella / Real Photos Ai account). Stripe only handles the payment — Aryeo does not know about it. Each new member must manually get the "The Top Hat Club" pricing plan applied to their Aryeo customer profile, otherwise they keep paying standard prices despite being a paying club member. This skill closes that gap.

Use the Claude in Chrome tools (`mcp__claude-in-chrome__*`) for everything — the user's Chrome is logged into both Stripe and Aryeo. Do not use host-level clicks. There is no working API path set up for this today; the browser is the way.

## Step 1 — Get the member list from Stripe

If the user names the new member(s), skip to Step 2. Otherwise:

1. Navigate to `https://dashboard.stripe.com/acct_1NgSZFFgt54xnYUv/subscriptions?status=active`
2. Read the page. Each row shows the customer email, name, and product (e.g. "Top Hat Club — Annual", "Top Hat Club — Founder").
3. Collect customer name + email for every active Top Hat Club subscription. Ignore canceled/paused unless the user asks about removals.

## Step 2 — Apply the pricing plan in Aryeo (per member)

For each member:

1. Navigate to `https://hat-fella-productions-2.aryeo.com/admin/customer-users`
2. In the Search field, type the customer's **first or last name** (as it appears in Stripe) and search. If the name gets no match, try the email or a partial name — Stripe names and Aryeo names occasionally differ in spelling. If still no match, flag the member to the user instead of guessing.
3. Click the matching customer to open their profile (URL looks like `/admin/customer-users/<id>`).
4. Open the **Billing** tab.
5. Under **User Pricing Plan Override**, open the "Select a pricing plan" dropdown and choose **The Top Hat Club** (exact name — do not pick "Top Producer 2026", "PRB", or other similarly-named plans).
6. Click **Update Customer Pricing Plan**.
7. Confirm the green toast: "Pricing plan assigned to customer successfully." If it doesn't appear, re-check the dropdown value and retry once before reporting a failure.

Important: use the per-customer **Billing → User Pricing Plan Override** path, not team settings or account settings. The owner confirmed the settings-based route does not work on this account — the override is the correct method until they change the setup.

## Step 3 — Report

Tell the user, briefly:

- Members updated (name → plan applied)
- Members skipped and why (already had the plan, no Aryeo match found, ambiguous match)
- Any Stripe subscribers with no Aryeo account at all — these need the user to create the customer in Aryeo first

## Edge cases

- **Already overridden**: if the Billing tab already shows "The Top Hat Club" as the pricing plan, skip and report — don't re-submit.
- **Multiple search matches**: match on email, not name. If email isn't visible in results, open candidates until the email matches.
- **This changes live billing** — never apply the override to anyone not confirmed as an active Top Hat Club subscriber in Stripe (or explicitly named by the user).

## Self-improvement

At the end of every run of this skill, before finishing, review:
- Did any step fail or need a workaround?
- Did the user correct or reject anything meaningful?
- Did you discover something a future run of this skill would need?

If (and only if) a change is meaningful, propose the specific edit to this SKILL.md to the user. Never edit the skill without the user's approval.
