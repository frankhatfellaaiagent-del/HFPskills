---
name: hatfella-missing-items-alert
description: "Audit Hat Fella shoots from the past 72 hours for missing/undelivered media, cross-check every shoot's stage on the Hat Rack production board against Aryeo, then send Fabian the findings by email (Outlook) and WhatsApp. Use for \"send Fabian the missing items\", \"72 hour delivery check\", \"alert Fabian\", or similar recurring gap-report requests."
---

# Fabian Missing-Items Alert (72h)

A fixed, seven-step pipeline: audit the last 72 hours of Hat Fella shoots for
delivery gaps, confirm Hat Rack and Aryeo agree on where each shoot stands,
then push the findings to Fabian over email and WhatsApp. The steps and their
done-rules are pre-baked and do not change between runs — only the toggle
below changes how the run behaves.

## ⚙️ Loop Training Mode — TOGGLE

```
LOOP TRAINING MODE: ON
```

Flip the word `ON`/`OFF` above to change how this skill runs. Read it fresh
every time this skill is invoked — do not assume last run's setting.

- **ON** (default): pause after every step and wait for the user's explicit
  go-ahead before starting the next one. Before running a step, check its
  done-rule first — if it already passes, skip the step (say so) and move
  on without pausing on it. Only steps that actually ran and failed get
  retried. Retries are capped (see below); never loop a step forever.
- **OFF**: run all seven steps back-to-back with no pauses for approval. Still
  check each step's done-rule before running it (skip if already passing)
  and still enforce the retry cap. Report the end state once, at the finish.

**Retry cap: 3 attempts per step**, ON or OFF. If a step still fails its
done-rule after 3 attempts, stop the run and tell the user exactly which
step and why — do not silently mark it done, and do not keep retrying past
the cap.

**Exception — Step 7 always runs.** "Stop the run" never means skipping the
WhatsApp message. No matter what failed upstream — a step blew its retry cap,
Aryeo wouldn't load, the board wouldn't budge, the email bounced or could not
be sent at all — always send Fabián AQ a WhatsApp with whatever the run did
establish, plus a plain statement of what failed and what is therefore
unverified. A partial report on WhatsApp beats silence every time; Fabian
reads WhatsApp first. Send it even if the report is only "the 72h check could
not complete — here is how far it got." Step 7 is the last thing the run does,
always, and only then does the run report its end state.

## Browser

