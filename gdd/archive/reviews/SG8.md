# サブゴールレビュー：SG8 polaris を plugin にする

## 何が出来たか、どう触るか

- エンジンを `plugins/polaris/` に移し、英語の plugin にした（`gdd-init` / `gdd-loop` skill、雛形、hook、`plugin.json`）。このリポジトリ自体を `.claude-plugin/marketplace.json` でマーケットプレイスにした。MIT ライセンスを付けた。
- README に入れ方（`/plugin marketplace add` → `/plugin install`）と始め方（`gdd-init` → `gdd-loop`）を書いた。
- 判断4件を `gdd/adr.md` に残した（エンジンの置き場所、plugin の言語、使う人の言語の決め方、ライセンス）。
- デモ：別の空ディレクトリで `claude --plugin-dir <polaris>/plugins/polaris` を起動し、`/polaris:gdd-init` → `/polaris:gdd-loop`。
- AI 側で確認できたこと：`claude plugin validate` が manifest / skills / marketplace とも通過。別ディレクトリから headless で起動すると `/polaris:gdd-init` が認識されて skill が動き出し、AI が `cp` で雛形を置こうとしたのを plugin の hook が止めた。

## 評価基準での振り返り

| 評価基準 | 定量 / 定性 | 結果 | 達成したか |
|---|---|---|---|
| 別のディレクトリで `/polaris:gdd-init` と `/polaris:gdd-loop` の両方が起動できる | 定量 | `gdd-init` は起動し hook も効いた。ファイルの書き込み完了と `gdd-loop` の起動は、この sandbox の headless 実行では Write が拒否されるため AI 側で確認できていない。人間が完了と判断 | 一部（人間の判断で完了） |
| README だけで、初めての人が入れ方と始め方をわかる | 定性 | 人間の判断 | 人間の判断で完了 |

## 一番自信がない判断

- plugin の雛形は作業ディレクトリの外（plugin のディレクトリ）にあるので、使う側の設定によっては `gdd-init` が雛形を読むときに確認が出る、または読めない。headless 実行では実際に読めなかった（`--add-dir` を足すと読めた）。対話実行なら1回の確認で済むはずだが、使う側の環境で試すまでわからない。

## 捨てた案

- リポジトリ直下をそのまま plugin にする、`.claude/` に残して配布用にコピーする：人間が B（`plugins/polaris/` に移す）を選んだ（`adr.md`）。
- 説明文と README だけ英語にする：人間が C（全部英語、返す言葉は使う人に合わせる）を選んだ（`adr.md`）。
- Template Repository を併設する：SG7 で plugin だけに決めた。

## 人間への質問

- 別ディレクトリで `/polaris:gdd-init` → `/polaris:gdd-loop` を実際に動かしたとき、雛形の読み取り確認は出ましたか（出たなら gdd-init の案内に1行足します）。

## 振り返り

| 項目 | 内容 |
|---|---|
| 続けること | `claude plugin validate` で機械的に確かめてから、本来の起動方法で試した。本来の起動方法で試したことで、hook が plugin でも効くことと、雛形の読み取りの件が見つかった |
| 問題 | headless 実行では Write が拒否され、AI 側で完了条件を最後まで確かめられなかった。SG8 の途中で Human-on-the-loop の評価（別作業）が長く入り、`state.md` の「現状」が SG7 のまま残っていた。評価の結果、design.md 7 の「機械的に判定する」が指示文のままだとわかり、「その先」を並べ直した |

## 改善の提案

| # | 種類 | 内容 | 反映先 | トレードオフ |
|---|---|---|---|---|
| 1 | 仕組みの修正 | design.md 0 に Human-on-the-loop の定義を1行足す：「AI は既定で進む。人間が関わるのはサブゴール完了時と機械的な停止条件に当たったときだけ。いつでも止めて覆せる」（Feng・McDonald・Zhang 2025 の L4 Approver に相当） | `docs/design.md` 0 | 用語のぶれが消え、SG9〜SG12 の目標がはっきりする。設計の行が1つ増える |
| 2 | 仕組みの修正 | gdd-init の案内に「雛形の読み取り確認が出たら許可してください」を1行足す | `gdd-init` SKILL.md 3 | 初めての人が止まらない。実際に出るかは未確認なので、質問の答えを待って決めてよい |
| 3 | 仕組みの修正 | gdd-loop 手順3の最初に、`state.md` の「現状」を「SG<N> 作業中」に書き換える1行を足す | `gdd-loop` SKILL.md 3 | 途中で止まっても再開時に現状がわかる。書き込みが1回増える |

## 次のサブゴールの提案

| 案 | ゴール | 種類と完了条件 | 評価基準（定量 / 定性） | 見せるもの | トレードオフ |
|---|---|---|---|---|---|
| A | SG9 機械的な停止条件を実装する | 作る系。戻せない行為（依存追加、マイグレーション、公開・送信、`.claude/settings.json`、design.md）が ask で止まり、goal.md / subgoals.md への Bash 書き込みは差分で検知して巻き戻し、`state.md` の学びの削除・`adr.md` の書き換え・テストの skip 追加を hook が止める | 定量：前回の敵対的レビューで通った 25 パターンのうち、goal/subgoals 書き込みの全経路が止まる。定性：止まった理由の文を見て人間が何をすべきかわかる | hook に意図的に書き込みを流して止まる様子と、ask ダイアログ | 聞かずに進んでも戻せないことは起きない、が初めて成り立つ。公開が1つ遅れる |
| B | SG10 を先に：GitHub で公開し、既存のリポジトリに入れて 1→100 を試す | 作る系。`/plugin install` で入り、既存リポジトリでサブゴールを1つ回せる | 定量：サブゴール1つ完了。定性：README だけで始められたと人間が言える | 既存リポジトリでのレビューと adr.md | 受け入れシナリオ2と5に早く届く。停止条件が指示文のまま公開される |
| C | SG9 を小さく：hook の差分検知＋巻き戻しだけ | 作る系。goal.md / subgoals.md が Bash 経由で変わったら戻して止める | 定量：25 パターンすべて止まる。定性：なし | hook の動作 | 1日で終わる。ask ルールの追加と不変条件は次に回るので、「聞かずに進める」条件はまだ揃わない |

## 判断

<!-- 人間が選んだ答えを gdd-loop が書く：次へ進む / 方向転換 / やめる（方向転換ならコメントも）。採用する改善の提案の番号も書く（例：採用 1, 3） -->
次へ進む（SG8 は人間の判断で完了）。次は A（SG9 機械的な停止条件を実装する）。採用 1。追加の指示：定義は plugin の中にも書く → README と design.md に書き、`gdd-loop` の SKILL.md には SG12 で手順を変えるときに入れる。2, 3 は不採用（AskUserQuestion で選択）。
