#!/bin/bash
# Mechanical stop conditions for the gdd/ state files (design.md 7).
# "pre" snapshots the files a tool may touch; "post" compares and undoes or refuses:
#   - gdd/goal.md changed or created by Bash                    -> restored, exit 2
#   - a gdd/subgoals/**/*.md written without `advances:`        -> restored or removed, exit 2
#   - a learning removed from gdd/state.md                      -> restored, exit 2
#   - gdd/adr.md rewritten instead of appended                   -> restored, exit 2
#   - a skip/ignore added to a test file                         -> exit 2 (stop and ask)
# Needs bash, grep, sed, awk, shasum, find. No jq.
# ponytail: the Bash snapshot runs `find` over the repo on every command; prune more dirs if it gets slow.

mode="$1"
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
    -o \( -path '*/gdd/goal.md' -o -path '*/gdd/subgoals/*.md' \) -print 2>/dev/null
}
refuse() { printf '%s\n' "$1" >&2; exit 2; }
# A sub-goal must say which acceptance scenario or uncertainty it advances.
no_advances() { ! sed -n '1{/^---$/!q;};2,/^---$/p' "$1" | grep -Eq '^advances:[[:space:]]*[^[:space:]]'; }

case "$mode:$tool" in
  pre:Bash)
    : > "$snap/bash.manifest"
    while IFS= read -r f; do
      cp "$f" "$snap/$(key "$f")"
      printf '%s\t%s\n' "$(sum "$f")" "$f" >> "$snap/bash.manifest"
    done < <(gdd_files)
    ;;

  post:Bash)
    [ -f "$snap/bash.manifest" ] || exit 0
    changed=""; bad=""
    while IFS=$'\t' read -r s f; do
      case "$f" in */gdd/goal.md) ;; *) continue ;; esac
      if [ ! -f "$f" ] || [ "$(sum "$f")" != "$s" ]; then
        cp "$snap/$(key "$f")" "$f"
        changed="$changed $f"
      fi
    done < "$snap/bash.manifest"
    while IFS= read -r f; do
      line=$(grep -F "	$f" "$snap/bash.manifest" | head -1)
      case "$f" in
        */gdd/goal.md) [ -n "$line" ] || { rm -f "$f"; changed="$changed $f"; } ;;
        *)
          [ "${line%%	*}" = "$(sum "$f")" ] && continue
          # Moving a sub-goal between candidates/in-progress/done keeps its content; only new or changed content is checked.
          no_advances "$f" || continue
          if [ -n "$line" ]; then cp "$snap/$(key "$f")" "$f"; else rm -f "$f"; fi
          bad="$bad $f"
          ;;
      esac
    done < <(gdd_files)
    [ -z "$changed" ] || refuse "Reverted Bash changes to:$changed. Do not write gdd/goal.md from Bash. Use the Edit tool so the human approves the change."
    [ -z "$bad" ] || refuse "Reverted sub-goal files without an \`advances:\` line in the frontmatter:$bad. Every sub-goal must name the acceptance scenario or uncertainty it advances."
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
      */gdd/subgoals/*.md)
        [ -f "$file" ] && no_advances "$file" || exit 0
        if [ -f "$old" ]; then cp "$old" "$file"; else rm -f "$file"; fi
        refuse "Reverted $file: a sub-goal needs an \`advances:\` line in its frontmatter naming the acceptance scenario (e.g. scenario_1) or uncertainty (e.g. U1) it moves forward."
        ;;
    esac
    [ -f "$old" ] && [ -f "$file" ] || exit 0
    case "$file" in
      */gdd/state.md)
        missing=$(awk '/^## /{p=($0 ~ /Learnings/ || index($0,"学び")>0)} p && /^- /{print}' "$old" |
          while IFS= read -r l; do grep -qF -- "$l" "$file" || printf '%s\n' "$l"; done)
        [ -z "$missing" ] || { cp "$old" "$file"; refuse "Restored gdd/state.md: these learnings were removed. Never delete a learning; keep its text and append to it instead:
$missing"; }
        ;;
      */gdd/adr.md)
        n=$(wc -c < "$old")
        [ "$(head -c "$n" "$file" | shasum)" = "$(shasum < "$old")" ] ||
          { cp "$old" "$file"; refuse "Restored gdd/adr.md: it is append-only. Add a new entry at the end; never rewrite earlier entries."; }
        ;;
      *)
        if printf '%s' "$file" | grep -Eqi '(^|/)(tests?|spec|__tests__|androidTest)(/|$)|[._]test\.|[._]spec\.|Tests?\.[a-z]+$'; then
          pat='@pytest\.mark\.skip|pytest\.skip\(|unittest\.skip|\.skip\(|\bxit\(|\bxdescribe\(|\bxtest\(|@Ignore|@Disabled|t\.Skip\(|#\[ignore\]'
          before=$(grep -Ec "$pat" "$old"); after=$(grep -Ec "$pat" "$file")
          [ "$after" -le "$before" ] || refuse "This edit adds a skip/ignore to a test file ($before -> $after). Loosening tests is a stop condition: do not continue; ask the human with three options first."
        fi
        ;;
    esac
    ;;
esac
exit 0