Use **Claude in Chrome** (the user's real, already-logged-in Chrome), not
the sandboxed in-app Browser pane — the sandboxed pane doesn't persist login
and can lose the Aryeo session mid-run, forcing a re-login. Claude in Chrome
rides the existing cookie session, so as long as the user stays logged into
Aryeo and Hat Rack in Chrome normally, this runs without prompting for
credentials.

## Goal

Fabian has, in his inbox and on WhatsApp, a correct list of everything
missing or undelivered across Hat Fella shoots from the last 72 hours — and
the Hat Rack production board mirrors Aryeo, with any card the run could not
move called out for a human.

## Skill-level done-rule (the Verification)

Both are true:
1. An email with the report is in the **Sent** state to fabian@hatfella.com,
   **sent from Outlook** (never Gmail — see Step 6).
2. A WhatsApp message with the report shows as sent to contact **"Fabian
   AQ"**.

The WhatsApp message goes out **no matter what** — it is never conditional on
the email having worked, or on any earlier step passing its done-rule. If the
run is degraded, send a degraded report; do not withhold it. Exhaust every
available channel before accepting failure: WhatsApp MCP/Zapier action, then
WhatsApp Web in Chrome, then the WhatsApp desktop app.

If WhatsApp is genuinely unreachable (no channel connected, or the contact
search for "Fabian AQ" returns nothing) after exhausting the retry cap on
Step 7, the run ends with that reported explicitly to the user as a gap —
it is never treated as equivalent to "done."

## Steps

Each step: what to do, and the done-rule that lets it be skipped on a rerun.

**1. Compute window**
Action: `start = now − 72h`, `end = now`, account local time (EDT).
Done-rule: start/end are recorded for this run.

**2. Calendar pass (Aryeo)**
Action: open `https://hat-fella-productions-2.aryeo.com/admin/calendar`.
**Before reading any appointments, confirm every filter is on** — the
sidebar's Team Members, Territories, and Event Types sections each have a
"Hide All" / "Show All" toggle label: it must read **"Hide All"** (meaning
everything in that section is currently checked and visible). If any section
reads "Show All" or shows a mix, click to turn everything on first — a
calendar filtered down to a subset of photographers will silently hide their
shoots from this audit. Then, for every appointment whose date falls in the
window, open it, read the Appointment Items (the package), open View Order,
and compare the package against the order's media — photo count, drone photos
if the package includes drone, floor plan count, video if included,
**virtual staging if the order carries a Virtual Staging line item** (see
below), and that every image is JPEG (no PNG). Skip non-shoot calendar
blocks.

**Drone matching:** match drone filenames as `/^(DJI|CAM)/i`, never `DJI_`
alone. A second drone body writes `CAM_<timestamp>_####_W.jpg`; on 2026-08-19
a `DJI_`-only filter produced five false "no drone files" findings that had to
be corrected to Fabian minutes after the report went out.

**Virtual Staging is a billable line item and must be verified separately.**
It is NOT covered by the photo count — Aryeo counts staged photos as ordinary
images, so an order can hit its photo target with zero staging delivered and
still look clean. For every order whose `items[]` contains a "Virtual Staging"
line:
- Count the images with **`is_virtually_staged: true`** in the order's `/edit`
  props (staged files are also named `<base> virtually staged.jpeg`).
- **Zero staged images when staging was billed is a hard finding** — report it
  under Media gaps with the billed quantity.
- Quantity does **not** map 1:1. Healthy orders routinely carry more staged
  images than billed (#3503 billed 1, delivered 6), so never flag "more than
  billed." A count that is non-zero but short of the billed quantity is a
  "worth a human look," not a hard finding.
- Check `files` and `marketing_materials` too before calling it zero — staged
  images have turned up outside the image list.

Why this rule exists: order #3574 (3405 Meleto Blvd — Enhanced Showcase +
4× Virtual Staging, shot 2026-08-12) delivered its 41 photos on Aug 13 with
zero staged images. It sat inside the window of the Aug 13–15 runs and was
handled by the Aug 15 run for a board-stage refresh, and the gap was still
missed because staging was not on this checklist. The client phoned in about
it seven days later.

Done-rule: all filter sections confirmed showing everyone/everything, and
every in-window appointment has been opened once and has either a recorded
finding or a recorded "clean." Every order carrying a Virtual Staging line
item has a recorded staged-image count.

**3. Listings cross-check**
Action: `https://hat-fella-productions-2.aryeo.com/admin/listings` → Filter →
Delivery Status = Delivered only, Delivered After/Before = the window. Apply.
Every appointment from Step 2 should appear in this list; any that don't are
a finding ("on calendar, not delivered").
Done-rule: the Delivered-filtered list has been pulled for the window and
every Step 2 appointment has been reconciled against it.

**4. Hat Rack stage cross-check**
Action: open `https://thehatrack.vercel.app/` → **Production board** in the
left nav. Lanes run left to right: **Scheduled → Shooting → Editing → QC
Review → Delivered → Reshoot**. The Delivered lane is normally collapsed —
click "Expand Delivered lane" to read it.

For each in-window appointment from Step 2, type its street number + street
name into the board's **"Search address or agent…"** box. The board filters
down to that card and shows which lane it sits in. Search one address at a
time rather than reading the whole board — the lanes are long, Delivered is
virtualized, and a whole-board dump silently truncates. Match on **street
address**: Hat Rack cards carry address, customer, package badge, assigned
photographer and shoot date, but no Aryeo order number.

Compare the lane against the Aryeo state established in Steps 2–3:

| Aryeo state | Expected Hat Rack lane |
|---|---|
| Appointment booked, no media on the order | Scheduled |
| Shot, media uploaded, edit not finished | Shooting / Editing |
| Media complete, awaiting sign-off | QC Review |
| Listing Delivered **and** order Fulfilled | Delivered |
| Retake/reshoot booked | Reshoot, or a RETAKE-badged card |

Any disagreement is a finding — e.g. "Aryeo shows Delivered + Fulfilled but
Hat Rack still has it in QC Review", or "Hat Rack shows Delivered but the
Aryeo order is only Partially Fulfilled". Also flag a shoot that exists in
one system and not the other.

Two things that are **not** findings: the board's banner warns that delivered
orders older than 14 days drop off the board entirely (they move to the Hat
Rack Calendar), so an absent card for older work is expected; and a card
sitting in "Needs a decision" at the top of the board is a Hat Rack triage
state, not a stage mismatch.

Done-rule: every in-window appointment from Step 2 has been searched on the
Hat Rack board once, and each has a recorded lane plus either "matches Aryeo"
or a recorded mismatch.

**4b. Mirror Hat Rack to Aryeo (write step)**
**Aryeo is the source of truth. Hat Rack gets corrected to match it, never
the other way round.** For every mismatch found in Step 4, move the Hat Rack
card to the lane Aryeo implies — in both directions:

- **Hat Rack behind** (Aryeo Delivered **and** Fulfilled, card still in
  Editing/QC Review) → move the card to **Delivered**.
- **Hat Rack ahead** (card in Delivered, but the Aryeo order is Unfulfilled
  or Partially Fulfilled, or the listing isn't on the Delivered-filtered
  list) → move the card **back** to the lane that matches Aryeo, normally QC
  Review.

How to move a card — mechanics verified on the live board:

1. Cards in **QC Review carry a per-card "Ready" toggle**, and the lane
   header counts them (`1/7` = one of seven marked ready). A card reading
   `Ready: no` is not signed off. Click the Ready chip first — it flips to a
   filled dot, persists (`ready_at` on the Supabase `listings` row), and
   fires no client-facing email. **Only tick Ready when Aryeo genuinely
   shows the listing Delivered** — it is a QC sign-off, not a cosmetic flag.
2. Then drag the card into the target lane. The board is a dnd-kit board:
   the card is `[role=button][aria-roledescription="draggable"]`, and lanes
   are `<section aria-label="… column">`.
3. **Verify the move landed.** Re-read the card's lane
   (`el.closest('section').getAttribute('aria-label')`) and the lane header
   counts. Do not assume the drag worked.

⚠️ **Known tooling limit:** synthetic drags often do *not* complete. The card
announces "Picked up …" in the live region and then stays put; arrow keys do
not carry it across lanes either. If after 3 attempts the card has not
changed lanes, **stop trying** and record it in the report as
*"mismatch — needs a manual card move"* with the current and target lanes.
Never report a card as mirrored unless step 3 confirmed the new lane.

Never touch: cards outside the 72h window, CANCELLED cards, anything in the
Reshoot lane, and delivered work older than 14 days (already off the board).

Done-rule: every Step 4 mismatch has either (a) a re-read confirming the card
now sits in the Aryeo-implied lane, or (b) an explicit "needs a manual card
move" entry carried into the report. Every Ready toggle and lane move the run
performed is listed so Fabian can see exactly what the agent changed.

**5. Compile the report**
Action: one report, findings only — per order: order #, customer, address,
appointment date/time, package, and exactly what's wrong (short photos, no
drone files, missing floor plan/video, PNG present, not delivered, or a Hat
Rack/Aryeo stage mismatch). Keep three clearly separate sections — they go to
different people to fix:
1. **Media gaps** (Aryeo — short photos, missing floor plan/video, **virtual
   staging billed but not delivered**, PNG present, not delivered).
