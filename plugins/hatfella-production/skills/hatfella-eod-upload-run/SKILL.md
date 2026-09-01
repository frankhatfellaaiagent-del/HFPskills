---
name: hatfella-eod-upload-run
description: "End-of-night run of the Hat Fella upload check — walk every shoot on today's Patrn list, verify photographer media came in (Dropbox MLS/drone, CubiCasa floor plan, Zillow 3D), tick verified deliverables on Patrn, and WhatsApp photographers about confirmed-missing items. Use for \"run the end of night upload check\", \"close out today's shoots\", or similar nightly upload-run requests."
---

# Hat Fella — EOD Upload Run

A fixed, six-step pipeline: pull today's shoot list from Patrn, verify each
shoot's incoming media, tick what's verified, WhatsApp photographers about
what's confirmed missing, then report. The steps and their done-rules are
pre-baked and do not change between runs — only the toggle below changes how
the run behaves.

This checks media coming **in** from photographers. It is not the Aryeo
customer-delivery QC (`hatfella-delivery-qc`) — that checks what went **out**.

## ⚙️ Loop Training Mode — TOGGLE

```
LOOP TRAINING MODE: OFF
```

Flip the word `ON`/`OFF` above to change how this skill runs. Read it fresh
every time this skill is invoked — do not assume last run's setting.

- **ON** (default): pause at every step and wait for the user's explicit
  approval before continuing. Before running a step, check its done-rule
  first — if it already passes, skip the step (say so) and move on without
  pausing on it. Only re-run steps that actually failed their done-rule.
- **OFF**: run all steps back-to-back with no pauses. Still check each step's
  done-rule before running it (skip if already passing) and still enforce
  the retry cap. Report the end state once, at the finish.

**Retry cap: 3 attempts per step**, ON or OFF — it can never loop forever.
If a step still fails its done-rule after 3 attempts, stop the run and tell
the user exactly which step and why. Never silently mark a step done.

## Browser

Use **Claude in Chrome** (the user's real, already-logged-in Chrome), not the
sandboxed in-app Browser pane — Patrn, Dropbox, CubiCasa, Zillow, and
WhatsApp Web all ride the existing cookie session. Prefer reading page text
(`read_page` / `get_page_text`) over eyeballing screenshots — file lists and
order tables are text. If a site shows a login wall (Dropbox sessions
expire), pause and ask the user to log back in — never enter credentials —
then retry the step. To count a Dropbox folder, use the file list's
"Select all" header checkbox and read the "N selected" toolbar count.

## Goal

Every shoot on today's Patrn list is either **verified** (all package
deliverables confirmed present and ticked on the card) or **escalated** (the
missing items named and the shoot's photographer messaged on WhatsApp
tonight, not tomorrow) — and the user has one report saying which is which.

## Skill-level done-rule (the Verification)

All three are true:
1. Every card on Patrn's Today's-shoots list was opened and checked — none
   skipped.
2. Every deliverable ticked on a Patrn card has recorded evidence (a count
   or a sighting); nothing ticked "because the folder exists."
3. Every shoot with confirmed-missing media has a WhatsApp message sent to
   its photographer (or an explicit flag to the user when messaging wasn't
   possible), and the final report lists every shoot as verified/escalated.

## Steps

Each step: what to do, and the done-rule that lets it be skipped on a rerun.

**1. Pull today's shoot list**
Action: open `https://yourpatrn.com` → Dashboard → **Today's shoots**. For
each card record: address, photographer, and the **Deliverables** checklist
(that list defines exactly what Steps 2–3 verify for that shoot — packages
differ). Skip cards whose status is Cancelled (note them in the report).
**Open a card by clicking the customer name** — clicking the address opens
Apple Maps in a new tab instead of the card detail.
Done-rule: every card on the list is recorded with address, photographer,
and deliverables; the count of shoots for tonight is stated.

**2. Verify photos in Dropbox (per shoot)**
Action: from the card, **Open in Dropbox** — folder is
`Hat Fella Production Team Folder/Upload/<YYYY-MM-DD>/<Agent>/<Address>/`.
- **MLS Photos**: raws are bracketed exposures — divide by the
  photographer's bracket size: **Andrew Ferrandiz ÷ 5** (`IMG_####`,
  `6Y8A####`), **Steven Forbes ÷ 3** (`SFF####.JPG`), anyone else ÷ 5
  until calibrated (confirmed by Marlon, 2026-08-24). Test:
  **raw count ÷ bracket ≥ package MLS count**.
