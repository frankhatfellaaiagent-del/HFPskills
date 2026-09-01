---
name: hatfella-eod-upload-check
description: >-
  End-of-night check that every one of today's Hat Fella Productions shoots has
  its media uploaded: MLS photos and drone photos in the order's Dropbox folder,
  a CubiCasa floor-plan order created, and — when the package includes them —
  a Zillow 3D tour and vertical photos. Use this whenever the user says
  "check that all photos were uploaded", "end of night check", "did the
  photographers upload", "verify today's uploads", "close out today's shoots",
  or names a day to verify uploads for. Covers walking the Patrn (yourpatrn.com)
  Today's-shoots list, counting files in Dropbox against each order's package,
  checking CubiCasa order history, ticking off the deliverables on the Patrn
  card, and WhatsApp-messaging the shoot's photographer when media is missing.
  This is the upload check (did media come IN from the photographer) — not the
  customer-delivery QC in Aryeo, which is a different skill.
---

# Hat Fella — End-of-Night Upload Check

At the end of the day, go through **every shoot on today's list** in Patrn and
confirm the photographer's media actually made it in: raw MLS photos and drone
photos in the order's Dropbox folder, and a floor-plan scan order in CubiCasa.
Tick off each deliverable on the Patrn card as it's verified. If a shoot has
nothing uploaded, message its photographer on WhatsApp so it gets fixed
tonight, not tomorrow.

This is about media coming **in** from photographers. It is not the Aryeo
customer-delivery QC (`hatfella-delivery-qc`) — that checks what went **out**
to customers.

## Tools to use

Drive the user's own Chrome (already logged into Patrn, Dropbox, CubiCasa, and
WhatsApp Web) with the **Claude in Chrome** tools (`navigate`, `read_page`,
`get_page_text`, `find`, `computer`) — never host-level mouse replay. Prefer
reading page text over eyeballing screenshots: Dropbox file lists and CubiCasa
order tables are text; pull counts and names from the page, don't scroll and
squint.

## Workflow

### 1. Get today's shoot list

Open `https://yourpatrn.com` → Dashboard → **Today's shoots** tab. Every card
in that list gets checked — the day isn't done until each one has been either
verified or escalated. Note each shoot's address, status, and time.

### 2. For each shoot: open the card and read the package

Click the shoot to open its order card. Record:

- **Deliverables** — the checklist for this order (e.g. *35 MLS Ready Photos,
  5 Drone Images, Floor Plan*). Every package is different; the deliverables
  list defines exactly what you're verifying.
- **Photographer** — who you'll message if media is missing.
- **Address** — used to find the Dropbox folder and CubiCasa order.

### 3. Check the photos in Dropbox

Click **Open in Dropbox** on the card. The order folder lives under
`Hat Fella Production Team Folder/Upload/<YYYY-MM-DD>/<Agent>/<Address>/` and
contains subfolders like **MLS Photos** and **Drone Photos**.

- **MLS Photos**: count the files (select-all shows the count; or read the
  list). These are raw bracketed frames — the camera shoots ~5 exposures per
  final photo — so the test is **raw count ÷ 5 ≥ the package's MLS photo
  count**. Example from a real night: 194 raws ÷ 5 ≈ 39 ≥ 35 required → enough.
  Camera raws are named `IMG_####`, `6Y8A####`, and similar.
- **Drone Photos**: count directly, no division — drone shots aren't
  bracketed the same way. `DJI_####` files. 42 files ≥ 5 required → enough.

If a count passes, go back to the Patrn card and **tick that deliverable's
checkbox** (MLS Ready Photos, Drone Images). Tick only what you verified.

### 4. Check the floor plan in CubiCasa

Open `https://app.cubi.casa` → **Order History**. Search for the property
address. If an order for the property exists — **Pending status counts**; it
means the scan was submitted and is processing — go back to Patrn and tick the
**Floor Plan** deliverable. No order at all = floor plan missing.

### 5. Bigger packages: Zillow 3D Tour and AI Walk-through Video

