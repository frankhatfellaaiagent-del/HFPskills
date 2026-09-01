---
name: hatfella-delivery-run
description: >-
  Run the daily media delivery for Hat Fella Productions in Aryeo
  (hat-fella-productions-2.aryeo.com): work through Yesterday's Appointments,
  verify each listing's photos against the property and package, check floor
  plan / Zillow 3D status, chase photographers and video editors on WhatsApp
  for anything missing, apply known customer discounts, and deliver what's
  ready with the right email wording. Use this whenever the user says "deliver
  yesterday's shoots", "start delivering", "send out the photos", "run the
  deliveries", "deliver the listings", or asks to process/ship yesterday's
  appointments. This is the DELIVERY workflow (getting media out the door) —
  not the after-the-fact audit (that's hatfella-delivery-qc) and not SD-card
  uploading (that's hatfella-shoot-upload).
---

# Hat Fella — Daily Delivery Run

Work through every listing in Aryeo's **Yesterday's Appointments** view and get
its media delivered. For each listing you: verify the photos are actually
complete, check the non-photo items (floor plan, 3D tour, video) are on track,
chase whoever owes something missing, and deliver whatever is ready **today** —
with the email telling the client the rest is coming. Partial delivery on time
beats complete delivery late; the one hard rule is never mark an order
Fulfilled until absolutely everything has gone out.

## Tools

Drive the user's own Chrome (logged into everything) with the **Claude in
Chrome** tools (`navigate`, `read_page`, `find`, `computer`) — never host-level
clicks. Prefer `read_page`/`get_page_text` to read media filenames, counts, and
order details instead of scrolling screenshots. Apps involved: Aryeo, Zillow,
CubiCasa (inside Aryeo), Dropbox web, WhatsApp Web (web.whatsapp.com).

## Workflow — per listing

Open `https://hat-fella-productions-2.aryeo.com/admin/listings` → saved view
**Yesterday's Appointments** (list view, 100 per page). Skip listings already
marked **Delivered**. For each Undelivered listing, open it and run the checks:

### 1. Verify the photos are complete

- Open the Media → Images section and review coverage: exterior/front, twilight
  (if the package or notes include one), **drone** shots (files `DJI_####`;
  regular stills are `IMG_####`, `6Y8A####`, `DSC####`), living room, kitchen,
  every bedroom, bathrooms, laundry.
- **Confirm the bedroom/bathroom count against the actual property**: look up
  the address on Zillow (or a quick web search) to get beds/baths, then make
  sure the photo set shows that many distinct bedrooms and bathrooms. A
  4-bed/2-bath house whose photos show three bedrooms means the shoot is short
  — that's a chase, not a deliver.
- Read the right-hand **customer notes / team notes** (photo preferences,
  specialty delivery items like "1 twilight, 3 virtual staging") and
  **internal notes** (access, RUSH flags). These modify the checklist.

### 2. Read the package — it defines what's owed

The order's items (e.g. *Ultimate Presentation: 40 photos, 5 drone, Zillow
walkthrough, social video, floor plan* or *Essential Exposure: 30 photos,
5 drone, floor plan, 1 virtual twilight*) are the delivery checklist. Photo
count should meet or beat the package.

### 3. Floor plan / 3D — route by package

- **Essential Exposure** and **Enhanced Social Media** packages → **CubiCasa**.
  In the listing's Floor Plans section click **CubiCasa → Load Recent
  Floorplans** and find the address. *Processing* means it's on the way — hit
  **Sync All** so it lands automatically when done. Not in the list at all →
  chase the photographer (step 5).
- **All other packages** (Ultimate, anything with a Zillow walkthrough) →
  **Zillow 3D Home**. Go to `zillow.com/my-3d-homes` signed in as
  **hatfellaproductions@gmail.com** (sign out of any other Zillow account
  first) and search by street name. Tour missing → chase the photographer.

### 4. Video orders — check Dropbox, hand off to editors

If the package includes a video: in Dropbox web, navigate
`Victoria Mora / Hat Fella Production Team Folder / Upload / <shoot date
YYYY-MM-DD> / <customer name> / <address>/`. Confirm the raw **Vertical
Photos** are uploaded, then copy the share link of the **vertical edited**
folder and post it in the WhatsApp group **"Video Editing"**:

> `<dropbox link>` video for `<address>` `<customer name>`

If the verticals aren't uploaded yet, chase the photographer instead.

### 5. Chase anything missing — WhatsApp, always through the group

Find who shot it (Team Members on the Aryeo appointment). Post in the WhatsApp
group **"HFP Photographers"** — not a DM — so the whole team (including Danny)
can see upload status. Format:

> `<address, city, state zip>` missing `<item>`. Please upload it when you get
> a chance. @`<photographer>` thank you

For a missing Zillow 3D specifically the ask is "Please upload the zillow 3D
for `<address>`". Always close with a thank-you — courteous to photographers,
editors, and clients, every time. Exact group names only; if a group or
contact doesn't come up in search, don't guess — skip and tell the user.

### 6. Known customer pricing — Easy Sell

**Easy Sell FL always pays $150 for the Essential plan.** If an Easy Sell
order shows the $175 list price, add a discount before delivering: order →
Discount → **One Off Coupon**, name `Easy Sell`, Amount **$25** off.

### 7. Deliver what's ready

Click **Deliver Listing**. In the email dialog, tailor the body to what's
actually going out:

- Photos only, rest pending → change "Your content" to "Your photos" and add:
  *"The rest of the media will be sent by the end of the day."*
- Only the floor plan pending → add: *"Floor plan will be ready by the end of
  the day."*
- Everything included → leave the default wording.

**Do not tick "mark as fulfilled"** unless every single item in the package
has been delivered. Then send the delivery.

### 8. Next listing

Back to the Yesterday's Appointments view; repeat until all are handled.

## Report

When the run is done, summarize per listing: address, customer, package,
what was delivered, what's still pending and who was chased (with the group
message sent). That's the user's picture of the day.

