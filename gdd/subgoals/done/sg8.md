---
type: build
advances: history (before the 2026-10-10 redesign)
depends_on: none
touches: plugins/polaris/, docs/, README.md
---
# SG8 polaris を plugin にする

| 項目 | 内容 |
|---|---|
| ゴール | polaris のリポジトリを、`/plugin install` で入れられる plugin とマーケットプレイスの形にする |
| 種類と完了条件 | 作る系。polaris 以外のディレクトリで plugin として読み込み、`/polaris:gdd-init` → `/polaris:gdd-loop` が通る。Bash から goal.md / subgoals.md への書き込みを止める hook も plugin と一緒に効く |
| 評価基準 | 定量：別のディレクトリで `/polaris:gdd-init` と `/polaris:gdd-loop` の両方が起動できる。定性：README だけで、初めての人が入れ方と始め方をわかると人間が判断できる |
| 結果 | エンジンを `plugins/polaris/` に移し英語の plugin にした。マーケットプレイスと MIT ライセンスを付けた。`claude plugin validate` は通過、別ディレクトリで `gdd-init` が起動し hook も効いた。書き込み完了と `gdd-loop` の起動は sandbox の制約で AI 側では未確認のまま、人間の判断で完了 |
