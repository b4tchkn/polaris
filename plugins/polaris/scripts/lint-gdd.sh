#!/bin/bash
# Lints the gdd/ state files against the shape of the plugin's templates, so that tools reading
# them (panes, graders) work whatever language the content is written in.
# Headings and table labels must be the templates' English ones; the content may be any language.
# Read-only: it never writes to gdd/. A file that does not exist yet is not checked (gdd-init writes them one by one).
# Usage: lint-gdd.sh [project dir]   (default: .)   Prints one line per problem; exit 1 if any.
# Needs bash, grep, sed, awk.

root="${1:-.}"
gdd="$root/gdd"
here="$(cd "$(dirname "$0")/.." && pwd)"
subgoals_tpl="$here/skills/gdd-init/templates/subgoals.md"
review_tpl="$here/skills/gdd-loop/templates/review.md"

fail=0
report() { printf '%s: %s%s\n' "$1" "$2" "${3:+ $3}"; fail=1; } # where, check id, message

# --- goal.md
# G1  the first heading is "# Goal: <name>"
if [ -f "$gdd/goal.md" ]; then
  first=$(grep -n -m1 '^# ' "$gdd/goal.md")
  case "${first#*:}" in
    "# Goal: "?*) ;;
    *) report "gdd/goal.md${first:+:${first%%:*}}" G1 'the first heading must be "# Goal: <name>"' ;;
  esac
fi

