# Team test checklist — real-employee onboarding test

Purpose: prove a non-technical Hat Fella team member can install and use the
skills **without developer help**. Until someone who did *not* build this
system completes every step below, the non-technical onboarding is
**not considered validated**.

Pick a teammate who has never seen this repo. Sit back and watch — help only
if they are fully stuck, and write down every place they hesitated.

Tester: ______________  Date: ______________  Mac model/OS: ______________

- [ ] 1. **Open the setup website** from a link you sent them
      (https://frankhatfellaaiagent-del.github.io/HFPskills/). They can tell
      you what the page is for without explanation.
- [ ] 2. **Copy the command** using the "Copy Installer" button, and see the
      "Copied" confirmation.
- [ ] 3. **Install the skills**: they open Terminal themselves (the site
      explains how), paste, press Enter, and the installer finishes with the
      success message showing the number of skills and the version.
      - If the Apple developer-tools popup appears: they resolve it using
        only the website's troubleshooting section.
- [ ] 4. **Restart Codex** because the final message told them to.
- [ ] 5. **Find and use a skill**: they ask Codex to do a real task (e.g.
      "check Quo" or "deliver yesterday's shoots") and the matching Hat
      Fella skill runs.
- [ ] 6. **Run the update**: they re-run the same command from the website
      and it completes with "up to date".
- [ ] 7. **Understand an error without help**: have them re-run the install
      after you add a junk file to `~/HFPskills` (simulates "local
      changes"). They read the error message and can say in their own words
      what it means and what to do — without asking a developer.

## Record the results

- Steps that needed help: ______________________________________________
- Confusing wording (site, installer, or error messages): ______________
- Time from opening the site to first successful skill run: ____________

File fixes for anything that failed, then re-run the failed steps with the
same tester. Only mark onboarding validated when all seven boxes pass
without developer intervention.