2. **Stage mismatches**, split into *corrected automatically* (what Step 4b
   actually changed, as old lane → new lane) and *needs a manual card move*
   (where the drop would not land).
3. **Clean** — shoots with no gaps whose stages already agree.

If nothing is missing and every stage agrees, the report says so explicitly
for the window — never leave it ambiguous whether the window was actually
checked.
Done-rule: report text is finalized, covers the full window, and discloses
every board change Step 4b made.

**6. Send email**
**Outlook only — never Gmail.** Per the workspace ground rule in
`CLAUDE.md`, all Hat Fella email goes out through Outlook.

Action: send via the Zapier **Microsoft Outlook → Send Email** action
(`microsoft_outlook_send_email`, an `execute_zapier_write_action` call) — to
`fabian@hatfella.com`, subject `Missing Items — <window dates>`, body = the
Step 5 report, `bodyFormat: Text`. It sends outright; there is no separate
draft-then-send round trip.

Check one thing before firing it: the recipient is exactly
`fabian@hatfella.com`.

**Which mailbox it sends from does not matter** — take whatever Outlook
account is connected and send. Don't pause to ask about the sender, and
don't treat an unexpected sender address as a reason to stop.

Fallback if the Zapier action is unavailable or errors out: open Outlook on
the web in Chrome (`outlook.office.com`), compose the same message, and send
it. Do **not** fall back to Gmail — a report sitting in the wrong system is
a failed step, not a partial success.

