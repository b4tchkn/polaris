---
type: build
advances: history (before the 2026-10-10 redesign)
depends_on: none
touches: plugins/polaris/, docs/, README.md
---
# SG1 状態ファイルの雛形と gdd-init を作る

| 項目 | 内容 |
|---|---|
| ゴール | 空の `gdd/` を生成する `gdd-init` skill と、状態ファイルの雛形を作る |
| 種類と完了条件 | 作る系。空のディレクトリで `gdd-init` を実行すると、雛形一式と settings の ask ルールが揃う |
| 結果 | `.claude/skills/gdd-init/` に skill と雛形（goal.md / subgoals.md / state.md）を作った。予算と constraints.md は廃止し、前提は goal.md と CLAUDE.md に置く。`archive/` は初めてゴールが完了したときに作る |
