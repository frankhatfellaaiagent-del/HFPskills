#!/usr/bin/env bash
# Automated test for install.sh. Runs entirely inside temp directories —
# never touches the real home directory. Usage: bash tests/test-install.sh
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

# A bare clone acts as the "remote" so pulls/clones work offline.
git clone --quiet --bare "$REPO_ROOT" "$WORK/origin.git"

export HFP_REPO_URL="$WORK/origin.git"
export HFP_REPO_BRANCH="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)"
export HFP_REPO_DIR="$WORK/HFPskills"
export HFP_SKILLS_DIR="$WORK/skills"

echo "== run 1: fresh install =="
bash "$REPO_ROOT/install.sh" > "$WORK/run1.log" 2>&1 || { cat "$WORK/run1.log"; exit 1; }

expected="$(find "$REPO_ROOT/plugins" -mindepth 4 -maxdepth 4 -name SKILL.md -path '*/skills/*' | wc -l | tr -d ' ')"
linked="$(find "$HFP_SKILLS_DIR" -maxdepth 1 -type l | wc -l | tr -d ' ')"
check "all $expected skills linked (got $linked)" [ "$linked" = "$expected" ]
check "manifest written" [ -f "$HFP_SKILLS_DIR/.hatfella-managed-skills" ]
first_link="$(find "$HFP_SKILLS_DIR" -maxdepth 1 -type l | head -1)"
check "links are absolute" bash -c '[[ "$(readlink "$1")" = /* ]]' _ "$first_link"
check "links resolve to a SKILL.md" [ -f "$first_link/SKILL.md" ]

echo "== run 2: idempotency + collision safety =="
mkdir "$HFP_SKILLS_DIR/my-personal-skill"                    # unrelated skill
echo hi > "$HFP_SKILLS_DIR/my-personal-skill/SKILL.md"
first_name="$(basename "$first_link")"
rm "$HFP_SKILLS_DIR/$first_name"                             # simulate collision:
mkdir "$HFP_SKILLS_DIR/$first_name"                          # real dir, same name
bash "$REPO_ROOT/install.sh" > "$WORK/run2.log" 2>&1 || { cat "$WORK/run2.log"; exit 1; }

linked2="$(find "$HFP_SKILLS_DIR" -maxdepth 1 -type l | wc -l | tr -d ' ')"
check "second run linked $((expected-1)) (one collision) (got $linked2)" [ "$linked2" = "$((expected-1))" ]
check "collision dir untouched (still a real dir)" [ -d "$HFP_SKILLS_DIR/$first_name" -a ! -L "$HFP_SKILLS_DIR/$first_name" ]
check "collision reported" grep -q "skipped: $first_name" "$WORK/run2.log"
check "personal skill untouched" [ -f "$HFP_SKILLS_DIR/my-personal-skill/SKILL.md" ]
check "no nested/duplicate links" bash -c '[ -z "$(find "$1" -mindepth 2 -maxdepth 2 -type l)" ]' _ "$HFP_SKILLS_DIR"

echo "== run 3: dirty repo refused =="
echo dirty >> "$HFP_REPO_DIR/README.md"
if bash "$REPO_ROOT/install.sh" > "$WORK/run3.log" 2>&1; then
  failn=$((failn+1)); echo "  FAIL: dirty repo should abort"
else
  pass=$((pass+1)); echo "  ok: dirty repo aborts with explanation"
fi
check "dirty-repo message is clear" grep -q "local changes" "$WORK/run3.log"
git -C "$HFP_REPO_DIR" checkout -- README.md

echo "== run 4: wrong repo refused =="
WRONG="$WORK/wrong"; mkdir -p "$WRONG"; git -C "$WRONG" init --quiet
git -C "$WRONG" remote add origin https://example.com/other/repo.git
if HFP_REPO_DIR="$WRONG" bash "$REPO_ROOT/install.sh" > "$WORK/run4.log" 2>&1; then
  failn=$((failn+1)); echo "  FAIL: wrong repo should abort"
else
  pass=$((pass+1)); echo "  ok: wrong repo aborts with explanation"
fi

echo
echo "RESULT: $pass passed, $failn failed"
[ "$failn" = 0 ]
