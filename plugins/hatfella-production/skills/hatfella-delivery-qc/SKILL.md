---
name: hatfella-delivery-qc
description: >-
  Quality-check media delivery for Hat Fella Productions shoots in Aryeo
  (hat-fella-productions-2.aryeo.com). Use this whenever the user asks to
  "check deliveries", "QC the shoots", "make sure everything was delivered",
  "check the calendar", "verify the media/photos went out", or names a day or
  date range to audit (e.g. "check Monday's shoots", "QC last week"). Covers
  reading each appointment's package on the calendar, verifying the delivered
  media matches it (photo count, drone photos, floor plans, video; all JPEG,
  no PNG), cross-checking against the Delivered-filtered listings, and taking
  notes on anything missing or undelivered, then sending the QC report to
  fabian@hatfella.com by Gmail (and WhatsApp when available).
---

# Hat Fella — Delivery QC

Verify that every shoot on the Aryeo calendar actually got its media delivered,
and that the media matches what the customer's package promised. The check runs
in **two passes on purpose**: the calendar tells you what was *supposed* to
happen; the Delivered-filtered listings tell you what actually *went out*. An
order can sit on the calendar looking fine and never have been delivered — it
only shows up as a gap when you compare the two.

## Before you start

Confirm **which day(s) to check**. The user will usually name a day or a range
("check yesterday", "QC last week"). If they didn't, ask. Default framing:
whole days, in the account's local time (EDT).

## Tools to use

Drive the user's own Chrome (already logged into Aryeo) with the **Claude in
Chrome** tools (`navigate`, `read_page`, `find`, `computer`) — never host-level
mouse replay. Reading the page beats scrolling screenshots: use `read_page` /
`get_page_text` to pull filenames and counts off the media list instead of
eyeballing thumbnails.

## Workflow

### Pass 1 — Calendar: check every shoot against its package

1. Open `https://hat-fella-productions-2.aryeo.com/admin/calendar`, Week view,
   and navigate to the target day(s).
2. For **each appointment** on a target day:
   - Open it and read the **Appointment Items** — this is the package, e.g.
     *Essential Exposure: 30 Professional Photos, 5 Drone Photos, Floor Plan*.
     Every package is different, so the package defines the checklist for this
     order — photos, drone, floor plans, video, whatever it lists.
   - Click **View Order** to open the order/listing and check the Media
     section against the package:
     - **Photo count** — total images should match or exceed what the package
       promises (e.g. 30 professional + 5 drone ≥ 35 images).
     - **Drone photos present** — drone files are named `DJI_####`; regular
       camera stills are `IMG_####`, `6Y8A####`, and similar. If the package
       includes drone, there must be DJI files in the media.
     - **Floor plans** — the Floor Plans section count matches the package.
     - **Video** — if the package includes it, the video is attached.
     - **File format** — every image must be a **JPEG**. Any `.png` in the
       media list is a defect; note it.
   - Go back to the calendar and repeat for the next appointment.
3. Skip external/blocked calendar events — only actual shoot appointments
   (they carry an order number and customer) get checked.

### Pass 2 — Listings: confirm the orders were actually delivered

1. Go to `https://hat-fella-productions-2.aryeo.com/admin/listings` → **Filter**.
2. Set **Delivery Status = Delivered only** (this filter matters — leaving it
   open defeats the whole cross-check), and set **Delivered After / Delivered
   Before** to bracket the target day(s). Apply.
3. Compare against Pass 1: every appointment from the calendar should have its
   listing in this Delivered list. For each one you're checking, open it and
   confirm it's the same order (order #, package) and the media checks from
   Pass 1 hold.
4. **A shoot on the calendar that is missing from the Delivered list is a
   finding** — it was shot (or scheduled) but never delivered. This is the
   main failure mode this second pass exists to catch.

### Take notes — the deliverable

Record a finding whenever:

- Any media is missing versus the package (photos short, no drone files,
  missing floor plan or video), or
- A PNG (or other non-JPEG image) is in the delivered media, or
- The order is on the calendar but **not delivered**.

Report findings per order: order #, customer, address, appointment date/time,
package, and exactly what's wrong. If everything checks out, say so explicitly
per day — "all N shoots on <date> delivered and complete" — so the user knows
the day was actually checked, not skipped.

### Send the report

After the check is done, send the report to **fabian@hatfella.com**:

1. **Email (always).** Use the **Gmail MCP** to create the email
   (`create_draft`) addressed to fabian@hatfella.com. Subject:
   `Delivery QC — <date or range>`. Body: the per-order findings, then the
   all-clear lines for clean days. If the Gmail MCP can only create drafts
   (no send tool), finish the job by opening the draft in Gmail in Chrome
   (mail.google.com → Drafts) and clicking Send — the report must actually go
   out, not sit in Drafts. Confirm to the user that it was sent.
2. **WhatsApp (when possible).** If a WhatsApp channel is available — a
   WhatsApp MCP/Zapier action, or WhatsApp Web (web.whatsapp.com) logged in
   in the user's Chrome — send the same report to the contact **"Fabian AQ"**
   (condensed is fine: findings first, then the all-clear summary). Search
   the contact by that exact name; if it doesn't come up, don't guess at a
   similar contact — skip and tell the user. If no WhatsApp channel is
   reachable, skip it and tell the user it went by email only.

## Quick reference

| Item | Value |
|------|-------|
| Aryeo calendar | https://hat-fella-productions-2.aryeo.com/admin/calendar |
| Aryeo listings | https://hat-fella-productions-2.aryeo.com/admin/listings |
| Delivered filter | Delivery Status = Delivered + Delivered After/Before dates |
| Drone files | `DJI_####` |
| Regular stills | `IMG_####`, `6Y8A####`, etc. |
| Format rule | all images JPEG — any PNG is a defect |
| Finding | media missing vs package, PNG present, or on calendar but undelivered |
| Report goes to | fabian@hatfella.com via Gmail MCP (+ WhatsApp contact "Fabian AQ" when available) |

## Common mistakes

- Checking only the calendar and trusting the order page — you'll miss orders
  that were never delivered. Always run Pass 2 with the Delivered filter.
- Forgetting to restrict the listings filter to **Delivered only** and the
  right date window.
- Counting images without checking for drone (`DJI_`) files when the package
  includes drone.
- Treating every calendar block as a shoot — external events don't get QC'd.

## Self-improvement

At the end of every run of this skill, before finishing, review:
- Did any step fail or need a workaround?
- Did the user correct or reject anything meaningful?
- Did you discover something a future run of this skill would need?

If (and only if) a change is meaningful, propose the specific edit to this SKILL.md to the user. Never edit the skill without the user's approval.
