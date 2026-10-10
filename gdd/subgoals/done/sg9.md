---
type: build
advances: history (before the 2026-10-10 redesign)
depends_on: none
touches: plugins/polaris/, docs/, README.md
---
# SG9 機械的な停止条件を実装する

| 項目 | 内容 |
|---|---|
| ゴール | 戻せない行為と状態ファイルの不変条件を、AI の判断を通さずに hook と ask ルールで止める |
| 種類と完了条件 | 作る系。gdd-init が書く ask ルールに戻せない行為（依存の追加、マイグレーション、公開・送信、`.claude/settings.json`、design.md）が入る。goal.md / subgoals.md への Bash 書き込みは差分で検知して巻き戻す。`state.md` の学びの削除、`adr.md` の書き換え、テストの skip 追加を hook が止める |
| 評価基準 | 定量：敵対的レビューで通った 25 パターンのうち、goal.md / subgoals.md 書き込みの全経路が止まる。定性：止まった理由の文を見て、人間が何をすべきかわかる |
| 結果 | `guard-gdd-writes.sh` が実行前に控えて実行後に比べる形で、goal.md / subgoals.md の Bash 書き込み・学びの削除・adr.md の書き換えを戻し、テストの skip 追加を止める（テスト 20 ケース）。gdd-init が戻せない行為の ask ルールを書く。外部サービスの選定・課金・認証・シナリオの緩和・assert を弱める変更・N 周無変化は指示文のまま。hook を読み込んだ状態の確認は人間が行い完了 |
