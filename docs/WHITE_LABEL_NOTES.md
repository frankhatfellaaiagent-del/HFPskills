# White-label notes (internal)

Hat Fella is the first customer of this "company SOPs → AI skills" setup.
The site and installer are deliberately structured so a second company is a
copy-and-edit job, not a rebuild. To stand this up for another company:

1. **Repository**: create their own skills repo (same layout: `.claude-plugin/marketplace.json`, `plugins/<dept>/skills/<skill>/SKILL.md`). Everything below points at it.
2. **Branding**: edit `docs/config.js` (company name, title, tagline, description, logo, support contact) and the color tokens at the top of `docs/styles.css`. Drop a real logo into `docs/assets/` and swap `logoText` for an image if desired.
3. **Installer**: `install.sh` defaults (repo URL, install dir name) are at the top of the file — change the two defaults, keep the rest. The env-var overrides already make it testable.
4. **Installer URL / install command**: update `installCommand` and `installerUrl` in `docs/config.js` and the README one-liner to the new repo's raw URL.
5. **Skill catalog**: run `scripts/generate-catalog.sh` in their repo — the site reads `docs/catalog.json`, nothing is hardcoded in HTML.
6. **Support contact**: `supportContact` in `docs/config.js`.
7. **Private repositories**: the curl one-liner only works while the repo is public. For a private repo, distribute via official GitHub auth (collaborator invite + `gh auth login` or a git credential helper) or host the installer behind a company-controlled download. Never embed tokens in URLs, the website JavaScript, or the installer.
8. **Custom domain**: GitHub Pages → add a CNAME (Settings → Pages → Custom domain); the site is static so nothing else changes.

Out of scope on purpose (do not add without a real need): multi-company SaaS,
billing, dashboards, logins, credential collection of any kind.
