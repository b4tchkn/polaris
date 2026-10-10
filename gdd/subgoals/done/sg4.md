---
type: build
advances: history (before the 2026-10-10 redesign)
depends_on: none
touches: plugins/polaris/, docs/, README.md
---
# SG4 振り返りを改善ループにする

| 項目 | 内容 |
|---|---|
| ゴール | サブゴール完了時の振り返りで、学び全体とこれまでの報告を見直し、GDD の仕組みの修正・学びのハーネス化・サブゴールの見直しを毎回提案する形を `gdd-loop` に入れる |
| 種類と完了条件 | 作る系。学びを消さない、改善の提案欄がある、採用したものだけ反映する、design.md 5 がこの流れになっている、の4つ |
| 結果 | `gdd-loop` に改善の提案（4種類、番号付き）と「学びは消さない」を入れ、design.md 5 を改善ループに書き直した。判断は毎回 AskUserQuestion で選んでもらう形にした（6）。採用した提案で、Bash から goal.md / subgoals.md への書き込みを止める hook を入れた |
