---
name: hatfella-shoot-upload
description: >-
  Upload real-estate photos from a photographer's camera SD card to the correct
  shoot order in Patrn (yourpatrn.com production board), cross-referencing the
  shoot in Aryeo (hat-fella-productions-2.aryeo.com). Use this whenever the user
  says they are "uploading a shoot", "uploading photos", "uploading someone's SD
  card", processing media for a property/customer, or names a photographer's SD
  card and a customer/address/agent to upload for (e.g. "upload Brianna's 2:30
  from the card"). Covers matching photos to the right appointment by camera
  type and timestamp, tagging the batch, and verifying every file uploaded.
---

# Hat Fella — Shoot Photo Upload (SD card → Patrn)

Move a batch of photos off a photographer's camera SD card into the correct
order on the **Patrn production board** (yourpatrn.com), using the **Aryeo
calendar** to confirm which shoot the photos belong to. The whole point is
getting the *right* photos onto the *right* order — the matching steps (which
appointment, which file range) are where care matters most; the button-pushing
is mechanical.

## Tools to use

The browser is the user's own Chrome, logged into both apps — drive it with the
**Claude in Chrome** tools (`navigate`, `read_page`, `find`, `computer`,
`file_upload`), never host-level mouse replay. The SD card is mounted on the
user's Mac; read its file listing programmatically (names + modification
times) to pick files — don't eyeball thumbnails or replay Finder clicks. Reach
each outcome (batch identified, files attached, upload verified) with the most
reliable tool.

## Finding the SD card

The card mounts as an external volume — commonly named **Untitled**, **X5**, or
similar. It is always the SD card, **never a hard drive**. Photos live in the
`DCIM` tree (folders like `100MEDIA`, `101MEDIA`, `102MEDIA`, `Camera01`,
`DJI_001`…). The newest shoots are usually in the highest-numbered folder.

## Workflow

### 1. Get today's shoots from Aryeo

Open `https://hat-fella-productions-2.aryeo.com/admin/calendar`, go to
**today**, and under TEAM MEMBERS check **Marlon Mora** — Marlon is the default
photographer; only filter to a different name if the user asks for one.

Record each shoot's **time, address, and agent** (e.g. 9:00 AM, 2:30 PM,
4:30 PM). Times sometimes move around — if the card's capture times don't line
up sensibly with a scheduled slot, stop and ask the user "is this time
correct?" rather than guessing.

### 2. Open the order in Patrn

Go to `https://yourpatrn.com` → **Production board** and open the order card
for the shoot you're processing. Confirm it matches Aryeo: same **address**,
**shoot time**, **photographer** (Marlon Mora), and **agent**. The card also
lists the deliverables (e.g. 35 MLS Ready Photos, 5 Drone Images, Floor Plan)
— this tells you which media types the order needs.

Click **Upload files** to open the "Upload shoot files" dialog. Files go
straight into the order's Dropbox folder. The dialog auto-sorts: `DJI_####` →
Drone Photos, portrait-orientation shots → Vertical Photos, `.zip` → AutoHDR;
you can also target a specific tab (MLS Photos, Drone Photos, Floor Plan,
Vertical Edited).

### 3. Identify this shoot's files on the card

Sort the card's photo folder by modification time and find the run belonging
to this appointment. Rules learned the hard way:

- **Camera type**: `DJI_####` = drone; `IMG_####` (and other non-DJI camera
  prefixes) = MLS stills. Handle them as two separate batches.
- **Time window**: a shoot's files start around its appointment time and run
  until the next shoot's window. A 2:30 PM shoot's drone files stamped 2:42 PM
  *and* 3:59 PM can both belong to it — the drone is often flown more than
  once per property. Everything before the next appointment's run is this
  shoot.
- **Note the file-number range** for each batch (e.g. drone `DJI_0672` →
  `DJI_0737`, MLS `IMG_3074` → `IMG_3248`) — you'll re-select exactly this
  range in the upload dialog, so the endpoints are your ground truth.
- **1-hour clock offset**: the camera/SD clock is sometimes exactly one hour
  ahead or behind (DST / clock setting). If *every* file is shifted by the
  same hour but the batches still line up with the schedule in order, treat it
  as a clock issue, not a different shoot — and mention it to the user so the
  camera clock gets fixed.
- **Tagging convention**: the team marks each shoot's batch with a Finder
  color tag (e.g. red = the current shoot being processed) before uploading.
  If you can tag (or the user has tagged), use the tags as a cross-check
  against your number range.

When unsure whether a file belongs, confirm with the user — a wrong or missing
photo is a redo.

### 4. Upload each batch

In the Patrn upload dialog, attach the drone batch, then the MLS batch (use
`file_upload` with the exact file range off the card; auto-sort will route
DJI → Drone). Uploads keep running if the dialog is closed — the tray in the
corner shows progress — but **do not move on, close anything, or start the
next batch's selection until the current count finishes** (e.g. "58 files
still going" reaches 0 and the toast shows "66 files uploaded").

If the order needs a Floor Plan or other deliverables not on this card, note
them as still pending — don't mark anything complete that you didn't upload.

### 5. Verify

For each batch: the tab badge / uploaded count in Patrn must equal the number
of files in your selected range (range endpoints included). Nothing pending,
nothing errored. Only then report the shoot as uploaded, and repeat from step
2 for the day's remaining shoots.

## Quick reference

| Item | Value |
|------|-------|
| Patrn board | https://yourpatrn.com → Production board |
| Aryeo calendar | https://hat-fella-productions-2.aryeo.com/admin/calendar |
| Default photographer filter | Marlon Mora (unless told otherwise) |
| SD card | external volume ("Untitled"/"X5"…), `DCIM` tree — never a hard drive |
| Drone files | `DJI_####` → Drone Photos (auto-sorted) |
| MLS files | `IMG_####` and other non-DJI → MLS Photos |
| Right batch | files from appointment time until the next shoot's run; drone may have multiple flights |
| Clock quirk | uniform ±1 hour offset = SD clock issue, same shoot |
| Done when | uploaded count == files in range, none pending/failed |

## Common mistakes

- Grabbing a whole folder instead of the appointment's file-number range —
  pulls in other customers' shoots.
- Treating a second drone flight (later timestamp, same property) as a
  different shoot and leaving those files behind.
- Misreading a uniform 1-hour timestamp offset as "wrong shoot".
- Walking away mid-upload — the count must reach zero remaining before
  touching anything else.
- Calling it done at "uploading" instead of confirming the final count.

## Self-improvement

At the end of every run of this skill, before finishing, review:
- Did any step fail or need a workaround?
- Did the user correct or reject anything meaningful?
- Did you discover something a future run of this skill would need?

If (and only if) a change is meaningful, propose the specific edit to this SKILL.md to the user. Never edit the skill without the user's approval.
