---
status: todo
type: build
advances: new-repo, parallel
depends_on: none
touches: sim/, tests/sim-verify.sh, tests/check.sh, .gitignore
---
# Docker のシミュレーション環境と、その結果を判定する `sim/verify.sh` をリポジトリに入れる（`simulations/` の旧環境を使う）

## Done when

1. [smoke] コンテナの中の headless の Claude Code が plugin を読み込み、空のリポジトリで `/polaris:gdd-init` を実行して `gdd/goal.md` を作る
   - Check: `bash sim/smoke.sh`
2. [verify] `sim/verify.sh` が、条件を満たす結果のリポジトリでは 0 で、マージが足りない、`status: done` でない、main で gate が落ちる、のそれぞれでは 0 以外で終わる
   - Check: `bash tests/sim-verify.sh`
3. [answers] 人間への質問（ask ルールの承認、AskUserQuestion に当たる質問）に台本の答えを渡して、同じセッションを続けられる
   - Check: observe: smoke のログで、質問に台本の答えが渡り、その後も作業が続いていること
4. [secrets] OAuth トークンとシミュレーションの作業データはコミットされない
   - Check: `git check-ignore -q sim/.oauth-token && git check-ignore -q sim/work/x`

## What to show

- `sim/` の使い方（数行）と smoke のログ
- 1回の実行にかかった時間と費用