- **Drone Photos**: count as-is, no division (`DJI_####` ≥ package drone
  count).
- **AI Walk-through Video** (when in the package): the order folder must
  contain a **Vertical Photos** folder with files in it — that's the input;
  absent/empty = missing media.
Done-rule: every shoot has recorded pass/fail counts for each Dropbox-side
deliverable in its package.

**3. Verify floor plan and Zillow 3D (per shoot)**
Action:
- **Floor Plan**: `https://app.cubi.casa` → Order History → search the
  address. An order existing = pass — **Pending counts** (submitted and
  processing). No order = missing. ⚠️ The search box ignores
  programmatically-set values — click it and send **real keystrokes**.
  Before trusting any "not found", prove the search works by searching an
  order you know exists (e.g. one from the dashboard's Recent Orders).
- **Zillow 3D Tour** (when in the package):
  `https://www.zillow.com/my-3d-homes/` → find the address with the 3D tour
  **READY** (Floor plan READY/POSTED alongside is normal). Not listed =
  missing.
Done-rule: every shoot has a recorded pass/missing for Floor Plan, and for
Zillow 3D when the package includes it.

**4. Tick verified deliverables in Patrn**
Action: on each shoot's card, tick exactly the deliverables that passed in
Steps 2–3. Ticks mean "verified present" — leave anything missing or
unverifiable **unticked** (a WhatsApp reminder is not a tick).
Done-rule: every passed deliverable is ticked; every failed or unverified
one is unticked; no card has ticks without recorded evidence.

**5. WhatsApp photographers about confirmed-missing media**
Action: for each shoot with missing items, open `https://web.whatsapp.com`,
search the photographer by **exact name** from the card, and send —
adapted to what's missing. Known contact names (confirmed by Marlon,
2026-08-24): Steven Forbes = **"Steven REP Forbes"**, Andrew Ferrandiz =
**"Andrew Videographer"** — both in the HFP Photographers group; a contact
being in that group is good corroboration for a new photographer.
- Everything: `All media is missing for <address>. Please upload as soon as
  you can. Thank you.`
- One item: name it, e.g. `Drone photos are missing for <address>. Please
  upload as soon as you can. Thank you.`
One message per shoot; don't send a second "cleaner" copy. WhatsApp Web
sends on Enter — Shift+Enter for line breaks.
Guardrails: **only message about confirmed-missing media** — if a check
itself failed (page wouldn't load, folder unreadable), that's a run failure
to report to the user, never a reason to ping a photographer. Exact contact
match only — no lookalikes; no match = skip and flag to the user. If the
photographer is the user themself, flag it instead of messaging.
Done-rule: every missing-media shoot has either a sent message confirmed in
the chat, or an explicit user-facing flag explaining why not.

**6. Report**
Action: one summary, per shoot: **verified** (which deliverables ticked) or
**escalated** (what's missing, who was messaged). Call out anything the run
could not check and why. If the night is fully clean, say so explicitly —
"all N shoots verified" — so the user knows every card was checked, not
skipped.
Done-rule: the report covers every shoot from Step 1 and states each one's
end state.

## Quick reference

| Item | Value |
|---|---|
| Shoot list | https://yourpatrn.com → Dashboard → Today's shoots |
| Dropbox path | Team Folder/Upload/`<date>`/`<agent>`/`<address>`/ |
| MLS test | raw count ÷ bracket ≥ package MLS count (Andrew ÷5, Steven ÷3, default ÷5) |
| Drone test | `DJI_####` count ≥ package drone count (no division) |
| Floor plan | app.cubi.casa → Order History → address; **Pending = OK** |
| Zillow 3D | zillow.com/my-3d-homes → address listed, 3D tour READY |
| AI Walk-through | Dropbox folder has "Vertical Photos" with files |
| Tick rule | tick only verified-present; reminders are not ticks |
| WhatsApp | web.whatsapp.com → one message per shoot; Steven = "Steven REP Forbes", Andrew = "Andrew Videographer" |
| Message trigger | confirmed-missing media only — never tool failures |
| Retry cap | 3 attempts per step |
| Loop Training Mode | OFF since 2026-08-24 (flip the toggle at the top to retrain) |
## Self-improvement

At the end of every run of this skill, before finishing, review:
- Did any step fail or need a workaround?
- Did the user correct or reject anything meaningful?
- Did you discover something a future run of this skill would need?

If (and only if) a change is meaningful, propose the specific edit to this SKILL.md to the user. Never edit the skill without the user's approval.
