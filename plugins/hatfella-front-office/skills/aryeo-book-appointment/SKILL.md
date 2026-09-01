---
name: aryeo-book-appointment
description: >-
  Book a photo shoot in Aryeo (hat-fella-productions-2.aryeo.com) for Hat
  Fella Productions: create a new listing with an order, attach the right
  customer, add their package and discount, and schedule the appointment
  with a photographer. Use this whenever the user shares a screenshot of a
  text/iMessage from a realtor asking for a shoot, says "book this", "book
  an appointment", "schedule a shoot", "create the listing for [address]",
  "put this on the calendar", or pastes an address with a date/time. This is
  the BOOKING workflow — not delivery (hatfella-delivery-run), not virtual
  staging (aryeo-virtual-staging).
---

# Hat Fella — Book an Appointment in Aryeo

Turn a realtor's text message (usually a screenshot) into a scheduled
listing + order in Aryeo. Most of the clicking is routine; the judgment is
in **reading the message correctly** (address, who sent it, when they want
it) and **getting the customer/package/notification details right** so the
realtor gets billed and notified correctly.

## Tools

Drive the user's own Chrome (already logged into Aryeo) with the **Claude in
Chrome** tools (`navigate`, `find`, `form_input`, `computer`, `read_page`) —
never host-level clicks. If the request arrived as an image, read the
screenshot directly; do not open Preview.

## Inputs to extract before touching Aryeo

From the screenshot / message / user prompt, pull out:

| Field | Where it comes from | If missing |
|-------|---------------------|------------|
| **Address** | The message text (e.g. "1413 Canal Point Rd, Longwood") | Ask |
| **Customer** | The sender / conversation name (see mapping below) | Ask |
| **Package** | Named in message ("Jenn full pkg") or customer default | Use customer default |
| **Date & time** | Message, screenshot, or user's instruction | Ask — do not guess |
| **Photographer** | User's instruction; default Steven | Use default |
| **Access code** (lockbox / gate / door) | e.g. "Code 2750" in the message | Skip — but look hard, it's easy to miss |

### Customer mapping

The sender name is often an assistant, not the actual Aryeo customer.

| Sender / conversation | Aryeo customer | Default package | Discount |
|-----------------------|----------------|-----------------|----------|
| "Angela Glory Assistant", "Jenn", Glory International | **Jennifer Clark** (office@gloryire.com, Glory International Real Estate) | **Ultimate Presentation** | **$100 off** ("Glory" discount) — top client, always |

For anyone else, search the Customers box by last name; if there is more
than one plausible match, ask rather than guessing — the wrong customer gets
the invoice and the delivery.

## Workflow

### 1. Create the listing with an order

Go to `https://hat-fella-productions-2.aryeo.com/admin/listings` → **Create
Listing**. Leave the **With Order** tab selected.

### 2. Address

Type the street address in the **Address** search box and pick the
autocomplete match (confirm city/ZIP look right — "Address saved
successfully" toast appears). Only use **Add Manually** if autocomplete
can't find it.

### 3. Customer

In **Customers**, search by last name (e.g. `clark`) and pick the exact
person from the dropdown by name *and* email. The customer's saved notes
(VIP status, photo preferences, specialty delivery items) load automatically
— read them, they matter later for the shoot and delivery.

### 4. Package and discount

In **Order Items**, type the package name (e.g. `ulti`) and select it.
Check the totals: the customer's discount should appear on its own line
(e.g. "Glory ($100.00 off)"). If it's not there for a customer who gets
one, add it via **Discount → Add**. Verify the Total before moving on
(Ultimate Presentation for Jennifer Clark = $397 − $100 = **$297**).

### 5. Appointment

Click **Add Appointment**, then switch to **Manual Choice** (the
Availability Picker hides same-day and short-notice slots, and most requests
are ASAP).

- **Appointment Date**: set the date, hour, minute and AM/PM exactly as
  requested. The picker defaults to *right now* — always change it.
- **Timezone**: Eastern.
- **Team Members**: search `steven` → **Steven Forbes**
  (majesticvues@gmail.com), unless the user names someone else.
- A yellow **Booking limit conflict** warning ("less time than Steven
  Forbes's minimum booking notice") is expected for short-notice bookings —
  ignore it, it does not block saving.
- Duration and Items fill from the package; leave them.

### 6. Notifications — decide, don't default

The **Send notifications when creating the appointment** checkbox emails the
realtor a confirmation. Leave it **on** if the conversation in the
screenshot happened within the last ~30–60 minutes (the realtor is waiting
for confirmation). Turn it **off** if the message is older than that or the
user says not to notify — a stale automatic email confuses the client. When
the timestamp isn't visible, ask.

### 7. Create

Click **Create Listing** (bottom right). Success = redirected to the new
listing page showing the address, the customer, and an **Order #**.

### 8. Internal Notes — the access code (do not skip)

This is the step most easily forgotten and the one that strands a
photographer at a locked door. Re-read the message for any code — "Code
2750", "LB 1234", "lockbox", "gate", "door code", "combo" — and put it in
the listing's **Internal Notes**: on the new listing page, scroll down the
right column past Internal Customer Notes to **Internal Notes**, type the
code exactly as written (e.g. `Code 2750`), click **Save Notes**, and wait
for the button to grey out (saved). Existing listings use the same
convention (e.g. `LB 2736`). Also add any other access instructions from
the message (gate name, "call on arrival", occupied/vacant).

If there's no code in the message, say so in the report so the user can ask
the realtor before the shoot.

### 9. Report back

One line: address, customer, package/total, appointment date-time,
photographer, notifications on/off, order number, and the access code
saved in Internal Notes (or "no code in message").

## Example

Input: iMessage screenshot from "Angela Glory Assistant" at 1:55 PM: "Hello,
have a property we are being asked to get listed asap. How soon can you
shoot (Jenn full pkg) and return? 1413 Canal Point Rd, Longwood Code 2750".
User says: "book it today 5pm".

Result: Listing 1413 Canal Point Rd, Longwood FL 32750 · Jennifer Clark ·
Ultimate Presentation $297 after Glory discount · Mon Aug 24, 5:00 PM ET ·
Steven Forbes · notifications ON (message was 10 min old) · Order #3655 ·
Internal Notes saved: "Code 2750".

## Self-improvement

At the end of every run of this skill, before finishing, review:
- Did any step fail or need a workaround?
- Did the user correct or reject anything meaningful?
- Did you discover something a future run of this skill would need?

If (and only if) a change is meaningful, propose the specific edit to this SKILL.md to the user. Never edit the skill without the user's approval.