## Quick reference

| Item | Value |
|------|-------|
| Aryeo listings view | Listings → saved view "Yesterday's Appointments" |
| Drone files | `DJI_####` (stills: `IMG_####`, `6Y8A####`, `DSC####`) |
| CubiCasa packages | Essential Exposure, Enhanced Social Media |
| Zillow 3D packages | everything else (Ultimate, Zillow walkthrough) |
| Zillow 3D dashboard | zillow.com/my-3d-homes — hatfellaproductions@gmail.com |
| Dropbox video path | Victoria Mora / Hat Fella Production Team Folder / Upload / date / customer / address |
| Photographer chase | WhatsApp group "HFP Photographers", @-tag the shooter |
| Video handoff | WhatsApp group "Video Editing", Dropbox link + address + customer |
| Easy Sell rule | Essential @ $150 → One Off Coupon "Easy Sell", $25 off |
| Fulfilled checkbox | only when 100% of the package is delivered |

## Common mistakes

- Delivering without checking room count against the property's actual
  beds/baths — a short shoot slips through looking "full".
- DM-ing the photographer instead of posting in HFP Photographers — the team
  loses visibility on what's outstanding.
- Marking Fulfilled on a partial delivery.
- Sending the default "your content is ready" email when only photos went out
  — the client thinks that's everything.
- Looking for an Essential Exposure floor plan in Zillow 3D (it's CubiCasa),
  or vice versa.

## Self-improvement

At the end of every run of this skill, before finishing, review:
- Did any step fail or need a workaround?
- Did the user correct or reject anything meaningful?
- Did you discover something a future run of this skill would need?

If (and only if) a change is meaningful, propose the specific edit to this SKILL.md to the user. Never edit the skill without the user's approval.
