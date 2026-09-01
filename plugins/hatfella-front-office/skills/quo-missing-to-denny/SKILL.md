---
name: quo-missing-to-denny
description: "Run the Quo (my.quo.com) inbox triage for Hat Fella — sweep every inbox under Open and Done plus Calls, find everything unanswered or unhandled, then WhatsApp Denny what's missing. Use for \"send Denny what's missing\", \"Quo check for Denny\", \"alert Denny\", or similar recurring Quo gap-report requests."
---

# Quo Missing-Items → Denny (WhatsApp)

A fixed, four-step pipeline: triage the Quo inbox for anything a human hasn't
handled, compile the gaps into one report, and send it to Denny on WhatsApp.
The steps and their done-rules are pre-baked and do not change between runs —
only the toggle below changes how the run behaves.

## ⚙️ Loop Training Mode — TOGGLE

```
LOOP TRAINING MODE: ON
```

Flip the word `ON`/`OFF` above to change how this skill runs. Read it fresh
every time this skill is invoked — do not assume last run's setting.

- **ON** (default): pause after every step and wait for the user's explicit
  go-ahead before starting the next one. Before running a step, check its
  done-rule first — if it already passes, skip the step (say so) and move on
  without pausing on it. Only steps that actually ran and failed get retried.
  Retries are capped (see below); never loop a step forever.
- **OFF**: run all four steps back-to-back with no pauses for approval. Still
  check each step's done-rule before running it (skip if already passing) and
  still enforce the retry cap. Report the end state once, at the finish.

**Retry cap: 3 attempts per step**, ON or OFF. If a step still fails its
done-rule after 3 attempts, stop the run and tell the user exactly which step
and why — do not silently mark it done, and do not keep retrying past the cap.

**Exception — Step 4 always runs.** "Stop the run" never means skipping the
WhatsApp message. No matter what failed upstream — Quo wouldn't load, an inbox
couldn't be swept, a step blew its retry cap — always send Denny a WhatsApp
with whatever the run did establish, plus a plain statement of what failed and
what is therefore unchecked. A partial report beats silence. Send it even if
the report is only "the Quo check could not complete — here is how far it
got." Step 4 is the last thing the run does, always.

## Browser

Use **Claude in Chrome** (the user's real, already-logged-in Chrome), not the
sandboxed in-app Browser pane — Chrome rides the existing Quo session, so no
credentials are needed. Call `tabs_context_mcp` first, then navigate to
https://my.quo.com. Never use host-level clicks.

## Goal

Denny has, on WhatsApp, a correct list of everything in Quo that's missing a
human response: unanswered client/partner messages (with a suggested reply
each), missed calls and voicemails with pending next steps, and junk flagged
for deletion. Nothing is ever sent to a client and nothing is deleted — this
run only reads Quo and messages Denny.

## Skill-level done-rule (the Verification)

A WhatsApp message containing the report shows as **sent** to the contact
**"Denny"** — exact name match; if the search returns several Dennys or none,
stop and ask the user which contact, don't guess. The message goes out **no
matter what** — it is never conditional on earlier steps passing. If WhatsApp
is genuinely unreachable after the retry cap on Step 4 (no channel connected,
contact not found), the run ends with that reported explicitly to the user as
a gap — never treated as equivalent to "done."

## Steps

Each step: what to do, and the done-rule that lets it be skipped on a rerun.

**1. Open Quo and enumerate the inboxes**
Action: open https://my.quo.com in Chrome. Read the inbox list from the left
sidebar rather than assuming — typically Customer Service, Admin Customer
Service, Client Notifications, Photographers, Backup.
Done-rule: the sidebar's inbox list is recorded for this run.

**2. Sweep every inbox — Open AND Done, plus Calls**
Action: in each inbox, sweep the conversation list under **both** the "Open"
and "Done" filters (a conversation marked Done can still hold an unanswered
client message), and open the **Calls** tab for missed calls and voicemails.
Open each conversation and read the last few messages (get_page_text /
read_page — faster than screenshots). Classify each as:
- **Automation/system noise** — OTPs, vendor blasts, Hat Fella's own delivery
  confirmations. Skip.
- **Spam/ads** — anything ending "Reply STOP", cold marketing. Flag for
  deletion; do NOT delete.
- **Needs a reply** — last message is from a client or partner and nobody
  from Hat Fella responded, including conversations closed Done unanswered.
- **Calls/voicemails** — read the AI call summary; note pending next steps.
When unsure, include it — a false positive costs seconds, a missed client
costs a job.
Done-rule: every inbox has been swept under both filters plus Calls, and
every conversation has a recorded classification or a recorded "clean."

**3. Compile the "what's missing" report**
Action: one report, gaps only, grouped by inbox:
1. **Unanswered** — per conversation: contact, inbox, last-message date, a
   one-line gist, and a suggested reply (Spanish if they wrote in Spanish,
   English otherwise; friendly, brief, first-name house tone).
2. **Missed calls / voicemails** with pending next steps.
3. **Delete candidates** — spam to clear, listed for a human to action.
If nothing is missing, the report says so explicitly — never leave it
ambiguous whether Quo was actually checked. Drafted replies live only in the
report; never type them into Quo.
Done-rule: report text is finalized and covers every inbox from Step 1.

**4. Send WhatsApp to Denny — ALWAYS, no matter what**
Action: send the report (condensed is fine) to the contact **"Denny"** via
whichever WhatsApp channel is available — WhatsApp MCP/Zapier action first,
then WhatsApp Web in Chrome, then the WhatsApp desktop app.
This step is unconditional: run it even when an earlier step blew its retry
cap or the sweep is incomplete — send what the run did establish and say
plainly what's unchecked.
Formatting on WhatsApp Web: the composer sends on Enter, so type each line
and press **Shift+Enter** between lines; one message only — never send a
second "cleaner" copy.
Done-rule: the message is confirmed sent to "Denny".

## Quick reference

| Item | Value |
|---|---|
| Quo | https://my.quo.com (Claude in Chrome, already logged in) |
| Sweep scope | every inbox × {Open, Done} filters + Calls tab |
| Never | send messages in Quo, delete conversations |
| Report sections | Unanswered (+ suggested replies) / Missed calls / Delete candidates |
| WhatsApp to | contact "Denny" (exact name; ask if ambiguous) |
| WhatsApp rule | **always send, no matter what** — never gated on earlier steps |
| Retry cap | 3 attempts per step (Step 4 still runs after any failure) |
| Loop Training Mode default | ON |
## Self-improvement

At the end of every run of this skill, before finishing, review:
- Did any step fail or need a workaround?
- Did the user correct or reject anything meaningful?
- Did you discover something a future run of this skill would need?

If (and only if) a change is meaningful, propose the specific edit to this SKILL.md to the user. Never edit the skill without the user's approval.
