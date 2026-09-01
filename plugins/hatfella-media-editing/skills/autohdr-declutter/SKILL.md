---
name: autohdr-declutter
description: >-
  Run an AI photo edit in AutoHDR (autohdr.com) for a Hat Fella Productions
  listing — De-clutter a room, or AI Re-Edit to remove a specific thing
  (the photographer in a mirror, a trash can, a car in the driveway) — then
  download the edited photos, add them to the matching listing in Aryeo
  (hat-fella-productions-2.aryeo.com), and re-deliver with a note that says
  the delivery is the declutter/edit photos. Use this whenever the user asks
  to "declutter", "de-clutter", "clean up the photos", "remove X from the
  photo", "take the photographer out of the mirror", "AutoHDR edit", or names
  a customer/address plus something that needs removing or tidying. This is
  the PHOTO-EDIT workflow — not virtual staging (aryeo-virtual-staging),
  not first delivery (hatfella-delivery-run), not the audit
  (hatfella-delivery-qc).
---

# Hat Fella — AutoHDR Declutter / Remove-object edit

A client (or the QC audit) asks for a room to be decluttered or for one
specific thing to be removed from a photo. The edit happens in **AutoHDR**,
the edited files come back to the Mac as a zip, and the finished photos get
added to the listing in **Aryeo** and re-delivered. Each AI edit spends an
AutoHDR credit, so edit only the photos that were asked for — nothing extra.

## Tools

Drive the user's own Chrome with the **Claude in Chrome** tools (`navigate`,
`find`, `read_page`, `computer`, `file_upload`) — never host-level clicks.
Both sites are already logged in there: AutoHDR as
**hatfellaproductions@gmail.com**, Aryeo as the Hat Fella admin. Look at the
photos (screenshots / zoom) — picking the right frame and judging the result
are the parts that matter.

## Workflow

### 1. Find the listing in AutoHDR

Open `https://www.autohdr.com/listings`. The left rail lists listings as
`<shoot date> / <customer name>` (e.g. `2026-08-22 / John Guevarra`). Use the
search box with the customer's name or the address the user gave and open
that listing. If the request came without a listing name, match by the
photos themselves (address in the Aryeo order → shoot date → customer).

### 2. Pick the photo(s) and the right tool

Click a photo to open the editor (**AI Tools** tab). Two tools cover
everything this workflow gets asked for:

| Ask | Tool | How |
|-----|------|-----|
| Remove one specific thing — "photographer in the mirror", "trash can", "cord on the floor" | **AI Re-Edit** | Type a plain instruction in *Edit Instructions* that names exactly what to remove, e.g. `remove photographer from mirror`, then **Generate**. Reference image is optional; skip it. |
| The room is just messy — "declutter", "clean it up", "too much stuff" | **De-clutter** | Click it; a dialog says *This Declutter will use 1 credit* → **Confirm & Process**. |

Write the Re-Edit instruction as the user phrased the ask, but concrete:
"remove <thing> from <where>". If the user asked for several separate items
in one photo, one instruction listing them is fine; if they asked for the
whole room cleared, that's De-clutter, not a Re-Edit.

Kick off all the requested edits before waiting — processing takes a minute
or two per photo and runs in the background (the thumbnail shows
*Decluttering…* / a spinner on the tool button).

### 3. Check the result

Close the editor. Edited photos appear as **stacks** on the listing grid
(`1/2` badge, labelled *Re-Edit* or *Declutter*; `2/2` is the original). Click
**Expand stacks** if they're collapsed, then open the edited frame full size
and compare against the original:

- The thing that was supposed to go is actually gone, with nothing warped or
  smeared where it was.
- Nothing else changed — furniture, walls, windows, floor all still match the
  original.
- De-clutter results are often "better, not perfect". That's acceptable; a
  blurred patch, a duplicated object, or a missing piece of real furniture
  is not — re-run once with a more specific Re-Edit instruction, and if it
  still fails tell the user instead of delivering a bad frame.

### 4. Download the edited photos

Tick the checkbox on each **edited** frame only (not the originals), then
**Download**. AutoHDR saves a zip to the Mac's `~/Downloads` named after the
listing (e.g. `2026-08-22_John_Guevarra_10081_SW_100th_Ave_Ocala_.zip`).
Unzip it (double-click, or `unzip` via `device_bash` if Downloads is
connected). Edited files carry the tool in the name —
`DSC08411_declutter_<hash>.jpg`, `DSC08366_reedit_<hash>.jpg` — which is how
you tell them apart from originals later.

### 5. Add them to the listing in Aryeo

Open `https://hat-fella-productions-2.aryeo.com/admin/listings`, search the
customer name (e.g. `john guevarra`) and open the listing for the same
address — the customer may have several. Scroll to **Media → Images** →
**Add** → **From device** and upload the unzipped edited JPGs (use
`file_upload`, pointing at the files in `~/Downloads/<unzipped folder>/`).
Confirm the image count went up by the number of files you added. Leave the
originals in place — the client gets both.

### 6. Re-deliver

Click **Re-deliver Listing**. The dialog notes when the listing was last
shared (leave the recipient as the customer). Edit the body so the client
knows why they're getting another email — change

> Your content for `<address>` is ready for download!

to

> Your content for declutter photos for `<address>` is ready for download!

(or "for the edited photos" / "for the retouched photos" if it was a
Re-Edit). Then **Deliver**. If the user said this is a test or "don't
deliver", stop before this step and say so.

## Report

Tell the user: listing and customer, which photos were edited and with
which tool (and the Re-Edit instruction used), how many credits were spent,
whether each result passed the check, and that the files were added to the
Aryeo listing and re-delivered (or explicitly not delivered).

## Common mistakes

- Using De-clutter when the ask was one specific object — it rewrites the
  whole room and spends a credit on a change nobody asked for. One thing →
  AI Re-Edit.
- Downloading the originals along with the edits, or uploading both to
  Aryeo, so the listing gets duplicate frames.
- Uploading to the wrong Aryeo listing because the customer has several —
  match the address, not just the name.
- Re-delivering with the stock "Your content for …" text; the client already
  has that email and won't know what's new.
- Delivering a Re-Edit that left a smear or ghost where the object was —
  inspect at full size, not thumbnail.

## Self-improvement

At the end of every run of this skill, before finishing, review:
- Did any step fail or need a workaround?
- Did the user correct or reject anything meaningful?
- Did you discover something a future run of this skill would need?

If (and only if) a change is meaningful, propose the specific edit to this SKILL.md to the user. Never edit the skill without the user's approval.
