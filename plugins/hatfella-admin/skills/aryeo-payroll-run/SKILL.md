---
name: aryeo-payroll-run
description: Run bi-monthly photographer payroll in Aryeo for Hat Fella Productions. Verifies every appointment in the pay period (1st–15th or 16th–end of month, last day included) has a matching pay run item, creates missing items at the correct rate, then builds one draft pay run per photographer. Use this skill whenever the user says "run payroll", "payroll in Aryeo", "create pay runs", "check pay run items", "pay the photographers", or mentions the 1-15 / 16-31 pay period — even if they don't name Aryeo explicitly.
---

# Aryeo Payroll Run (Hat Fella Productions)

Bi-monthly payroll verification and pay run creation in Aryeo at
`https://hat-fella-productions-2.aryeo.com/admin`. Use the Claude in Chrome
browser tools (navigate, read_page, find, form_input, computer) — the user is
normally already logged in as the Frank Hat Fella AI Agent account.

## Pay periods

Payroll always covers one of two windows, and **the last day of the window is
always included**:
- **1st through the 15th** (the 15th counts)
- **16th through the last day of the month** (the 30th or 31st counts)

A shoot dated on that final day belongs in the run. If the shoot is scheduled
on the last day but hasn't been marked delivered/fulfilled yet when you run,
don't drop it — flag it so its payout gets added once it's completed.

If the user doesn't specify a period, infer the most recently completed one
from today's date and confirm before starting.

## Who gets paid

Every photographer who shot a real order in the period. In practice that's
Andrew Ferrandiz, Steven Forbes, Priscilla Samartino, and Ryan Drucker, but
include anyone who has order appointments. **Only Marlon Mora and Victoria
Mora are excluded** — they're the owners, and their appointments never
generate pay run items.

## Source of truth: use the Orders list, not just the calendar

Reconcile against the **Orders list**, because the calendar can silently hide
paid shoots. The calendar sidebar has per-team-member checkboxes, and if any
photographer is unchecked, their shoots simply don't appear — a calendar-only
sweep will then miss payouts without any warning.

Two ways to stay safe; do the first, and use the second to cross-check:

1. **Orders list (primary).** Go to `/admin/orders`, sort by *Appointment
   Scheduled*, set results to 100 per page, and read every order whose
   appointment date falls in the pay period. `get_page_text` returns the whole
   list at once (order #, address, customer, appointment date, fulfilled
   status), which is faster and more complete than clicking calendar events.

2. **Calendar with everyone shown (cross-check).** If you do use the calendar
   (`/admin/calendar`, List view, Eastern Time), first click **Show All** under
   TEAM MEMBERS so every photographer is checked, then uncheck **only Marlon
   Mora and Victoria Mora**. That guarantees every payable photographer's
   shoots are visible each run. Anytime you land on the calendar, assume the
   filter may be wrong and re-apply this before trusting what you see.

Ignore rows labelled "External event" — those are photographers' personal
calendar syncs, not orders. Only order rows (e.g. "#3512 - Faneeza Mohamed -
9773 Bennington…") count.

## Payout rates

Base packages:

| Package | Payout |
|---|---|
| Essential / Essential Exposure | $60 |
| Enhanced / Enhanced Showcase | $80 |
| Ultimate / Ultimate Presentation | $100 |

Common add-on line items each carry their own payout, and an order may be
**only** add-ons (no base package) — that's normal, don't treat a missing base
package as an error:

| Add-on | Payout |
|---|---|
| Drone Photography | $40 |
| Agent Intro | $25 |
| Zillow 3D Tour | $20 |
| Additional Photos | $15 |

**Specialty / custom-priced orders** (anything not in the tables above, e.g.
a ribbon-cutting event or a "Re-Take" line): the payout is a judgment call. If
a pay run item already exists on the order, it's handled — move on. If none
exists, do NOT guess — flag it to the user and ask what to pay. When an order
mixes a known package with an unknown extra, pay the known part and flag only
the unknown extra.

## Phase 1 — Verify pay run items

For each order in the period assigned to a payable photographer:

1. Open the order and scroll to the **Payroll** section. `get_page_text` on the
   order page shows the package/line items, the assigned team member, and any
   existing pay run items in one shot.
2. **If a pay run item exists** matching the package/add-on payout — done.
3. **If it's missing**, click **Create pay run item** and fill in:
   - Team member: the photographer on the appointment
   - Order: the order in question (and Task, if the drawer offers the specific
     line item)
   - Title: `Complete <Package>` (e.g. "Complete Essential")
   - Amount: the rate from the tables above
   - Submitted Date: **the date of the appointment** (not today)
   - Create it and confirm it lands in the Payroll table.

Keep a running list of what you verified vs. created — you'll report it and use
it for the payout doc.

## Phase 2 — One draft pay run per photographer

Only after the whole period is verified:

1. Go to `/admin/payroll/pay-runs` → **Create Pay Run**.
2. Title: `<Mon> <start>-<end> <Photographer first name>` (e.g. "Aug 1-15
   Andrew").
3. **Uncheck "Include all outstanding pay run items"** — runs are itemized per
   photographer, so this box must stay off.
4. Create it, then **Add Items to Pay Run**:
   - Submitted After: first day of the period
   - Submitted Before: last day of the period
   - Team member(s): this photographer only
   - Search, select all returned items, add them.
5. The Pay Run Total is that photographer's payout. Leave it in **Draft**.
6. Click **Export Pay Run** to download its file (CSV). Do this for every
   photographer's run. **Only export — never click "Submit Pay Run."**
   Exporting does not submit; the file downloads to the user's browser
   downloads folder.
7. Repeat for each photographer with items in the period.

## Final report

Summarize per photographer: shoots verified, items created (order #, package,
amount), draft pay run title and total, and that its export file was
downloaded. Separately list anything that needs a
decision — specialty/custom orders with no rate, last-day shoots not yet
delivered, or any order whose photographer/package was ambiguous. If the user
asked for a payout document, build a Google Doc with a per-photographer table
(date, order #, address, package, payout) plus a summary and the flagged items.

## Safety

This moves real payroll money. **Never submit a pay run — only export.** Every
run is left in **Draft** and exported; the "Submit Pay Run" button is off
limits, even if the user's phrasing sounds like they want it finalized.
Submitting is always the user's own action to take in Aryeo, not this skill's.
The deliverable of this skill is: verified items + one draft pay run per
photographer + an exported file for each.

If the user asks for a "check" or "dry run", do Phase 1 read-only: report
what's missing instead of creating it. When an amount is unusual or unclear,
ask rather than guess.

## Self-improvement

At the end of every run of this skill, before finishing, review:
- Did any step fail or need a workaround?
- Did the user correct or reject anything meaningful?
- Did you discover something a future run of this skill would need?

If (and only if) a change is meaningful, propose the specific edit to this SKILL.md to the user. Never edit the skill without the user's approval.
