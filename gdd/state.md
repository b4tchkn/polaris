# State

> AI が毎周、1ページ以内に書き直す。学びは消さない。

## 現状

- SG5（シミュレーションを回せるようにする）を終え、`gdd/reports/SG5.md` の判断待ち。

## 出来たもの

- `gdd-init` / `gdd-loop` skill と雛形。どちらも対象ディレクトリを引数で受け取れる（例：`simulations/morning-review`）
- `gdd-loop`：改善の提案（4種類、番号付き、採用したものだけ反映）、学びは消さない、判断は AskUserQuestion で選んでもらう（6）
- `.claude/hooks/guard-gdd-writes.sh`：Bash から `gdd/goal.md` / `gdd/subgoals.md` への書き込みを止める
- `.claude/settings.json`：`gdd/state.md` を allow。`gdd/` と `simulations/**/gdd/` の goal.md / subgoals.md を ask
- `simulations/morning-review/gdd/`：雛形一式（commit しない）
- design.md：セクション5 を改善ループに書き直した。「ゲート」を使わない言い方に統一した
- CLAUDE.md（前提、コミットメッセージ）、CLAUDE.local.md（commit しない。固有名詞のルール）

## 判断ログ

- 予算の概念と constraints.md は廃止。前提は goal.md（ゴール固有）と CLAUDE.md（リポジトリ全体）に置く。
- 大ゴールの切り替え時も `gdd-init` で状態ファイルを作り直す。
- 用語は「サブゴール」「サブゴール完了報告」「サブゴール完了時の判断」。番号は SG。
- サブゴール完了報告は `gdd/reports/SG<N>.md`。Loop / 報告 / 振り返りは `gdd-loop` 1本。
- state.md は承認なしで書ける。reports/ は対象にしない。
- SG3 → 方向転換：`simulations/` で題材を1つずつ GDD で回し、振り返りを GDD 本体の改善に使う。1つ目は「朝に昨日を振り返り、今日やることを提案する skill」。動くところまで作る。判断は人間。`simulations/` は commit しない。
- 学びは将来のハーネスの元なので消さない。振り返りを改善ループにする（SG4）。
- 判断欄は毎回 AskUserQuestion で選択肢を出して人間に選んでもらい、答えを AI が書く。
- SG4 → 次へ進む。改善の提案 1, 3, 4 を採用（2 は不採用）。
- シミュレーションの ask ルールは個別ではなく `simulations/**` でまとめて効かせる。
- 公開リポジトリから勤務先の固有名詞を消し、履歴も書き換えた。作者メールは GitHub の noreply。

## 却下された案

- 予算（周回数、コスト）による上限
- constraints.md と「境界」
- Loop / 報告 / 振り返りを別々の skill にする
- gdd-init をシェルスクリプトで作る
- `gdd/reports/` の書き込みも allow に入れる（頼まれた範囲を超えていた）
- 題材3案（1on1 メモ / 消耗品の在庫 / あとで読む）
- 複数のシミュレーションを一度に回す（人間の判断が追いつかない）
- 判断ログに転記済みなら 2 を飛ばす（SG4 の提案2）
- シミュレーションごとに ask ルールを足す

## 学び

- 用語は「サブゴール」を使う。「マイルストーン」「Sub-goal」「ゲート」「ゲート報告」は使わない（「サブゴール完了時の判断」と言う）。
- goal.md / subgoals.md は Edit ツールで書く（Bash で書くと ask の承認を通らない）。→ ハーネス化済み：`.claude/hooks/guard-gdd-writes.sh`
- push は sandbox から通らないので、人間に `! git push origin main` を頼む。
- 権限や設定の変更は、頼まれた範囲だけにする。
- 人間に伝わりにくい言葉（「ゲート」など）は使わず、何が起きるかで言う。
