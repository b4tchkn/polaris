---
status: todo
type: build
advances: parallel, worker-isolation
depends_on: sim-harness
touches: sim/parallel/
---
# Docker の中で、独立したサブゴール2〜3個を worker の並列と、別のセッションの `/polaris:gdd-work` の2通りで回し、すべて main に取り込む

## Done when

1. [scenario] 直近の実行結果が parallel の条件を満たす
   - Check: `bash sim/verify.sh parallel`
2. [two-ways] 2通りが本当に起きている：(a) worker が background で同時に動いた、(b) 別のコンテナのセッションで `/polaris:gdd-work <slug>` を実行した
   - Check: observe: 両方のログで、(a) は worker の起動が重なっていること、(b) は別のセッションで gdd-work が動いたこと

## What to show

- 2通りそれぞれのマージ結果とログ
- worktree の分離について分かったこと（worker-isolation の答え）
