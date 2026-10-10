---
type: decide
advances: history (before the 2026-10-10 redesign)
depends_on: none
touches: plugins/polaris/, docs/, README.md
---
# SG0 構成と配布方法を決める

| 項目 | 内容 |
|---|---|
| ゴール | エンジンと状態の分け方、配布方法を決める |
| 種類と完了条件 | 決める系。構成に人間が合意したら完了 |
| 結果 | エンジン（`.claude/`）と状態（`gdd/`）を分ける。新規リポジトリは Template から作り、既存リポジトリには plugin と `gdd-init` で導入する。設計は `docs/design.md` に置く |
