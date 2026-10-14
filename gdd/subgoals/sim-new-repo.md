---
status: todo
type: build
advances: new-repo
depends_on: sim-harness
touches: sim/new-repo/
---
# Docker の中で、空のリポジトリから `/polaris:gdd-init` と `/polaris:gdd-loop` を回し、コマンドの ToDo アプリ（Python と pytest）のサブゴールを3つ以上 main に取り込む

## Done when

1. [scenario] 直近の実行結果が new-repo の条件を満たす
   - Check: `bash sim/verify.sh new-repo`
2. [scripted] 人間の答えはすべて `sim/new-repo/` の台本から渡し、途中で手を入れていない
   - Check: observe: `sim/new-repo/` の実行スクリプトとログを見て、台本以外の入力が無いこと

## What to show

- 取り込まれたサブゴールの一覧とレビュー、ToDo アプリの動かし方
- シミュレーションで見つかった plugin の問題（直すものは新しい todo サブゴールにする）
