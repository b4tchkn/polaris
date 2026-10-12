#!/bin/bash
# Mechanical stop conditions for the gdd/ state files (design.md 7).
# "pre" snapshots the files a tool may touch; "post" compares and undoes or refuses:
#   - gdd/goal.md changed or created by Bash                    -> restored, exit 2
#   - gdd/state.md, gdd/subgoals/*.md, gdd/reviews/*.md failing gdd-lint.sh -> restored or removed, exit 2
#   - a learning removed from gdd/state.md, or state.md deleted (Edit/Write or Bash) -> restored, exit 2
#   - an existing gdd/adr/*.md changed or deleted                -> restored, exit 2 (new files are fine)
#   - a skip/ignore added to a test file, or tests removed from it -> restored, exit 2 (stop and ask)
#   - test files deleted by Bash (fewer than before)             -> restored from git, exit 2
# Needs bash, grep, sed, awk, shasum, find. No jq.
# ponytail: the Bash snapshot runs `find` over the repo on every command; prune more dirs if it gets slow.

mode="$1"
lint="$(cd "$(dirname "$0")/.." && pwd)/skills/gdd-loop/scripts/gdd-lint.sh"
input=$(cat)

field() { printf '%s' "$input" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -1; }

tool=$(field tool_name)
session=$(field session_id)
agent=$(field agent_id)
file=$(field file_path)
# Parallel subagents share the session id, so each agent gets its own snapshot.
snap="${TMPDIR:-/tmp}/polaris-guard/${session:-nosession}${agent:+-$agent}"
mkdir -p "$snap"

# Anchor on the git root of the tool's cwd (a worktree has its own; CLAUDE_PROJECT_DIR stays at the main checkout).
# post reuses the root pre chose, so a `cd` in between cannot make every file look new.
if [ "$1" = pre ]; then
  cwd=$(field cwd)
  root=$(git -C "${cwd:-.}" rev-parse --show-toplevel 2>/dev/null) || root="${CLAUDE_PROJECT_DIR:-${cwd:-$PWD}}"
  printf '%s' "$root" > "$snap/root"
fi
cd "$(cat "$snap/root" 2>/dev/null || printf .)" 2>/dev/null || exit 0

key() { printf '%s' "$1" | shasum | cut -c1-16; }
sum() { shasum < "$1" | cut -c1-40; }
gdd_files() {
  # Other worktrees under .claude/worktrees/ have their own guard (their own root); a worker creating one mid-command is not a write.
  find . \( -name .git -o -name node_modules -o -name build -o -name .gradle -o -path ./.claude/worktrees \) -prune \
    -o \( -path '*/gdd/goal.md' -o -path '*/gdd/state.md' -o -path '*/gdd/subgoals/*.md' -o -path '*/gdd/reviews/*.md' -o -path '*/gdd/adr/*.md' \) -print 2>/dev/null
}
refuse() { printf '%s\n' "$1" >&2; exit 2; }
is_test() { printf '%s' "$1" | grep -Eqi '(^|/)(tests?|spec|__tests__|androidTest)(/|$)|[._]test\.|[._]spec\.|(^|/)test_[^/]*\.py$|Tests?\.[a-z]+$'; }
test_files() {
  find . \( -name .git -o -name node_modules -o -name build -o -name .gradle -o -path ./.claude/worktrees \) -prune \
    -o -type f -print 2>/dev/null | while IFS= read -r f; do is_test "$f" && printf '%s\n' "$f"; done | sort
}
# Sub-goal and review files must keep their format (gdd-lint.sh prints what is wrong).
misformed() { problems=$(bash "$lint" "${1%/gdd/*}/gdd" "$1") && return 1; printf '%s\n' "$problems"; }
# Learnings in state.md are never deleted: prints the ones in $1 (before) that are missing from $2 (after).
lost_learnings() {
  awk '/^## /{p=($0 ~ /Learnings/ || index($0,"学び")>0)} p && /^- /{print}' "$1" |
    while IFS= read -r l; do grep -qF -- "$l" "$2" 2>/dev/null || printf '%s\n' "$l"; done
}

case "$mode:$tool" in
  pre:Bash)
    test_files > "$snap/tests.list"
    : > "$snap/bash.manifest"
    while IFS= read -r f; do
      cp "$f" "$snap/$(key "$f")"
      printf '%s\t%s\n' "$(sum "$f")" "$f" >> "$snap/bash.manifest"
    done < <(gdd_files)
    ;;

  post:Bash)
    [ -f "$snap/bash.manifest" ] || exit 0
    if [ -f "$snap/tests.list" ]; then
      now=$(test_files)
      if [ "$(printf '%s' "$now" | grep -c .)" -lt "$(grep -c . "$snap/tests.list")" ]; then
        gone=$(printf '%s\n' "$now" | comm -13 - "$snap/tests.list")
        printf '%s\n' "$gone" | while IFS= read -r f; do [ -n "$f" ] && git checkout -q HEAD -- "$f" 2>/dev/null; done
        refuse "Test files were deleted:
