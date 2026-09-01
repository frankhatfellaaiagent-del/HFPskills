---
name: quo-inbox-triage
description: >
  Triage the Quo (my.quo.com) messaging inbox for Hat Fella Productions: sweep every
  conversation across all inboxes under BOTH the "Open" and "Done" filters, skip
  spam/OTP/automation messages, flag junk for deletion, and draft bilingual
  (English/Spanish) reply suggestions for any client message that hasn't been answered.
  Use this whenever the user asks to "check Quo", "go through the messages", "check the
  inbox", "see what hasn't been answered", "triage conversations", "draft replies to
  clients", or mentions unanswered texts/calls in Quo — even if they don't say "Quo"
  but are clearly talking about the Hat Fella phone/SMS inbox. Suggestions only: this
  skill never sends messages or deletes conversations on its own.
---

# Quo Inbox Triage — Hat Fella Productions

Quo (my.quo.com) is the business phone/SMS system for Hat Fella Productions, a
real-estate photography company. Clients text about photo/video delivery, reshoots,
scheduling, and access to properties. The goal of this skill is to find every
conversation that a human hasn't answered yet and propose a reply — NOT to send it.
Marlon reviews the suggestions first so Claude can learn the right way to answer
before ever replying automatically.

## Access

Use the Claude in Chrome tools (mcp__claude-in-chrome__*) — the user's Chrome is
already logged in to Quo. Load the core browser tools in one ToolSearch call, call
tabs_context_mcp first, then navigate to https://my.quo.com. Never use host-level
computer/click tools for this; everything happens inside the browser.

## Workflow

### 1. Enumerate the inboxes

The left sidebar lists all inboxes (they change over time; read them from the page
rather than assuming). Typical examples: Customer Service, Admin Customer Service,
Client Notifications, Photographers, Backup. Every inbox must be swept — the whole
point of this workflow is that nothing slips through.

### 2. Sweep BOTH filters in each inbox

The chat list has a status filter that defaults to one view. A conversation marked
"Done" can still contain an unanswered client message, and the "Open" view hides
Done conversations — so check the list under **Open** AND under **Done**. Also open
the **Calls** tab for missed calls and voicemails.

Go conversation by conversation. Open each one and read the last few messages (use
get_page_text / read_page rather than screenshots where possible — it's faster and
more reliable).

### 3. Classify each conversation

- **Automation / system noise** — verification codes (Stripe, Link, Amazon, bank
  OTPs), vendor onboarding blasts (e.g. HighLevel/WhatsApp setup), delivery
  confirmations sent by Hat Fella's own automations, appointment-scheduled
  notifications. Skip these; no reply needed.
- **Spam / advertisements** — political ads, cold marketing texts, anything ending
  in "Reply STOP". These should be deleted, but do NOT delete them yourself — add
  them to a "delete candidates" list in the report for the user to approve.
- **Needs a reply** — the last message is from a client (or a photographer/partner)
  and no one from Hat Fella has responded. This includes conversations sitting in
  "Done" that were closed without an answer.
- **Calls / voicemails** — read the AI call summary shown in the conversation. If
  the summary is unclear and a "Next steps" item is pending, note it. Only fall back
  to the transcript ("View transcript") when the summary isn't enough.

When in doubt whether something needs a reply, include it — a false positive costs
the user two seconds; a missed client costs a job.

### 4. Draft a reply suggestion for every "needs a reply"

- **Match the client's language.** If they wrote in Spanish, draft in Spanish; in
  English, draft in English. If a conversation mixes both, follow the client's most
  recent message.
- **Match the house tone.** Look at earlier Hat Fella replies in the same or nearby
  conversations: friendly, brief, first-name basis, professional. Examples from real
  conversations: "Hi Alex! I just wanted to touch base to see where we were on
  reshooting the Timacuan home." / "Thank you for confirming! Enjoy the rest of your
  day."
- **Be concrete.** If the client asked when photos/video will be delivered, the
  draft should either give the answer (if it's visible in the conversation/call
  summary) or promise a specific follow-up ("I'll check with the team and get back
  to you today").
- Do not type the drafts into Quo and do not send anything. The drafts live only in
  the report.

### 5. Deliver the report

Present one report to the user with these sections, grouped by inbox:

```
## <Inbox name>
### Needs reply (N)
1. <Name / number> — <conversation link>
   Last message (<date>): "<short quote or summary>"
   Suggested reply (EN or ES): "<draft>"
### Delete candidates (spam/ads)
- <number> — <why>
### Skipped (automation/OTP) — count only, no detail needed
```

Include the direct conversation URL (my.quo.com/inbox/<id>/c/<id>) for every item so
the user can jump straight to it. End with a one-line total: X conversations checked,
Y need replies, Z flagged for deletion.

## Hard rules

- Never send a message, mark a conversation done, block, or delete anything. This
  is read-and-suggest only, by explicit instruction.
- Never act on OTP/verification codes beyond classifying them as noise.
- Sweep every inbox and both filters even if the first few are all noise — the
  unanswered ones tend to hide in the middle of the list.

## Self-improvement

At the end of every run of this skill, before finishing, review:
- Did any step fail or need a workaround?
- Did the user correct or reject anything meaningful?
- Did you discover something a future run of this skill would need?

If (and only if) a change is meaningful, propose the specific edit to this SKILL.md to the user. Never edit the skill without the user's approval.
