---
status: todo
type: build
advances: parallel
depends_on: sim-harness
touches: sim/parallel/, sim/run.sh
---
# Docker の中で、独立したサブゴール2〜3個を worker の並列で回し、すべて main に取り込む

## Done when

1. [scenario] 直近の実行結果が parallel の条件を満たす
   - Check: `bash sim/verify.sh parallel`
2. [concurrent] worker が本当に同時に動いている
   - Check: `jq -s '[.[] | select(.type=="assistant") | {id: .message.id, n: [.message.content[]? | select(.type=="tool_use" and .name=="Agent")] | length}] | group_by(.id) | map(map(.n) | add) | max >= 2' sim/work/parallel/logs/*.jsonl | grep -qx true`（1つの assistant のメッセージが worker を2つ以上起動している）

## What to show

- マージ結果とログ
- worktree の分離について分かったこと