Done-rule: the message is confirmed Sent to fabian@hatfella.com **from
Outlook** — either a success response from the Zapier action, or the message
visible in Outlook's Sent Items.

**7. Send WhatsApp — ALWAYS, no matter what**
Action: same report (condensed is fine) to the contact **"Fabian AQ"** —
exact name match, don't guess a similar contact — via whichever WhatsApp
channel is available (WhatsApp MCP/Zapier action, or WhatsApp Web in
Chrome).

This step is unconditional. Run it even when Step 6 failed, when an earlier
step blew its retry cap, or when the audit is incomplete — in those cases
send what the run did establish and say plainly what failed and what is
therefore unverified. Never end a run without attempting this step.

Formatting: WhatsApp Web sends on Enter, so build the message body with
`document.execCommand('insertText', …)` into the composer and then press
Enter once. Note that `insertText` **collapses newlines** — for a readable,
multi-line message, type each line and press **Shift+Enter** between lines
instead, or accept a single run-on block. Do not send a second "cleaner"
copy; one message, even an ugly one, beats double-messaging Fabian.

Done-rule: the message is confirmed sent to "Fabian AQ".

## Quick reference

| Item | Value |
|---|---|
| Window | now − 72h → now, EDT |
| Calendar | https://hat-fella-productions-2.aryeo.com/admin/calendar |
| Listings | https://hat-fella-productions-2.aryeo.com/admin/listings |
| Delivered filter | Delivery Status = Delivered + Delivered After/Before = window |
| Drone match | `/^(DJI|CAM)/i` — never `DJI_` alone (CAM_ bodies fly drone too) |
| Virtual Staging | billed line item → count `is_virtually_staged` images; **zero when billed = finding**; more than billed is fine |
| Hat Rack board | https://thehatrack.vercel.app/ → Production board |
| Hat Rack lanes | Scheduled → Shooting → Editing → QC Review → Delivered → Reshoot |
| Hat Rack lookup | search box, one street address at a time; Delivered lane must be expanded |
| Hat Rack caveat | delivered orders >14 days old drop off the board (Calendar instead) |
| Mirror direction | Aryeo is source of truth; correct Hat Rack to match, both directions |
| Move mechanic | tick per-card "Ready" first (QC Review gate), then drag lane → verify |
| If the drag won't land | 3 attempts max, then report "needs a manual card move" — never claim mirrored |
| Email to | fabian@hatfella.com (must be Sent, not Draft) |
| Email via | **Outlook only, never Gmail** — Zapier "Microsoft Outlook → Send Email"; fallback outlook.office.com in Chrome |
| Sender mailbox | doesn't matter — any connected Outlook account is fine |
| WhatsApp to | contact "Fabian AQ" (exact name) |
| WhatsApp rule | **always send, no matter what** — never gated on Step 6 or any earlier step |
| Retry cap | 3 attempts per step (Step 7 still runs after any failure) |
| Loop Training Mode default | ON |
## Self-improvement

At the end of every run of this skill, before finishing, review:
- Did any step fail or need a workaround?
- Did the user correct or reject anything meaningful?
- Did you discover something a future run of this skill would need?

If (and only if) a change is meaningful, propose the specific edit to this SKILL.md to the user. Never edit the skill without the user's approval.