Packages vary — larger ones (e.g. *Ultimate Presentation*: 45 MLS Ready
Photos, 5 Drone Images, Floor Plan, Zillow 3D Tour, AI Walk-through Video)
carry extra deliverables. Each has its own place to verify:

- **Zillow 3D Tour**: open `https://www.zillow.com/my-3d-homes/` (the "My 3D
  Homes" dashboard → All tours list). Search or scan for the property address.
  If the address is listed with the 3D tour **READY** (Floor plan READY /
  POSTED alongside is normal), tick **Zillow 3D Tour** on the Patrn card. Not
  in the list = missing.
- **AI Walk-through Video**: this one is verified in **Dropbox** — the order
  folder must contain a **Vertical Photos** folder with files in it. That's
  the input the AI walkthrough is built from; if the folder is absent or
  empty, the deliverable can't be produced, so treat it as missing media from
  the photographer.

Same rule as the rest: tick a deliverable only after you've seen its
evidence. If a package lists a deliverable this skill doesn't cover, tell the
user rather than guessing where to verify it.

### 6. Missing media → WhatsApp the photographer

If a shoot has nothing uploaded (no Dropbox folders / empty folders, no
CubiCasa order, no Zillow tour), or a specific deliverable is missing:

1. Copy the **photographer's name** from the Patrn card and the **address**.
2. Open `https://web.whatsapp.com`, search the photographer by name, open the
   chat — match the exact name; if it doesn't come up, don't guess at a
   similar contact, skip and tell the user.
3. Send, adapting to what's actually missing:
   - Everything missing: `All media is missing for <address>. Please upload as
     soon as you can. Thank you.`
   - One thing missing: name it, e.g. `Drone photos are missing for
     <address>. Please upload as soon as you can. Thank you.`
4. Leave the unverified deliverables **unticked** in Patrn — the ticks mean
   "verified present", not "reminded someone".

If the missing shoot's photographer is the user themself, just flag it to the
user instead of messaging.

### 7. Repeat and report

Work through every shoot on the list, then summarize per shoot: verified
(which deliverables ticked) or escalated (what's missing, who was messaged).
Say explicitly when a day is fully clean — "all N shoots verified" — so the
user knows every card was checked, not skipped.

## Quick reference

| Item | Value |
|------|-------|
| Shoot list | https://yourpatrn.com → Dashboard → Today's shoots |
| Dropbox path | Team Folder/Upload/`<date>`/`<agent>`/`<address>`/ |
| MLS photo test | raw file count ÷ 5 ≥ package MLS count |
| Drone test | `DJI_####` file count ≥ package drone count (no division) |
| Floor plan | app.cubi.casa → Order History → search address; Pending = OK |
| Zillow 3D Tour | zillow.com/my-3d-homes → All tours → address listed, 3D tour READY |
| AI Walk-through Video | Dropbox order folder has a "Vertical Photos" folder with files |
| Tick a deliverable | only after its media is verified in Dropbox/CubiCasa |
| Missing media | WhatsApp Web → photographer from the card → "All media is missing for `<address>`. Please upload as soon as you can. Thank you." |

## Common mistakes

- Comparing the raw MLS file count directly against the package number — raws
  are 5-bracket exposures; divide by 5 first. (Drone photos are counted
  as-is.)
- Ticking deliverables before verifying, or ticking everything because "the
  folder exists" — open the folders and count.
- Treating a Pending CubiCasa order as missing — Pending means submitted and
  processing, which is all tonight's check needs.
- Only checking MLS/drone/floor plan on a bigger package — the deliverables
  list on the card is the checklist; Zillow 3D Tour and AI Walk-through Video
  have their own verification spots.
- Messaging a lookalike WhatsApp contact when the exact name doesn't match.
- Stopping after the first few cards — every shoot on today's list gets
  checked.

## Self-improvement

At the end of every run of this skill, before finishing, review:
- Did any step fail or need a workaround?
- Did the user correct or reject anything meaningful?
- Did you discover something a future run of this skill would need?

If (and only if) a change is meaningful, propose the specific edit to this SKILL.md to the user. Never edit the skill without the user's approval.
