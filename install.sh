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
# Uninstall (removes only the links this installer created; keeps the repo):
#   ~/HFPskills/install.sh --uninstall
#
# It is completely non-interactive, never uses sudo, never asks for a
# GitHub password, and only manages the links it created itself (tracked
# in a manifest file). Personal skills are never touched.
#
# Compatible with the Bash that ships on a stock Mac (3.2): no associative
# arrays, no mapfile, no bash-4-only syntax.
#
# Overridable via environment variables (all optional, for testing):
#   HFP_TARGET_HOME  base dir standing in for $HOME (repo + skills default under it)
#   HFP_REPO_URL     git URL to install from   (default: public Hat Fella repo)
#   HFP_REPO_BRANCH  branch to track           (default: main)
#   HFP_REPO_DIR     where the repo is cloned  (default: $HFP_TARGET_HOME/HFPskills)
#   HFP_SKILLS_DIR   Codex skills folder       (default: $HFP_TARGET_HOME/.agents/skills)
#   HFP_LEGACY_CODEX_LINKS=1  also link into .codex/skills for older Codex
#                             versions (off by default to avoid duplicate
#                             skills in versions that scan both folders)

set -Eeuo pipefail

TARGET_HOME="${HFP_TARGET_HOME:-$HOME}"
REPO_URL="${HFP_REPO_URL:-https://github.com/frankhatfellaaiagent-del/HFPskills.git}"
REPO_BRANCH="${HFP_REPO_BRANCH:-main}"
REPO_DIR="${HFP_REPO_DIR:-$TARGET_HOME/HFPskills}"
SKILLS_DIR="${HFP_SKILLS_DIR:-$TARGET_HOME/.agents/skills}"
LEGACY_DIR="${HFP_LEGACY_SKILLS_DIR:-$TARGET_HOME/.codex/skills}"
MANIFEST_NAME=".hatfella-managed-skills"

MODE="install"
if [ "${1:-}" = "--uninstall" ]; then MODE="uninstall"; fi

