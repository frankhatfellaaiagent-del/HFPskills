#!/usr/bin/env bash
# Validates the skill repository. Fails (exit 1) on any problem:
#   - a skill folder without a SKILL.md
#   - missing/empty name: or description: frontmatter
#   - duplicate skill names (by the frontmatter name value AND folder name)
#   - broken symlinks anywhere in the repo
#   - an outdated website catalog (docs/catalog.json)
# Also validates the marketplace and each plugin with `claude plugin validate`
# when the claude CLI is available.
set -Eeuo pipefail
cd "$(dirname "$0")/.."

errors=0
err() { echo "ERROR: $*" >&2; errors=$((errors+1)); }

# --- every skill folder has a SKILL.md with real frontmatter ---------------
for dir in plugins/*/skills/*/; do
  md="$dir/SKILL.md"
  if [ ! -f "$md" ]; then err "$dir has no SKILL.md"; continue; fi
  name="$(sed -n 's/^name:[[:space:]]*//p' "$md" | head -1)"
  desc="$(sed -n 's/^description:[[:space:]]*//p' "$md" | head -1)"
  [ -n "$name" ] || err "$md: missing or empty name:"
  [ -n "$desc" ] || err "$md: missing or empty description:"
done

# --- duplicate names (frontmatter values and folder names) -----------------
dupes="$(sed -n 's/^name:[[:space:]]*//p' plugins/*/skills/*/SKILL.md 2>/dev/null | sort | uniq -d)"
[ -z "$dupes" ] || err "duplicate frontmatter skill name(s): $dupes"
fdupes="$(for d in plugins/*/skills/*/; do basename "$d"; done | sort | uniq -d)"
[ -z "$fdupes" ] || err "duplicate skill folder name(s): $fdupes"

# --- broken symlinks in the repo -------------------------------------------
broken="$(find . -path ./.git -prune -o -type l ! -exec test -e {} \; -print | grep -v '^\./\.git' || true)"
[ -z "$broken" ] || err "broken symlink(s) in the repo: $broken"

# --- website catalog freshness ---------------------------------------------
if ! bash scripts/generate-catalog.sh --check >/dev/null; then
  err "docs/catalog.json no longer matches the repository (run scripts/generate-catalog.sh)"
fi

# --- claude plugin validation (marketplace + each plugin individually) -----
if command -v claude >/dev/null 2>&1; then
  if ! claude plugin validate . >/dev/null 2>&1; then err "claude plugin validate . failed"; fi
  for p in plugins/*/; do
    if ! claude plugin validate "$p" >/dev/null 2>&1; then err "claude plugin validate $p failed"; fi
  done
else
  echo "note: claude CLI not available — skipped plugin manifest validation"
fi

if [ "$errors" -gt 0 ]; then
  echo "validate-skills: $errors problem(s) found." >&2
  exit 1
fi
echo "validate-skills: all checks passed."