# --- subgoals.md
# S1  every "## " heading is "## Done: SG<n> <title>", "## Next: SG<n> <title>" or "## Later"
# S2  at most one Next; none only when the Later table has no rows (the goal is reached)
# S3  Done sections, then Next, then Later
# S4  no SG number twice across Done, Next and Later
# S5  the Next table has every row label of the template's Next table, none empty
# S6  "Type and done condition" reads "<type>. <done condition>" (or "<type>。<done condition>")
# S7  every Later row is "| SG<n> | <goal> | <type> |"
sub="$gdd/subgoals.md"
if [ -f "$sub" ]; then
  # The Next table's row labels, from the template, tab-separated.
  labels=$(awk '/^## /{inNext=($0 ~ /^## Next:/); sep=0; next}
    inNext && /^\|/ { t=$0; gsub(/[ \t]/, "", t); if (t ~ /^\|[-:|]+$/) { sep=1; next }
      if (sep) { split($0, c, "|"); gsub(/^[ \t]+|[ \t]+$/, "", c[2]); printf "%s%s", (n++ ? "\t" : ""), c[2] } }' "$subgoals_tpl")
  while IFS= read -r line; do report "${line%% *}" "${line#* }"; done < <(
    awk -v F=gdd/subgoals.md -v L="$labels" '
      function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
      function bad(n, id, msg) { printf "%s%s %s %s\n", F, (n ? ":" n : ""), id, msg }
      BEGIN { split(L, need, "\t") }
      /^## / {
        sec = ""; sep = 0
        if ($0 ~ /^## (Done|Next): SG[0-9]+ [^ ]/) {
          kind = substr($0, 4, 4); id = $0; sub(/^## (Done|Next): /, "", id); sub(/ .*/, "", id)
          if (kind == "Done" && (nexts || later)) bad(NR, "S3", "a Done section must come before Next and Later")
          if (kind == "Next") { nexts++; nextLine = NR; if (later) bad(NR, "S3", "Next must come before Later") }
          if (nexts > 1 && kind == "Next") bad(NR, "S2", "more than one Next section")
          if (id in seen) bad(NR, "S4", id " appears more than once"); seen[id] = 1
          sec = kind
        } else if ($0 ~ /^## Later([ (]|$)/) { later = 1; sec = "Later" }
        else bad(NR, "S1", "a heading must be \"## Done: SG<n> <title>\", \"## Next: SG<n> <title>\" or \"## Later\"")
        next
      }
      /^\|/ && sec != "" {
        t = $0; gsub(/[ \t]/, "", t)
        if (t ~ /^\|[-:|]+$/) { sep = 1; next }
        if (!sep) next
        n = split($0, c, "|"); for (i = 1; i <= n; i++) c[i] = trim(c[i])
        if (sec == "Next" && nexts == 1) { val[c[2]] = c[3]; at[c[2]] = NR }
        if (sec == "Later") {
          rows++
          if (n != 5 || c[2] !~ /^SG[0-9]+$/ || c[3] == "" || c[4] == "")
            bad(NR, "S7", "a Later row must be \"| SG<n> | <goal> | <type> |\"")
          else { if (c[2] in seen) bad(NR, "S4", c[2] " appears more than once"); seen[c[2]] = 1 }
        }
      }
      END {
        if (!nexts && rows) bad(0, "S2", "no Next section while Later still has sub-goals")
        if (!nexts) exit
        for (i = 1; i in need; i++) {
          if (!(need[i] in val)) bad(nextLine, "S5", "the Next table has no \"" need[i] "\" row")
          else if (val[need[i]] == "") bad(at[need[i]], "S5", "\"" need[i] "\" is empty")
        }
        k = "Type and done condition"
        if (val[k] != "" && val[k] !~ /^[^.]+\. ./ && val[k] !~ /^[^.]+。./) bad(at[k], "S6", "\"" k "\" must read \"<type>. <done condition>\"")
      }' "$sub")
fi

# --- reviews/
# R1  each reviews/SG<n>.md names a Done or Next sub-goal
# R2  the reviews of Next and of the last Done have the template's "## " headings, same order (Decision last);
#     with Later empty, "Next sub-goal options" may be another heading (gdd-loop writes the goal check there)
# R4  the last Done's review has a filled Decision
# X1  only the Next's review may have an empty Decision
# X2  the last Done has a review
next_id=$(sed -n 's/^## Next: \(SG[0-9]*\) .*/\1/p' "$sub" 2>/dev/null | head -1)
last_done=$(sed -n 's/^## Done: \(SG[0-9]*\) .*/\1/p' "$sub" 2>/dev/null | tail -1)
known=$(sed -nE 's/^## (Done|Next): (SG[0-9]+) .*/\2/p' "$sub" 2>/dev/null)
template_heads=$(grep '^## ' "$review_tpl")
later_rows=$(awk '/^## /{ l = ($0 ~ /^## Later([ (]|$)/); next } l && /^\|[ \t]*SG[0-9]+[ \t]*\|/ { n++ } END { print n + 0 }' "$sub" 2>/dev/null)

heads_ok() { # review file
  T="$template_heads" FREE=$([ "${later_rows:-0}" = 0 ] && echo '## Next sub-goal options') \
    awk 'BEGIN { n = split(ENVIRON["T"], t, "\n") } { g[++m] = $0 }
      END { if (m != n) exit 1; for (i = 1; i <= n; i++) if (g[i] != t[i] && t[i] != ENVIRON["FREE"]) exit 1 }' \
    < <(grep '^## ' "$1")
}

# The Decision section with comments and blanks removed; empty means no answer yet.
decision() {
  awk '/^## /{ d = ($0 == "## Decision"); next } d { b = b $0 "\n" }
    END { while ((s = index(b, "<!--")) > 0) { e = index(substr(b, s), "-->"); if (!e) { b = substr(b, 1, s - 1); break }
            b = substr(b, 1, s - 1) substr(b, s + e + 2) }
          gsub(/[ \t\n]/, "", b); print b }' "$1"
}

for f in "$gdd"/reviews/SG*.md; do
  [ -f "$f" ] || continue
  id=$(basename "$f" .md)
  where="gdd/reviews/$id.md"
  printf '%s\n' "$known" | grep -qx "$id" || report "$where" R1 "$id is not a Done or Next sub-goal in subgoals.md"
  if [ "$id" = "$next_id" ] || [ "$id" = "$last_done" ]; then
    heads_ok "$f" ||
      report "$where" R2 "the \"## \" headings must be the template's, in its order: $(printf '%s' "$template_heads" | sed 's/^## //' | paste -sd '|' -)"
  fi
  if grep -qx '## Decision' "$f" && [ -z "$(decision "$f")" ] && [ "$id" != "$next_id" ]; then
    report "$where" X1 "the Decision is empty but $id is not the Next sub-goal"
  fi
done

if [ -n "$last_done" ]; then
  f="$gdd/reviews/$last_done.md"
  if [ ! -f "$f" ]; then
    report "gdd/reviews/$last_done.md" X2 "missing: the last Done sub-goal has no review"
  elif [ -z "$(decision "$f")" ]; then
    report "gdd/reviews/$last_done.md" R4 "the last Done sub-goal's Decision is empty"
  fi
fi

exit "$fail"