say()  { printf '%s\n' "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# Extract managed skill names from a manifest. Supports the current
# format (lines "skill<TAB>name<TAB>source<TAB>dest") and the original
# format (one bare name per line).
manifest_names() {
  # $1 = manifest path
  [ -f "$1" ] || return 0
  if grep -q '^format=' "$1" 2>/dev/null; then
    sed -n 's/^skill	\([^	]*\).*/\1/p' "$1"
  else
    grep -v '^#' "$1" 2>/dev/null || true
  fi
}

# ------------------------------------------------------------------ uninstall
uninstall_from() {
  # $1 = target skills root
  root="$1"
  manifest="$root/$MANIFEST_NAME"
  [ -f "$manifest" ] || return 0
  say "Uninstalling Hat Fella skills from $root ..."
  manifest_names "$manifest" | while IFS= read -r name; do
    [ -n "$name" ] || continue
    link="$root/$name"
    if [ -L "$link" ]; then
      case "$(readlink "$link")" in
        "$REPO_DIR"/*) rm "$link"; say "  removed: $name" ;;
        *) say "  kept:    $name (link no longer points into the Hat Fella repo)" ;;
      esac
    elif [ -e "$link" ]; then
      say "  kept:    $name (not a symlink — never deleted)"
    fi
  done
  rm -f "$manifest"
}

if [ "$MODE" = "uninstall" ]; then
  uninstall_from "$SKILLS_DIR"
  uninstall_from "$LEGACY_DIR"
  say ""
  say "Uninstall complete. Only Hat Fella-created skill links were removed."
  say "The downloaded library at $REPO_DIR was kept; delete it manually if you"
  say "no longer want it:  rm -rf \"$REPO_DIR\""
  exit 0
fi

# ---------------------------------------------------------------- git check
if ! command -v git >/dev/null 2>&1; then
  if [ "$(uname -s)" = "Darwin" ]; then
    fail "git is not installed yet. Run 'xcode-select --install', click Install on the popup, wait for it to finish, then run this installer again."
  fi
  fail "git is not installed. Install git with your system's package manager, then run this installer again."
fi

# ------------------------------------------------------------ clone or update
normalize_url() { printf '%s' "${1%.git}" | tr '[:upper:]' '[:lower:]'; }

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

COMMIT_SHA="$(git -C "$REPO_DIR" rev-parse HEAD)"
COMMIT_SHORT="$(git -C "$REPO_DIR" rev-parse --short HEAD)"

# ------------------------------------------------------- discover the skills
# A skill is any directory under plugins/*/skills/ that contains a SKILL.md
# with non-empty name: and description: frontmatter.
SKILL_LIST="$(mktemp)"
trap 'rm -f "$SKILL_LIST"' EXIT

find "$REPO_DIR/plugins" -mindepth 4 -maxdepth 4 -type f -name SKILL.md -path '*/skills/*' 2>/dev/null | sort | while IFS= read -r skill_md; do
  dir=$(cd "$(dirname "$skill_md")" && pwd)
  skname="$(sed -n 's/^name:[[:space:]]*//p' "$skill_md" | head -1)"
  skdesc="$(sed -n 's/^description:[[:space:]]*//p' "$skill_md" | head -1)"
  if [ -n "$skname" ] && [ -n "$skdesc" ]; then
    printf '%s\n' "$dir" >> "$SKILL_LIST"
  else
    say "WARNING: skipping $(basename "$dir") — SKILL.md is missing a name or description."
  fi
done

[ -s "$SKILL_LIST" ] || fail "No skills found in $REPO_DIR/plugins — the repository layout looks wrong."
SKILL_COUNT="$(wc -l < "$SKILL_LIST" | tr -d ' ')"

# unique-folder-name check (frontmatter-name uniqueness is enforced by the
# repository's own validation before anything reaches this installer)
dupes="$(while IFS= read -r d; do basename "$d"; done < "$SKILL_LIST" | sort | uniq -d)"
[ -z "$dupes" ] || fail "Duplicate skill names in the repository: $dupes. Fix the repository before installing."

# --------------------------------------------------------------- link skills
# Links are recorded in a manifest so future runs only ever remove links this
# installer created. Anything else in the skills folder is left alone.
# Manifest also records what version was installed, for support and rollback.
link_into() {
  target_root="$1"
  mkdir -p "$target_root"
  manifest="$target_root/$MANIFEST_NAME"
  old_names="$(manifest_names "$manifest")"

  newmanifest="$manifest.new"
  {
    printf '# Hat Fella managed skills manifest — created by install.sh, do not edit\n'
    printf 'format=2\n'
    printf 'repo_url=%s\n' "$REPO_URL"
    printf 'branch=%s\n' "$REPO_BRANCH"
    printf 'commit=%s\n' "$COMMIT_SHA"
    printf 'installed_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  } > "$newmanifest"

  installed=""
  skipped=""
  while IFS= read -r dir; do
    name="$(basename "$dir")"
    link="$target_root/$name"
    manage=0
    if [ -L "$link" ]; then
      case "$(readlink "$link")" in
        "$REPO_DIR"/*) manage=1 ;;
        *) if printf '%s\n' "$old_names" | grep -qx -- "$name"; then manage=1; fi ;;
      esac
      if [ "$manage" = 1 ]; then
        ln -sfn "$dir" "$link"
      else
        skipped="$skipped  ! skipped: $name (a skill link that isn't managed by this installer already exists)\n"
        continue
      fi
    elif [ -e "$link" ]; then
      skipped="$skipped  ! skipped: $name (you already have a personal skill or folder with this name — it was NOT touched)\n"
      continue
    else
      ln -s "$dir" "$link"
    fi
    installed="$installed  + $name\n"
    printf 'skill\t%s\t%s\t%s\n' "$name" "$dir" "$link" >> "$newmanifest"
  done < "$SKILL_LIST"

  # Remove stale links: only names the manifest proves we created, whose
  # skill no longer exists in the repo.
  if [ -n "$old_names" ]; then
    printf '%s\n' "$old_names" | while IFS= read -r name; do
      [ -n "$name" ] || continue
      grep -q "^skill	$name	" "$newmanifest" && continue
      link="$target_root/$name"
      if [ -L "$link" ]; then
        rm "$link"
        say "Removed retired skill link: $name"
      fi
    done
  fi
  mv "$newmanifest" "$manifest"

  say ""
  say "Skills in $target_root:"
  printf '%b' "$installed"
  [ -n "$skipped" ] && printf '%b' "$skipped"
  return 0
}

link_into "$SKILLS_DIR"

if [ "${HFP_LEGACY_CODEX_LINKS:-0}" = "1" ]; then
  say ""
  say "Legacy linking requested — also linking into $LEGACY_DIR"
  link_into "$LEGACY_DIR"
fi

say ""
say "Done. $SKILL_COUNT Hat Fella skills are installed and up to date (version $COMMIT_SHORT)."
say "Restart Codex now so it picks up the skills."
say "To update later, run this same installer again."
say "To uninstall later:  \"$REPO_DIR/install.sh\" --uninstall"
