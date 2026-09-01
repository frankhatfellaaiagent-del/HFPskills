---
name: aryeo-cubicasa-floorplan-sync
description: >-
  Attach CubiCasa floor plans to listings in Aryeo
  (hat-fella-productions-2.aryeo.com) for Hat Fella Productions: for a given
  shoot day or a specific customer/address, open each listing that needs floor
  plans, use the CubiCasa importer in the Floor Plans media section, match the
  right CubiCasa scan to the listing (by exact address, or by nearby street +
  shoot date + Google Maps when CubiCasa's address differs from Aryeo's), Sync
  All, and confirm both plans landed. Use this whenever the user says "floor
  plans", "cubicasa", "sync the floor plan", "attach the floor plan", "floor
  plans for today / for a customer / for an address", or a listing is missing
  its floor plan before delivery. This is the FLOOR PLAN workflow — not
  delivery (hatfella-delivery-run), not staging (aryeo-virtual-staging).
---

# Hat Fella — CubiCasa Floor Plan Sync

Pull a listing's floor plan from CubiCasa into Aryeo. The click path is
trivial; the whole job is **matching the right CubiCasa scan to the right
listing**. CubiCasa's address comes from the phone's GPS/geocoder at scan
time, so it often does not match the address the customer typed into Aryeo
(e.g. Aryeo says "1416 SW Rd, Sanford" while CubiCasa says "1435 Roosevelt
Avenue, Sanford"). Syncing the wrong scan puts another house's floor plan on
a customer's listing, so verify before you sync.

## Tools

Drive the user's own Chrome (logged into Aryeo) with the **Claude in Chrome**
tools (`navigate`, `read_page`, `find`, `computer`) — never host-level clicks.
Open Google Maps in a separate tab when you need to confirm a location.

## Inputs

The user gives either a **shoot day** ("floor plans for today / Saturday") or
a **specific customer or address**. For a day, the candidates are all listings
whose shoot date is that day; for a customer, just their listing(s).

## Workflow

### 1. Find the listings that need floor plans

Open `https://hat-fella-productions-2.aryeo.com/admin/listings` (sorted by
Date Created, newest first). Each card shows the shoot date/time chip, the
customer, and the order number. Open each candidate listing (`/admin/listings/LISTING_ID/edit`) and scroll
to **Media**. A listing needs this workflow when
**Floor Plans** shows `0`. If it's not obvious the customer ordered a floor
plan, expand the order on the listing page and check the line items — don't
attach a floor plan nobody paid for.

Note the listing's **address, city, and shoot date** — that's what you'll
match against.

### 2. Open the CubiCasa importer

In the Floor Plans row click the purple **CubiCasa** button. The "CubiCasa
Importer" dialog lists recent CubiCasa scans by address, newest first, each
with `Sync`, `Sync w/ Dimensions`, and `Sync All` buttons. A scan already
attached to some listing shows a green **Connected** badge and a red
**Remove Sync** instead.

### 3. Match the scan to the listing

**Easy case (most of the time):** a row's street name and house number match
the listing's address (e.g. listing "39913 Swift Rd, Eustis" ↔ CubiCasa
"39937 Swift Road, Eustis" — same street, same city, number within a few
digits of geocoder drift). Match it and move on.

**Hard case:** nothing matches the address. Then:

1. Narrow by **recency and city** — scans from the last few shoots sit at the
   top of the list; drop any already marked Connected and any in the wrong
   city.
2. For each remaining candidate, copy its address and open it in **Google
   Maps** in a new tab. Look at where the pin lands relative to the listing's
   street. In the reference example, "1435 Roosevelt Ave" pinned right where
   Roosevelt Ave meets SW Rd — a few doors from 1416 SW Rd — so it was the
   same house.
3. Confirm with the street-view/listing photos if the pin alone is
   ambiguous (compare the house exterior to the listing's cover photo).
4. If you still can't get a confident match, **stop and ask the user**
   rather than guessing. Tell them which scans you ruled out and why.

### 4. Sync

Click **Sync All** on the matched row (not plain `Sync` — Sync All pulls
every plan variant, which is what the listing should carry). Wait for the
green "CubiCasa order has been synced." toast. Close the dialog.

### 5. Verify and save

Expand the Floor Plans row: the counter should read **2** and both plan
thumbnails should be present, with "Make floor plans section visible to
customers when the listing is delivered" toggled on. Save the floor plan
settings (toast: "Floor plan settings have been saved."). If you reopen the
CubiCasa dialog, the row you synced now shows **Connected** — a quick
sanity check that you attached the right one.

Repeat for every listing on the list.

## Report back

One line per listing, e.g.:

- `1416 SW Rd, Sanford (Order #3651)` — synced from CubiCasa "1435 Roosevelt
  Ave" (address mismatch, confirmed via Maps pin). 2 plans, saved.
- `39913 Swift Rd, Eustis (Order #3648)` — already Connected, nothing to do.
- `275 Abbott Ave, Lake Mary (Order #3650)` — no matching scan found; shoot
  is later today, scan probably not uploaded yet.

Flag anything you didn't sync and why, so the user can handle it.

## Gotchas

- Don't click **Remove Sync** on a Connected row unless the user asks — it
  detaches the plan from whichever listing it's on.
- A scan that isn't in the list yet usually means the photographer hasn't
  finished/uploaded the CubiCasa scan; say so instead of forcing a match.
- Two listings on the same day in the same city can both look "close" on the
  map. Recency order in the list plus the house number direction (odd/even
  side of the street) usually breaks the tie; otherwise ask.

## Self-improvement

At the end of every run of this skill, before finishing, review:
- Did any step fail or need a workaround?
- Did the user correct or reject anything meaningful?
- Did you discover something a future run of this skill would need?

If (and only if) a change is meaningful, propose the specific edit to this SKILL.md to the user. Never edit the skill without the user's approval.
