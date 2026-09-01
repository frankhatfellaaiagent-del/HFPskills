---
name: aryeo-virtual-staging
description: >-
  Run AI virtual staging on a listing in Aryeo
  (hat-fella-productions-2.aryeo.com) for Hat Fella Productions: find the
  customer's listing, pick the best empty-room photos (master bedroom, living
  room, secondary bedroom, patio), stage them with Virtual Staging AI in the
  right room type and furniture style, quality-check every generated variant
  for impossible furniture, add the good ones to the listing (with and without
  watermark), and re-deliver. Use this whenever the user asks for "virtual
  staging", "stage the listing",
  "VS for a customer or address", mentions a customer note like "3 virtual
  staging", or wants empty-room photos furnished.
  This is the STAGING workflow — not delivery (hatfella-delivery-run) and not
  the audit (hatfella-delivery-qc).
---

# Hat Fella — Virtual Staging AI

Stage a listing's empty-room photos in Aryeo's built-in **Virtual Staging AI**,
then add only the results that pass quality control to the listing and
re-deliver it. The generation is easy; the value of this workflow is in two
judgment steps — **picking the right source photos** and **rejecting AI
results that look wrong**. A bad staged photo (floating furniture, a bed
blocking a door) is worse than no staged photo: never add a variant that
doesn't pass QC.

## Tools

Drive the user's own Chrome (logged into Aryeo) with the **Claude in Chrome**
tools (`navigate`, `read_page`, `find`, `computer`) — never host-level clicks.
Use `read_page`/screenshots to actually LOOK at each photo and each generated
variant; this workflow is visual judgment, not clicking.

## Workflow

### 1. Find the listing

Open `https://hat-fella-productions-2.aryeo.com/admin/listings` and search by
the customer's first name or the address the user gave (e.g. "Linda" →
630 Cranes Way apt. 306). Open the matching listing.

### 2. Open Virtual Staging AI and pick source photos

In the listing's Media → Images section click **Virtual Staging AI** (URL is
`/admin/listings/<id>/virtual-staging`), then **Add images**. Select the best
empty photo of each key room:

- **Master bedroom** — the largest bedroom.
- **Living room** — prefer the angle that shows the kitchen in the background;
  it sells the open layout.
- **Secondary bedroom(s)**.
- **Patio / balcony**, if the property has one.

That's typically 4 images. Check the listing's customer notes first — if they
specify a count (e.g. "3 virtual staging"), that wins. Skip bathrooms,
kitchens, hallways, and laundry rooms — they don't get staged. Click
**Continue**.

### 3. Stage each image with the right settings

For every selected image, set **Room Type** to match what the photo actually
shows before generating — the default carries over from the previous image
and is often wrong:

| Photo | Room Type |
|-------|-----------|
| Any bedroom | Bedroom |
| Living room | Living Room |
| Patio / balcony | Outdoor |

**Furniture Style: Scandinavian** is the house default — clean and simple.
Click **Virtually stage**. Results save automatically and generate ~3 variants
per image; you can move to the next image while earlier ones show
*Processing*.

### 4. Quality-check every variant — the hardest part

Open each image's **Virtual Staging** tab and inspect every variant at full
size. Reject a variant if:

- **Furniture sits on top of other furniture** — the most common AI failure
  (a sofa merged into a dresser, a rug through a table).
- **A bed or large piece blocks a glass/sliding door** or an obvious walkway.
  Nobody stages a room so you can't reach the balcony.
- **Odd or off-brand objects** — e.g. a barbecue grill on a small patio.
  A simple table and chairs beats a cluttered scene.
- Anything physically impossible, warped, or just weird-looking.

Pick the cleanest, simplest variant per photo. If **no** variant passes,
click **Generate more** once for another batch; if still nothing passes,
skip that photo entirely — the listing goes out without it.

### 5. Add winners to the listing

For each passing variant click **Add to listing** and add **both** options:
*with 'Virtually Staged' watermark* and *without watermark*. Confirm the green
**"Successfully added to listing"** toast appears for each — no toast means it
didn't save. When all images are done, click **Exit**.

### 6. Re-deliver

Back on the listing page, click **Re-deliver Listing** (or **Deliver Listing**
if it was never delivered) so the client gets the staged photos.

## Report

Tell the user: which listing, which rooms were staged and in what style, how
many variants were rejected and why (briefly), and confirmation that the
listing was re-delivered. If any photo was skipped because no variant passed
QC, say so explicitly.

## Common mistakes

- Staging with the wrong Room Type because the previous image's setting
  carried over — a "Bedroom" prompt on a living-room photo.
- Adding the first variant without checking the others — the AI's first try
  is often the worst.
- Accepting furniture-on-furniture or a bed blocking a glass door because it
  "mostly looks fine" at thumbnail size. Inspect at full size.
- Adding only the watermarked (or only the clean) version — both go on the
  listing.
- Forgetting to confirm the green "Successfully added to listing" toast, or
  forgetting to re-deliver at the end.

## Self-improvement

At the end of every run of this skill, before finishing, review:
- Did any step fail or need a workaround?
- Did the user correct or reject anything meaningful?
- Did you discover something a future run of this skill would need?

If (and only if) a change is meaningful, propose the specific edit to this SKILL.md to the user. Never edit the skill without the user's approval.