$gone
Removing tests loosens the checks: restored what git had. Do not continue; ask the human with three options first."
      fi
    fi
    changed=""; bad=""; lost=""
    while IFS=$'\t' read -r s f; do
      case "$f" in
        */gdd/state.md)
          m=$(lost_learnings "$snap/$(key "$f")" "$f")
          if [ ! -f "$f" ] || [ -n "$m" ]; then cp "$snap/$(key "$f")" "$f"; lost="$lost${m:+
$m}"; changed="$changed $f"; fi
          continue ;;
        */gdd/goal.md|*/gdd/adr/*.md) ;;
        *) continue ;;
      esac
      if [ ! -f "$f" ] || [ "$(sum "$f")" != "$s" ]; then
        mkdir -p "$(dirname "$f")"; cp "$snap/$(key "$f")" "$f"
        changed="$changed $f"
      fi
    done < "$snap/bash.manifest"
    while IFS= read -r f; do
      line=$(grep -F "	$f" "$snap/bash.manifest" | head -1)
      case "$f" in
        */gdd/goal.md) [ -n "$line" ] || { rm -f "$f"; changed="$changed $f"; } ;;
        */gdd/adr/*.md) ;;
        *)
          [ "${line%%	*}" = "$(sum "$f")" ] && continue
          # Renaming a sub-goal keeps its content; only new or changed content is checked.
          p=$(misformed "$f") || continue
          if [ -n "$line" ]; then cp "$snap/$(key "$f")" "$f"; else rm -f "$f"; fi
          bad="$bad
$p"
          ;;
      esac
    done < <(gdd_files)
    [ -z "$changed" ] || refuse "Reverted Bash changes to:$changed. Do not write gdd/goal.md from Bash (use the Edit tool so the human approves it), never change or delete an existing ADR in gdd/adr/ (add a new file instead), and never delete gdd/state.md or a learning in it (keep its text and append to it instead).${lost:+ Learnings that were removed:$lost}"
    [ -z "$bad" ] || refuse "Reverted gdd files with format problems:$bad
Fix them as the messages say (sub-goals and reviews follow templates/subgoal.md and templates/review.md) and write them again."
    ;;

  pre:Edit|pre:Write)
    [ -n "$file" ] || exit 0
    rm -f "$snap/$(key "$file")"
    [ -f "$file" ] && cp "$file" "$snap/$(key "$file")"
    ;;

  post:Edit|post:Write)
    [ -n "$file" ] || exit 0
    old="$snap/$(key "$file")"
    case "$file" in
      */gdd/state.md|*/gdd/subgoals/*.md|*/gdd/reviews/*.md)
        if [ -f "$file" ] && p=$(misformed "$file"); then
          if [ -f "$old" ]; then cp "$old" "$file"; else rm -f "$file"; fi
          refuse "Reverted $file:
$p
Fix it as the messages say and write it again (sub-goals and reviews follow templates/subgoal.md and templates/review.md). A sub-goal's advances: names the acceptance scenario ids (e.g. capture) or uncertainties (e.g. U1) it moves forward."
        fi
        ;;
    esac
    [ -f "$old" ] && [ -f "$file" ] || exit 0
    case "$file" in
      */gdd/state.md)
        missing=$(lost_learnings "$old" "$file")
        [ -z "$missing" ] || { cp "$old" "$file"; refuse "Restored gdd/state.md: these learnings were removed. Never delete a learning; keep its text and append to it instead:
$missing"; }
        ;;
      */gdd/adr/*.md)
        [ "$(sum "$file")" = "$(sum "$old")" ] ||
          { cp "$old" "$file"; refuse "Restored $file: an ADR is never changed once written. Record a new decision in a new file in gdd/adr/."; }
        ;;
      *)
        if is_test "$file"; then
          pat='@pytest\.mark\.skip|pytest\.skip\(|unittest\.skip|\.skip\(|\bxit\(|\bxdescribe\(|\bxtest\(|@Ignore|@Disabled|t\.Skip\(|#\[ignore\]'
          before=$(grep -Ec "$pat" "$old"); after=$(grep -Ec "$pat" "$file")
          [ "$after" -le "$before" ] || { cp "$old" "$file"; refuse "Restored $file: the edit added a skip/ignore ($before -> $after). Loosening tests is a stop condition: do not continue; ask the human with three options first."; }
          tp='^[[:space:]]*(async[[:space:]]+)?def[[:space:]]+test|(^|[^.[:alnum:]_])(it|test)(\.each[^(]*)?[[:space:]]*\(|func[[:space:]]+Test|@Test|#\[test\]'
          before=$(grep -Ec "$tp" "$old"); after=$(grep -Ec "$tp" "$file")
          [ "$after" -ge "$before" ] || { cp "$old" "$file"; refuse "Restored $file: the edit removed tests ($before -> $after). Removing tests loosens the checks: do not continue; ask the human with three options first."; }
        fi
        ;;
    esac
    ;;
esac
exit 0
