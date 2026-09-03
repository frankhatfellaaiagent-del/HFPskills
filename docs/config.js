// All company-specific values for the setup website live here.
// To white-label this site for another company, change this file
// (and the brand colors in styles.css) — see WHITE_LABEL_NOTES.md.
window.HFP_CONFIG = {
  companyName: "Hat Fella Productions",
  siteTitle: "Install Hat Fella AI Skills",
  tagline: "Install Hat Fella’s approved workflows inside Claude Code or Codex.",
  description:
    "Hat Fella skills are step-by-step playbooks that teach Claude and Codex " +
    "exactly how we book shoots, upload media, deliver listings, run payroll, " +
    "and more — so everyone gets the same result, every time.",
  logoText: "\u{1F3A9}", // top-hat mark; replace with an <img> path in assets/ when a logo file exists
  repo: "frankhatfellaaiagent-del/HFPskills",
  repoUrl: "https://github.com/frankhatfellaaiagent-del/HFPskills",
  installerUrl:
    "https://github.com/frankhatfellaaiagent-del/HFPskills/blob/main/install.sh",
  installCommand:
    "curl -fsSL https://raw.githubusercontent.com/frankhatfellaaiagent-del/HFPskills/main/install.sh | bash",
  claudeMarketplace: "frankhatfellaaiagent-del/HFPskills",
  supportContact: "hatfellaproductions@gmail.com",
};
