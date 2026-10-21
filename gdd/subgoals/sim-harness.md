---
status: todo
type: build
advances: parallel
depends_on: none
touches: sim/, tests/sim-verify.sh, tests/check.sh, .gitignore
---
# `sim/` の Docker シミュレーション環境を、clone した人がそのまま使えるようにし、結果を判定する `sim/verify.sh` を足す

## Done when

1. [setup] `sim/setup.sh <name>` が `sim/work/<name>/`（remote.git、作業ツリー、github/、claude-home/、ask ルール入りの `.claude/settings.json`）を何もない状態から作る。どれかが欠けたら smoke は失敗する
   - Check: `bash sim/smoke.sh`（smoke はイメージの `docker build` と、自分の `sim/work/<name>/` を消して setup から作り直すところからやる。トークンは `.worktreeinclude` で worker の worktree にもコピーされる）
2. [smoke] コンテナの中の headless の Claude Code が plugin を読み込み、空のリポジトリで `/polaris:gdd-init` を実行して `gdd/goal.md` を作る
   - Check: `bash sim/smoke.sh`
3. [verify] `sim/verify.sh <name>` が `sim/work/<name>/` を読み、条件を満たす結果では 0 で、マージが足りない、`status: done` でない、main で gate が落ちる、のそれぞれでは 0 以外で終わる。gate はシミュレーションしたリポジトリの `gdd/goal.md` の Definition of done のコマンドを使う。対象のサブゴールは、シナリオが書いた `sim/work/<name>/subgoals.txt`（1行に1つの slug）のもの。マージ済みとは、そのブランチが `remote.git` の main に取り込まれていること
   - Check: `bash tests/sim-verify.sh`（Docker もトークンも使わず、fixture のリポジトリとローカルの git だけで動く）
4. [gate] `tests/check.sh` が `tests/sim-verify.sh` を実行する
   - Check: `grep -q sim-verify.sh tests/check.sh && bash tests/check.sh`
5. [answers] 人間への質問（ask ルールの承認、AskUserQuestion に当たる質問）に台本の答えを渡して、同じセッションを続けられる。ask ルールは `approve.sh`、質問への答えは `--resume` で次のプロンプトとして渡す
   - Check: observe: smoke のログで、質問に台本の答えが渡り、その後も作業が続いていること
6. [secrets] OAuth トークンは、シミュレーションしたリポジトリ（worker の worktree を含む）でもコミットされない
   - Check: `bash sim/smoke.sh`（シミュレーションしたリポジトリでトークンのファイルが `git check-ignore` で無視されることを確かめる）

## What to show

- `sim/` の使い方（数行。イメージのビルドとトークンの用意を含む）と smoke のログ
- 1回の実行にかかった時間と費用
