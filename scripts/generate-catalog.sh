#!/usr/bin/env bash
# Generates docs/catalog.json from the repository's plugin and skill
# metadata (SKILL.md frontmatter: name + description). Run after adding or
# editing skills, then commit the result.
#
#   scripts/generate-catalog.sh          # (re)write docs/catalog.json
#   scripts/generate-catalog.sh --check  # fail if docs/catalog.json is outdated
set -Eeuo pipefail
cd "$(dirname "$0")/.."

MODE="write"
if [ "${1:-}" = "--check" ]; then MODE="check"; fi

OUT="docs/catalog.json"
if [ "$MODE" = "check" ]; then
  OUT="$(mktemp)"
  trap 'rm -f "$OUT"' EXIT
fi

OUT="$OUT" python3 - <<'PY'
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

out = os.environ["OUT"]
with open(out, "w") as f:
    json.dump(catalog, f, indent=2)
total = sum(len(p["skills"]) for p in catalog["plugins"])
print(f"{out}: {len(catalog['plugins'])} plugins, {total} skills")
PY

if [ "$MODE" = "check" ]; then
  if ! diff -q "$OUT" docs/catalog.json >/dev/null 2>&1; then
    echo "ERROR: docs/catalog.json is outdated. Run scripts/generate-catalog.sh and commit the result." >&2
    exit 1
  fi
  echo "docs/catalog.json is up to date."
fi
