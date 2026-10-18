# ゴール駆動・人間介在型 AI 作業環境 設計

> 2026-10-19 版。設計はこの1ファイルだけ。

## 目的

人間がゴールを伝えると、AI がそこへのサブゴールを提案し、承認されたら反復しながら自律的に進める。人間は要所だけ関わる（Human-on-the-loop）。新規のリポジトリでも既存のリポジトリでも、plugin を入れて同じ手順で始められる。

## 原則

- **結果の形だけを書き、やり方はモデルに任せる**。skill は eli5（https://github.com/anthropics/claude-plugins-community/tree/main/eli5 ）のように、メインの流れの最低限だけを書く。細かい場合分けは、実際に困ってから足す。
- **完了はコマンドで決める**。ゴールとサブゴールの条件には `Check:` を付け、なるべくコマンド（0 で終われば達成）にする。作業した AI の自己申告では決めない。
- **main は PR のマージでしか変わらない**。サブゴール1つに PR 1つ。これがガードレールになる。
- **1人用**。状態は `gdd/` のファイルとして git に入り、リモートにあるので別の PC からも続けられる。

## 流れ

```
ゴールを決める ─▶ サブゴールに分ける ─▶ worker が作って PR ─▶ マージ ─▶（繰り返す）─▶ 全 Check が通ったら報告
```

1. ゴールが無ければ人間と決める：1文の北極星と、3〜5個の成果。それぞれに `Check:`。
2. 残りを小さなサブゴールに分ける（`gdd/subgoals/<slug>.md`、それぞれ Done when と Check）。人間が一覧を承認する。
3. `worker` が worktree で作る。独立したものは並列にする。終わったら自分のブランチを push して PR を出す。本文は、作ったもの、試し方、Check の結果。
4. CI が通ったら AI がマージする。ただし、`human:` の条件を含む PR、`goal.md` や既にあるテストを変えた PR は、人間がマージする。
5. `goal.md` の Check がすべて通ったら、報告して止まる。

## 人間が関わる場面

これ以外では止まらない。

| いつ | 何をするか |
|---|---|
| ゴールを決める | 質問に答え、`goal.md` を承認する |
| サブゴールに分ける | 一覧と各 Check を承認する |
| 判断が要る PR | 中身を見てマージする |
| 取り返しのつかないこと | 依存の追加、データモデル、外部サービスなどを選ぶ（ask ルールでも止まる） |

## 構成

```
plugins/polaris/
  skills/gdd-init/           goal.md の雛形を置き、ask ルールを足す
  skills/gdd-loop/           上の「流れ」を回す
  agents/worker.md           サブゴール1つを worktree で作り、PR にして返す
  agents/goal-owner.md       別のコンテキストで、ゴール案と次にやることを判断する
  agents/subgoal-verifier.md 別のコンテキストで、Check が本当に条件を試しているかを見る
gdd/                         使う側のリポジトリの状態
  goal.md                    北極星、成果と Check、前提
  subgoals/<slug>.md         サブゴール1件1ファイル（並列でも衝突しない）
```

導入は `/plugin marketplace add b4tchkn/polaris` → `/plugin install polaris@polaris` → `/polaris:gdd-init` → `/polaris:gdd-loop`。このリポジトリ自身も `claude --plugin-dir plugins/polaris` で同じように進める。

## 借りる既存手法

- 仕様 → 計画 → タスク：GitHub Spec Kit https://github.com/github/spec-kit
- 進捗をファイルに持ち越すループ：Anthropic「Effective harnesses for long-running agents」 https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
- 作る役と評価する役を分ける：https://www.anthropic.com/engineering/harness-design-long-running-apps
- 確定的なチェックを優先する：Böckeler「Harness engineering for coding agent users」 https://martinfowler.com/articles/harness-engineering.html
- 機械チェックだけの変更は後から読む：Wilsenach「Ship / Show / Ask」 https://martinfowler.com/articles/ship-show-ask.html

## 経緯

- **2026-10-05〜11**：PR を人間がマージする形で作り、状態の1件1ファイル化、`Check:` と gate、goal-owner、worker の並列化を入れた。
- **2026-10-14**：PR 待ちで止まるのを嫌い、PR を使わず手元の main に取り込む形にした。作業が手元にしか無く、PC が壊れると失われる問題が残った。
- **2026-10-15**：サブゴールごとに PR を作る形に戻す案を書いた（PR #12、マージせず閉じた）。
- **2026-10-19（この版）**：実装が 700 行を超え、hook、状態や書式を出すスクリプト、細かい手順で、メインの流れが見えなくなっていた。eli5 にならい、メインの流れの最低限だけにした。hook の役は「main は PR でしか変わらない」と「テストや goal.md を変えた PR は人間がマージする」に置き換えた。
