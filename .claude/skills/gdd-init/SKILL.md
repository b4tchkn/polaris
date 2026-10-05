---
name: gdd-init
description: Goal Driven Development の状態ファイル（gdd/goal.md, gdd/subgoals.md, gdd/state.md）を雛形から生成し、goal.md / subgoals.md の書き込みに人間の承認を求める ask ルールを .claude/settings.json に追加する。Use when GDD を新規・既存リポジトリに導入するとき、Template から作った直後に状態を空にするとき、大ゴールをアーカイブしたあと新しいゴールを始めるとき。「gdd-init」「GDD を導入」「状態を初期化」。
---

# gdd-init

## 手順

1. `gdd/` に `goal.md` / `subgoals.md` / `state.md` のどれかがすでにあれば、上書きする前に人間に確認する。断られたら止める。
2. このスキルの `templates/` にある `goal.md` / `subgoals.md` / `state.md` を、そのまま `gdd/` に書き出す。
   - `gdd/archive/` には触らない。無ければ作らない（初めてゴールが完了したときに作る）。
3. `.claude/settings.json` の `permissions.ask` に次の2つを追加する。
   - `Edit(/gdd/goal.md)`
   - `Edit(/gdd/subgoals.md)`
   - ファイルが無ければ作る。既存のキーやルールは消さずにマージし、同じルールがすでにあれば追加しない。
4. 作成・変更したファイルの一覧を報告して止める。commit はしない。
