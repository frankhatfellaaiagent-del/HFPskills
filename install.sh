#!/usr/bin/env bash
#
# Hat Fella Productions — team skills installer for Codex.
#
# Installs (or updates) the Hat Fella skill library on this computer and
# links every skill into Codex's user skills folder. Safe to run again at
# any time: running it again IS the update.
#
#   curl -fsSL https://raw.githubusercontent.com/frankhatfellaaiagent-del/HFPskills/main/install.sh | bash
#
# It never uses sudo, never asks for a GitHub password, and only manages
# the links it created itself (tracked in a manifest file). Your own
# personal skills are never touched.
#
# Overridable for testing:
#   HFP_REPO_URL     git URL to install from   (default: public Hat Fella repo)
#   HFP_REPO_BRANCH  branch to track           (default: main)
#   HFP_REPO_DIR     where the repo is cloned  (default: ~/HFPskills)
#   HFP_SKILLS_DIR   Codex skills folder       (default: ~/.agents/skills)
#   HFP_LEGACY_CODEX_LINKS=1  also link into ~/.codex/skills for older Codex
#                             versions (off by default to avoid duplicate
#                             skills in versions that scan both folders)

set -Eeuo pipefail

REPO_URL="${HFP_REPO_URL:-https://github.com/frankhatfellaaiagent-del/HFPskills.git}"
REPO_BRANCH="${HFP_REPO_BRANCH:-main}"
REPO_DIR="${HFP_REPO_DIR:-$HOME/HFPskills}"
SKILLS_DIR="${HFP_SKILLS_DIR:-$HOME/.agents/skills}"
LEGACY_DIR="${HFP_LEGACY_SKILLS_DIR:-$HOME/.codex/skills}"
MANIFEST_NAME=".hatfella-managed-skills"

say()  { printf '%s\n' "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------- git check
if ! command -v git >/dev/null 2>&1; then
  if [ "$(uname -s)" = "Darwin" ]; then
    fail "git is not installed yet. Run 'xcode-select --install', click Install on the popup, wait for it to finish, then run this installer again."
  fi
  fail "git is not installed. Install git with your system's package manager, then run this installer again."
fi

# ------------------------------------------------------------ clone or update
normalize_url() { printf '%s' "${1%.git}" | tr 'A-Z' 'a-z'; }

if [ ! -e "$REPO_DIR" ]; then
  say "Downloading the Hat Fella skill library to $REPO_DIR ..."
  git clone --branch "$REPO_BRANCH" "$REPO_URL" "$REPO_DIR"
else
  [ -d "$REPO_DIR/.git" ] || fail "$REPO_DIR exists but is not the Hat Fella skills repository. Move or rename that folder, then run the installer again."
  existing_url="$(git -C "$REPO_DIR" remote get-url origin 2>/dev/null || true)"
  if [ "$(normalize_url "$existing_url")" != "$(normalize_url "$REPO_URL")" ]; then
    fail "$REPO_DIR contains a different repository ($existing_url). Move or rename that folder, then run the installer again."
  fi
  if [ -n "$(git -C "$REPO_DIR" status --porcelain)" ]; then
    fail "$REPO_DIR has local changes that an update would collide with. Ask whoever edits the skills to commit or discard those changes, then run the installer again. (Nothing was deleted.)"
  fi
  say "Updating the Hat Fella skill library in $REPO_DIR ..."
  git -C "$REPO_DIR" fetch origin "$REPO_BRANCH"
  git -C "$REPO_DIR" checkout -q "$REPO_BRANCH"
  if ! git -C "$REPO_DIR" merge --ff-only "origin/$REPO_BRANCH"; then
    fail "The local copy in $REPO_DIR has drifted from the team repository and cannot be fast-forwarded. Resolve the git state manually (or move the folder aside), then run the installer again. (Nothing was deleted.)"
  fi
fi

# ------------------------------------------------------- discover the skills
# A skill is any directory under plugins/*/skills/ that contains a SKILL.md
# with a "name:" line in its frontmatter.
skill_dirs=()
while IFS= read -r skill_md; do
  dir="$(cd "$(dirname "$skill_md")" && pwd)"
  if head -20 "$skill_md" | grep -q '^name:'; then
    skill_dirs+=("$dir")
  else
    say "WARNING: skipping $(basename "$dir") — its SKILL.md has no 'name:' frontmatter."
  fi
done < <(find "$REPO_DIR/plugins" -mindepth 4 -maxdepth 4 -type f -name SKILL.md -path '*/skills/*' 2>/dev/null | sort)

[ "${#skill_dirs[@]}" -gt 0 ] || fail "No skills found in $REPO_DIR/plugins — the repository layout looks wrong."

# unique-name check
dupes="$(for d in "${skill_dirs[@]}"; do basename "$d"; done | sort | uniq -d)"
[ -z "$dupes" ] || fail "Duplicate skill names in the repository: $dupes. Fix the repository before installing."

# --------------------------------------------------------------- link skills
# Links are recorded in a manifest so future runs only ever remove links this
# installer created. Anything else in the skills folder is left alone.
link_into() {
  target_root="$1"
  mkdir -p "$target_root"
  manifest="$target_root/$MANIFEST_NAME"
  old_managed="$( [ -f "$manifest" ] && cat "$manifest" || true )"

  installed=() ; skipped=()
  : > "$manifest.new"
  for dir in "${skill_dirs[@]}"; do
    name="$(basename "$dir")"
    link="$target_root/$name"
    if [ -L "$link" ]; then
      # A symlink: ours to manage if it's in the manifest or already points
      # into our repo. Otherwise leave it alone.
      current="$(readlink "$link")"
      case "$current" in
        "$REPO_DIR"/*) ln -sfn "$dir" "$link"; installed+=("$name"); printf '%s\n' "$name" >> "$manifest.new"; continue ;;
      esac
      if printf '%s\n' "$old_managed" | grep -qx "$name"; then
        ln -sfn "$dir" "$link"; installed+=("$name"); printf '%s\n' "$name" >> "$manifest.new"
      else
        skipped+=("$name (a skill link that isn't managed by this installer already exists)")
      fi
    elif [ -e "$link" ]; then
      skipped+=("$name (you already have a personal skill or folder with this name — it was NOT touched)")
    else
      ln -s "$dir" "$link"; installed+=("$name"); printf '%s\n' "$name" >> "$manifest.new"
    fi
  done

  # Remove stale links: only names the manifest proves we created, whose
  # target no longer exists in the repo.
  if [ -n "$old_managed" ]; then
    while IFS= read -r name; do
      [ -n "$name" ] || continue
      grep -qx "$name" "$manifest.new" && continue
      link="$target_root/$name"
      if [ -L "$link" ]; then
        rm "$link"
        say "Removed retired skill link: $name"
      fi
    done <<< "$old_managed"
  fi
  mv "$manifest.new" "$manifest"

  say ""
  say "Skills in $target_root:"
  for name in "${installed[@]}"; do say "  + $name"; done
  for note in "${skipped[@]+"${skipped[@]}"}"; do say "  ! skipped: $note"; done
}

link_into "$SKILLS_DIR"

if [ "${HFP_LEGACY_CODEX_LINKS:-0}" = "1" ]; then
  say ""
  say "Legacy linking requested — also linking into $LEGACY_DIR"
  link_into "$LEGACY_DIR"
fi

say ""
say "Done. ${#skill_dirs[@]} Hat Fella skills are installed and up to date."
say "Restart Codex now so it picks up the skills."
say "To update later, just run this same installer again."
