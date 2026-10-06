#!/bin/bash
# Bash から gdd/goal.md / gdd/subgoals.md への書き込みを止める。Edit ツールなら ask で人間の承認が入る。
# ponytail: 正規表現による粗い判定。すり抜けが見つかったらパターンを足す

cmd=$(jq -r '.tool_input.command // ""')
target='gdd/(goal|subgoals)\.md'

if grep -Eq ">>?[[:space:]]*[^[:space:]&]*${target}" <<<"$cmd" ||
  { grep -Eq "$target" <<<"$cmd" && grep -Eq '(sed[[:space:]]+-i|perl[^|;]*[[:space:]]-[a-zA-Z]*i|tee[[:space:]]|mv[[:space:]]|cp[[:space:]]|rm[[:space:]]|truncate[[:space:]])' <<<"$cmd"; }; then
  echo "gdd/goal.md と gdd/subgoals.md は Bash で書かず、Edit ツールで書く（人間の承認を通すため）。" >&2
  exit 2
fi
exit 0
