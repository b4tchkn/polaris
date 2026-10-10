---
type: build
advances: history (before the 2026-10-10 redesign)
depends_on: none
touches: plugins/polaris/, docs/, README.md
---
# SG2 Loop を1周回す skill を作る

| 項目 | 内容 |
|---|---|
| ゴール | 1回の起動で次のサブゴールを1つ進め、サブゴール完了報告（振り返りを含む）を出して止まる `gdd-loop` skill を作る |
| 種類と完了条件 | 作る系。このリポジトリで `gdd-loop` を1回起動すると、サブゴールを進めて `state.md` を書き直し、design.md 4.1 の項目を満たすサブゴール完了報告を出して止まる |
| 結果 | `.claude/skills/gdd-loop/` と報告の雛形を作った。報告は `gdd/reports/SG<N>.md` に置き、「判断」欄が空なら次に進まない。`/gdd-loop` での起動確認は SG3 で行う |
