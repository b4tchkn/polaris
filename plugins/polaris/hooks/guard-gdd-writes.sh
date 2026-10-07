#!/bin/bash
# Block Bash writes to gdd/goal.md and gdd/subgoals.md. Writes through the Edit tool go through the ask rule instead.
# ponytail: coarse regex over the raw hook JSON (no jq). Add patterns when a bypass is found.

input=$(cat)
target='gdd/(goal|subgoals)\.md'

if grep -Eq ">>?[[:space:]]*[^[:space:]&]*${target}" <<<"$input" ||
  { grep -Eq "$target" <<<"$input" && grep -Eq '(sed[[:space:]]+-i|perl[^|;]*[[:space:]]-[a-zA-Z]*i|tee[[:space:]]|mv[[:space:]]|cp[[:space:]]|rm[[:space:]]|truncate[[:space:]])' <<<"$input"; }; then
  echo "Do not write gdd/goal.md or gdd/subgoals.md from Bash. Use the Edit tool so the human approves the change." >&2
  exit 2
fi
exit 0
