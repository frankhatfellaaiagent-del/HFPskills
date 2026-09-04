# Security checklist

## Never commit to this repository

This repository is **public**. Before every commit, confirm none of the
following is in the diff:

- [ ] Passwords of any kind
- [ ] API keys or tokens (GitHub, Stripe, Aryeo, any `ghp_…`, `sk-…`, `AKIA…` string)
- [ ] Customer information (names tied to orders, addresses, contact details)
- [ ] Private client lists or exports
- [ ] Internal credentials (logins, session cookies, connection strings)
- [ ] Sensitive pricing or financial information (payroll amounts, margins, contract terms)

Skill files describe *how* to do a task; anything a skill needs to log in
with belongs in the tool doing the login (a connector, a credential
manager), never in a SKILL.md.

Run a secret scan before shipping changes (see Development in the README).

## Public vs. private

Running public is a convenience trade-off for easy installs. The
**commercial version of this system should use a private repository** with
official GitHub authentication (collaborator invites + `gh auth login` or a
git credential helper) — never tokens embedded in URLs, website JavaScript,
or the installer. When this repo goes private, the public curl one-liner
stops working; the README documents the switch.

## Recommended GitHub protections for `main`

Set in GitHub → Settings → Branches → Add branch ruleset for `main`:

- [ ] Require a pull request before merging
- [ ] Block force pushes
- [ ] Restrict branch deletion
- [ ] Require two-factor authentication for every account with write access
      (GitHub → account Settings → Password and authentication)
- [ ] Tag a known-good version before every major update so there is always
      a tested commit to roll back to. **Tag `main` after the change merges**
      — never a feature-branch commit, because a squash merge creates a new
      commit on `main` and the feature-branch commit is not the production
      code. Exact UI steps:
      1. Merge the PR into `main`.
      2. Repo → **Releases** (right sidebar) → **Draft a new release**.
      3. Click **Choose a tag**, type the new tag (e.g. `v1.0.0`), select
         **Create new tag on publish**, and set **Target: main**.
      4. Title it (e.g. "v1.0.0 — installer + setup site"), click
         **Publish release**. The tag now points at the merged `main` commit.

## Rollback

Every install records the exact commit in its manifest
(`~/.agents/skills/.hatfella-managed-skills`), and the installer prints the
short version on every run. To roll the whole team back after a bad update:

```bash
git revert <bad-commit>   # on main — creates a new commit undoing the bad one
git push
```

Everyone gets the rollback the next time they update (Claude Code
auto-update, or re-running the installer for Codex). Reverting is preferred
over force-pushing old history — force pushes should be blocked on `main`.
