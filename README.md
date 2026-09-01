# Hat Fella Productions — Team Skills

This repo is the **single source of truth** for Hat Fella Productions' AI skills (SOPs for Claude). Every workflow the team runs through Claude lives here, packaged as installable plugins. The company owns the skills, git history gives rollback, and one edit here reaches everyone with auto-update enabled.

## Install (Claude Code)

1. Open Claude Code and run `/plugin`
2. Go to **Marketplaces → Add marketplace** and enter:
   ```
   frankhatfellaaiagent-del/HFPskills
   ```
3. Back in the plugin menu, install the plugin(s) for your role (see below)
4. **Enable auto-update** for the marketplace — required so skill edits reach you automatically

The same repo also works as a plugin in Codex.

## Plugins

Install only what your role needs.

### hatfella-production
| Skill | What it does |
|---|---|
| `hatfella-shoot-upload` | Upload SD-card photos to the correct shoot order in Patrn, cross-referencing Aryeo |
| `hatfella-eod-upload-check` | End-of-night check that every shoot's media was uploaded (Dropbox, CubiCasa, Zillow 3D) |
| `hatfella-eod-upload-run` | End-of-night run: verify uploads, tick Patrn deliverables, WhatsApp photographers about missing items |
| `hatfella-missing-items-alert` | 72-hour missing-media audit across Hat Rack + Aryeo, report to Fabian by email and WhatsApp |
| `hatfella-delivery-run` | Daily delivery of yesterday's shoots in Aryeo, chasing missing media and applying discounts |
| `hatfella-delivery-qc` | After-the-fact delivery audit against each appointment's package, QC report to Fabian |
| `aryeo-cubicasa-floorplan-sync` | Attach CubiCasa floor plans to the right Aryeo listings |

### hatfella-media-editing
| Skill | What it does |
|---|---|
| `aryeo-virtual-staging` | AI virtual staging on empty-room photos in Aryeo, QC every variant, re-deliver |
| `autohdr-declutter` | AutoHDR declutter / object-removal edits, add to the listing, re-deliver |

### hatfella-front-office
| Skill | What it does |
|---|---|
| `aryeo-book-appointment` | Book a shoot in Aryeo: listing + order + customer + package + appointment |
| `quo-inbox-triage` | Sweep the Quo inbox, flag junk, draft bilingual replies for unanswered clients |
| `quo-missing-to-denny` | Quo sweep (Open, Done, Calls) and WhatsApp Denny everything unhandled |

### hatfella-admin
| Skill | What it does |
|---|---|
| `aryeo-payroll-run` | Bi-monthly photographer payroll: verify pay run items, build draft pay runs |
| `top-hat-club-sync` | Apply Top Hat Club pricing in Aryeo for new Stripe club members |
| `top-hat-club-eod-sync` | End-of-day sweep: every active Stripe club subscriber has club pricing in Aryeo |

## Updating a skill

1. Edit the skill's `SKILL.md` under `plugins/<plugin>/skills/<skill>/`
2. Commit and push (or open a PR)
3. Everyone with auto-update enabled receives the change automatically

If an edit breaks a skill, git history is the rollback — revert the commit and push.

Every skill ends with a **Self-improvement** section: after each run, Claude reviews what failed or was corrected and proposes an edit to the skill, so the whole team's process keeps getting better.

## Adding a new skill

Create `plugins/<plugin>/skills/<new-skill-name>/SKILL.md` with YAML frontmatter (`name`, `description`) followed by the step-by-step SOP. Skills inside a plugin's `skills/` folder are auto-discovered — no registration needed. Add a row to the table above, commit, push.
