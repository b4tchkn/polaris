# サブゴール完了報告：SG5 シミュレーションを回せるようにする

## 何が出来たか、どう触るか

- `gdd-init` / `gdd-loop` が対象ディレクトリを引数で受け取れるようにした。渡すと `gdd/` を `<ディレクトリ>/gdd/` と読み替え、作るものもそのディレクトリに置く。
- `.gitignore` に `simulations/` を足した（commit されないことを `git check-ignore` で確認した）。
- `.claude/settings.json` の ask に `Edit(/simulations/**/gdd/goal.md)` と `Edit(/simulations/**/gdd/subgoals.md)` を足した。どのシミュレーションでも goal.md / subgoals.md の書き込みに承認が入る。
- `simulations/morning-review/gdd/` に雛形一式（goal.md / subgoals.md / state.md）を作った。
- （SG4 で採用した提案1）`.claude/hooks/guard-gdd-writes.sh`：Bash から goal.md / subgoals.md に書き込むコマンドを止める。読むだけのコマンドは通す。`simulations/` の下も対象。実際に止まることを確認した。
- デモ：`/gdd-loop simulations/morning-review` で1つ目のシミュレーションが始まる。

## 一番自信がない判断

- シミュレーションの中も、リポジトリのルートの `.claude/` と `CLAUDE.md` のまま動かすこと。シミュレーションで作る skill を試すとき、polaris 自身の skill や設定と混ざるかもしれない。

## 捨てた案

- シミュレーションごとに ask ルールを足す：人間の指示で `simulations/**` にまとめた。
- シミュレーションの中に `.claude/` を丸ごとコピーする：エンジンの修正が二重になる。

## 人間への質問

- なし（改善の提案 1 と 2 で選んでください）

## 振り返り

| 項目 | 内容 |
|---|---|
| 続けること | hook を入れたあと、読むコマンドと書くコマンドを並べて試し、すり抜け（`perl -CSD -i`）を見つけて直した。本番のコマンドで止まることも確かめた |
| 問題 | ask ルールをシミュレーション1つ分だけ足そうとして却下された。SG4 の判断のあと、判断ログへの転記を先回りして書き、手順どおりにするため戻した |

## 改善の提案

| # | 種類 | 内容 | 反映先 |
|---|---|---|---|
| 1 | 仕組みの修正 | goal.md / subgoals.md が雛形のまま（`<ゴール名>` が残っている）なら、`gdd-loop` はサブゴールを進める代わりに goal.md と SG0 の案を書き、AskUserQuestion で選んでもらう。今のままだと、シミュレーションの最初の `/gdd-loop` で何もできない | `gdd-loop/SKILL.md` |
| 2 | 学びのハーネス化 | シミュレーションの state.md も毎周承認が要る状態なので、`Edit(/simulations/**/gdd/state.md)` を allow に足す（polaris 本体の state.md と同じ扱い） | `.claude/settings.json` |
| 3 | 学びの追加 | 権限のルールは、対象が増えそうなら個別ではなく、まとめて効く書き方（`**`）にする | `state.md` の学び |

## 次のサブゴールの提案

| 項目 | 内容 |
|---|---|
| ゴール | SG6 シミュレーション1（朝の振り返り skill）を動くところまで回す |
| 種類と完了条件 | 作る系。`/gdd-loop simulations/morning-review` をくり返し、朝に実行すると昨日の出来事の振り返りと今日まずやることが出る skill が動く。シミュレーションの中の判断はすべて人間が選ぶ |
| 見せるもの | シミュレーションの報告一式と、skill を実行した結果 |

## 判断

<!-- 人間が選んだ答えを gdd-loop が書く：次へ進む / 方向転換 / やめる（方向転換ならコメントも）。採用する改善の提案の番号も書く（例：採用 1, 3） -->
次へ進む。採用 1, 2（AskUserQuestion で選択）
