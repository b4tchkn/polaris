# State

> AI が毎周、1ページ以内に書き直す。

## 現状

- M2（gdd-loop を作る）を終え、`gdd/reports/M2.md` の判断待ち。

## 出来たもの

- `gdd-init` skill と状態ファイルの雛形（goal.md / subgoals.md / state.md）
- `gdd-loop` skill とサブゴール完了報告の雛形（`templates/report.md`）
- design.md：予算・constraints.md の廃止、用語の統一、`gdd/reports/` の追加を反映
- CLAUDE.md：このリポジトリの前提（design.md に従う、骨格は既存手法から借りる）

## 判断ログ

- 予算の概念は不要。全体から削除した。
- constraints.md は廃止。境界は削除し、前提は goal.md（ゴール固有）と CLAUDE.md（このリポジトリ全体）に置く。
- 大ゴールの切り替え時も `gdd-init` で状態ファイルを作り直す。
- 用語は「サブゴール」「サブゴール完了報告」に統一する（subgoals.md のタイトル `# Sub-goals` は残す）。
- サブゴール完了報告は `gdd/reports/M<N>.md` に置き、末尾の「判断」欄に人間が書く。空なら次に進まない。
- Loop / 報告 / 振り返りは `gdd-loop` 1本にまとめる。

## 却下された案

- 予算（周回数、コスト）による上限
- constraints.md と「境界」
- Loop / 報告 / 振り返りを別々の skill にする
- gdd-init をシェルスクリプトで作る

## 学び

- 用語は「サブゴール」を使う。「マイルストーン」「Sub-goal」「ゲート報告」は使わない。
- goal.md / subgoals.md は Edit ツールで書く（Bash で書くと ask の承認を通らない）。
- push は sandbox から通らないので、人間に `! git push origin main` を頼む。
