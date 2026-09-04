#!/usr/bin/env bash
# Automated test for install.sh. Runs entirely inside temp directories via
# HFP_TARGET_HOME — it never modifies the real home directory, and proves it.
# Usage: bash tests/test-install.sh
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

pass=0; failn=0
check() { # check <description> <command...>
  desc="$1"; shift
  if "$@" >/dev/null 2>&1; then pass=$((pass+1)); echo "  ok: $desc"
  else failn=$((failn+1)); echo "  FAIL: $desc"; fi
}

# Snapshot the real skills folders so we can prove the tests never touch them.
snap_real() {
  { ls -la "$HOME/.agents/skills" 2>/dev/null; ls -la "$HOME/.codex/skills" 2>/dev/null; } || true
}
REAL_BEFORE="$(snap_real)"

# A bare repo acts as the "remote" so pulls/clones work offline. HEAD is
# pushed into a named branch so this works even from a detached-HEAD
# checkout (as on CI runners).
git init --quiet --bare "$WORK/origin.git"
git -C "$REPO_ROOT" push --quiet "$WORK/origin.git" HEAD:refs/heads/testmain

export HFP_TARGET_HOME="$WORK/home"
mkdir -p "$HFP_TARGET_HOME"
export HFP_REPO_URL="$WORK/origin.git"
export HFP_REPO_BRANCH=testmain
REPO_DIR="$HFP_TARGET_HOME/HFPskills"
SKILLS_DIR="$HFP_TARGET_HOME/.agents/skills"

echo "== run 1: fresh install =="
bash "$REPO_ROOT/install.sh" > "$WORK/run1.log" 2>&1 || { cat "$WORK/run1.log"; exit 1; }

expected="$(find "$REPO_ROOT/plugins" -mindepth 4 -maxdepth 4 -name SKILL.md -path '*/skills/*' | wc -l | tr -d ' ')"
linked="$(find "$SKILLS_DIR" -maxdepth 1 -type l | wc -l | tr -d ' ')"
check "all $expected skills linked (got $linked)" [ "$linked" = "$expected" ]
manifest="$SKILLS_DIR/.hatfella-managed-skills"
check "manifest written" [ -f "$manifest" ]
check "manifest records repo url" grep -q "^repo_url=$HFP_REPO_URL" "$manifest"
check "manifest records branch" grep -q "^branch=$HFP_REPO_BRANCH" "$manifest"
sha="$(git -C "$REPO_DIR" rev-parse HEAD)"
check "manifest records commit sha" grep -q "^commit=$sha" "$manifest"
check "manifest records install date" grep -qE "^installed_at=[0-9]{4}-" "$manifest"
check "manifest records source and dest paths" grep -qE "^skill	[^	]+	$REPO_DIR/.+	$SKILLS_DIR/." "$manifest"
short="$(git -C "$REPO_DIR" rev-parse --short HEAD)"
check "final report shows short sha" grep -q "version $short" "$WORK/run1.log"
first_link="$(find "$SKILLS_DIR" -maxdepth 1 -type l | head -1)"
# shellcheck disable=SC2016  # $1 is expanded by the inner bash, not this shell
check "links are absolute" bash -c 'case "$(readlink "$1")" in /*) exit 0;; *) exit 1;; esac' _ "$first_link"
check "links resolve to a SKILL.md" [ -f "$first_link/SKILL.md" ]

echo "== run 2: idempotency + collision safety =="
mkdir "$SKILLS_DIR/my-personal-skill"                    # unrelated skill
echo hi > "$SKILLS_DIR/my-personal-skill/SKILL.md"
first_name="$(basename "$first_link")"
rm "$SKILLS_DIR/$first_name"                             # simulate collision:
mkdir "$SKILLS_DIR/$first_name"                          # real dir, same name
bash "$REPO_ROOT/install.sh" > "$WORK/run2.log" 2>&1 || { cat "$WORK/run2.log"; exit 1; }

linked2="$(find "$SKILLS_DIR" -maxdepth 1 -type l | wc -l | tr -d ' ')"
check "second run linked $((expected-1)) (one collision) (got $linked2)" [ "$linked2" = "$((expected-1))" ]
check "collision dir untouched (still a real dir)" [ -d "$SKILLS_DIR/$first_name" -a ! -L "$SKILLS_DIR/$first_name" ]
check "collision reported" grep -q "skipped: $first_name" "$WORK/run2.log"
check "personal skill untouched" [ -f "$SKILLS_DIR/my-personal-skill/SKILL.md" ]
# shellcheck disable=SC2016  # $1 is expanded by the inner bash, not this shell
check "no nested/duplicate links" bash -c '[ -z "$(find "$1" -mindepth 2 -maxdepth 2 -type l)" ]' _ "$SKILLS_DIR"

echo "== run 3: dirty repo refused =="
echo dirty >> "$REPO_DIR/README.md"
if bash "$REPO_ROOT/install.sh" > "$WORK/run3.log" 2>&1; then
  failn=$((failn+1)); echo "  FAIL: dirty repo should abort"
else
  pass=$((pass+1)); echo "  ok: dirty repo aborts with explanation"
fi
check "dirty-repo message is clear" grep -q "local changes" "$WORK/run3.log"
git -C "$REPO_DIR" checkout -- README.md

echo "== run 4: wrong repo refused =="
WRONG="$WORK/wrong"; mkdir -p "$WRONG"; git -C "$WRONG" init --quiet
git -C "$WRONG" remote add origin https://example.com/other/repo.git
if HFP_REPO_DIR="$WRONG" bash "$REPO_ROOT/install.sh" > "$WORK/run4.log" 2>&1; then
  failn=$((failn+1)); echo "  FAIL: wrong repo should abort"
else
  pass=$((pass+1)); echo "  ok: wrong repo aborts with explanation"
fi

echo "== run 5: uninstall =="
bash "$REPO_ROOT/install.sh" --uninstall > "$WORK/run5.log" 2>&1 || { cat "$WORK/run5.log"; exit 1; }
linked5="$(find "$SKILLS_DIR" -maxdepth 1 -type l | wc -l | tr -d ' ')"
check "all managed links removed (got $linked5)" [ "$linked5" = "0" ]
check "manifest removed" [ ! -f "$manifest" ]
check "personal skill survives uninstall" [ -f "$SKILLS_DIR/my-personal-skill/SKILL.md" ]
check "collision dir survives uninstall" [ -d "$SKILLS_DIR/$first_name" ]
check "cloned repo kept by default" [ -d "$REPO_DIR/.git" ]
check "uninstall names what it removed" grep -q "removed:" "$WORK/run5.log"

echo "== real home directory untouched =="
REAL_AFTER="$(snap_real)"
check "real ~/.agents/skills and ~/.codex/skills unchanged" [ "$REAL_BEFORE" = "$REAL_AFTER" ]

echo
echo "RESULT: $pass passed, $failn failed"
[ "$failn" = 0 ]
