#!/usr/bin/env bash
# Regenerates docs/catalog.json from the repository's plugin and skill
# metadata. Run this after adding or renaming skills, then commit the result.
set -Eeuo pipefail
cd "$(dirname "$0")/.."

python3 - <<'PY'
import json, os, re, glob

catalog = {"plugins": []}
for pj_path in sorted(glob.glob("plugins/*/.claude-plugin/plugin.json")):
    plugin_dir = os.path.dirname(os.path.dirname(pj_path))
    with open(pj_path) as f:
        pj = json.load(f)
    skills = []
    for sk in sorted(glob.glob(os.path.join(plugin_dir, "skills", "*", "SKILL.md"))):
        with open(sk) as f:
            text = f.read()
        m = re.search(r"^---\n(.*?)\n---", text, re.S)
        front = m.group(1) if m else ""
        name = re.search(r"^name:\s*(.+)$", front, re.M)
        desc = re.search(r"^description:\s*(.+)$", front, re.M)
        d = desc.group(1).strip().strip('"\'' ) if desc else ""
        # First sentence only, keep it human-sized for the website card.
        first = re.split(r"(?<=[.!?])\s", d)[0][:220]
        skills.append({
            "name": name.group(1).strip() if name else os.path.basename(os.path.dirname(sk)),
            "summary": first,
        })
    catalog["plugins"].append({
        "name": pj["name"],
        "description": pj.get("description", ""),
        "skills": skills,
    })

os.makedirs("docs", exist_ok=True)
with open("docs/catalog.json", "w") as f:
    json.dump(catalog, f, indent=2)
total = sum(len(p["skills"]) for p in catalog["plugins"])
print(f"docs/catalog.json written: {len(catalog['plugins'])} plugins, {total} skills")
PY
