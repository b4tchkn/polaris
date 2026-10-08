#!/bin/bash
# Mechanical stop conditions for the gdd/ state files (design.md 7).
# "pre" snapshots the files a tool may touch; "post" compares and undoes or refuses:
#   - gdd/goal.md, gdd/subgoals.md changed or created by Bash  -> restored, exit 2
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
file=$(field file_path)
snap="${TMPDIR:-/tmp}/polaris-guard/${session:-nosession}"
mkdir -p "$snap"

key() { printf '%s' "$1" | shasum | cut -c1-16; }
sum() { shasum < "$1" | cut -c1-40; }
gdd_files() {
  find . \( -name .git -o -name node_modules -o -name build -o -name .gradle \) -prune \
    -o \( -path '*/gdd/goal.md' -o -path '*/gdd/subgoals.md' \) -print 2>/dev/null
}
refuse() { printf '%s\n' "$1" >&2; exit 2; }

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
    changed=""
    while IFS=$'\t' read -r s f; do
      if [ ! -f "$f" ] || [ "$(sum "$f")" != "$s" ]; then
        cp "$snap/$(key "$f")" "$f"
        changed="$changed $f"
      fi
    done < "$snap/bash.manifest"
    while IFS= read -r f; do
      grep -qF "	$f" "$snap/bash.manifest" || { rm -f "$f"; changed="$changed $f"; }
    done < <(gdd_files)
    [ -z "$changed" ] || refuse "Reverted Bash changes to:$changed. Do not write gdd/goal.md or gdd/subgoals.md from Bash. Use the Edit tool so the human approves the change."
    ;;

  pre:Edit|pre:Write)
    [ -n "$file" ] && [ -f "$file" ] && cp "$file" "$snap/$(key "$file")"
    ;;

  post:Edit|post:Write)
    [ -n "$file" ] || exit 0
    old="$snap/$(key "$file")"
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
