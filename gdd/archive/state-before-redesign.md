# State

> AI が毎周、1ページ以内に書き直す。学びは消さない。

## 現状

- 2026-10-10：`docs/redesign-plan.md` の改修を実装（ブランチ `feat/redesign`）。`subgoals.md` は `gdd/subgoals/` の1件1ファイルに移した。eval は18ケースに書き直したが未実行（人間が流す）。候補は sg20（ヒルクライミング。19ケース前提の記述は着手時に直す）、sg15、sg10。
- SG19 完了（19ケース pass、対応表に未カバーなし）。
- 2026-10-07 に Human-on-the-loop の多視点レビューと4シナリオのシミュレーションを行い、「その先」を機械的な停止条件 → 公開 → 評価の独立 → 続く既定の順に並べ直した。定義は README と design.md 0（SKILL.md には SG12 で）。

## 出来たもの

- `plugins/polaris/`：英語の plugin（`gdd-init` / `gdd-loop` skill、雛形、hook）。`.claude-plugin/marketplace.json` でこのリポジトリ自体がマーケットプレイス。`claude plugin validate` は manifest / skills / marketplace とも通過。MIT ライセンス
- `gdd-init` / `gdd-loop`：対象ディレクトリを引数で受け取れる。改善の提案（4種類）、学びは消さない、判断は AskUserQuestion、ゴールが雛形のままなら一緒に決める、案はいつも3つ（トレードオフ付き）、選ぶたびに理由を `gdd/adr.md`、外のデータは先に実データで試す、本来の起動方法で確かめる、評価基準（定量 / 定性）で振り返る
- `plugins/polaris/hooks/guard-gdd-writes.sh`（SG9）：Bash / Edit / Write の前に `gdd/` の状態ファイルを控え、後に結果を比べる。goal.md / subgoals.md の Bash 書き込み、学びの削除、adr.md の書き換えは元に戻して exit 2、テストへの skip 追加は exit 2。`tests/guard-gdd-writes.sh` で 20 ケース
- `gdd-init`（SG9）：戻せない行為（依存の追加、マイグレーション、push / PR マージ / release、履歴の書き換え、settings の変更）の ask ルールを使う側の settings.json に書く
- `gdd-loop` 手順5・7（SG13）：「その先」が空なら受け入れシナリオごとの結果を書き、GOAL 達成に見えると伝えて「サブゴールを足す / 完了報告（`gdd/reviews/GOAL.md`）を書く」を聞く。試験用 `simulations/goal-done/gdd/`（commit しない）
- `plugins/polaris/agents/evaluator.md`（SG11）：評価基準と成果物の場所だけを受け取り、自分で測って基準ごとの表を返す。`gdd-loop` 5 が `polaris:evaluator` を呼び、表をそのまま貼る。試験用 `simulations/eval-test/gdd/`（commit しない）
- `gdd-loop` 7（SG12）：作る系で evaluator の表が全行「達成」なら人間に聞かず「次へ進む（自動）」として手順2へ。冒頭に Human-on-the-loop の1文。試験用 `simulations/auto-test/gdd/`（commit しない）
- `plugins/polaris/evals/`（SG19 で19ケース）：ambiguous-comment（3案は LLM 判定）、stop-data-model、evaluator-verdict、init-existing、apply-proceed にハーネス化の印。SG18 時点：決める系、方向転換、提案の採用、依存で止まる、言語、history_file で人間の答えを再現する3つ（初回の答え、完了報告、見送り）、案を選んで adr。指示との対応表は `gdd/archive/reviews/SG18.md`。SG17 時点の6ケース：`init`、`first-run`、`apply-proceed`、`apply-stop`、`auto-continue`（SG0・SG1 が自動で進み SG2 で止まる）と `goal-reached`（「その先」が空で GOAL 達成の2択）。scaffold_script が試験用 `gdd/` を作り、graders が a.txt / b.txt とレビューの判断欄を見る。README に走らせ方
- design.md と plugin の対応表（SG14）：`gdd/archive/reviews/SG14.md`。入っている 14、一部 6、無い 6（予定無しはアーカイブ一式、大きさの指針、典型的な並び、N 周無変化）
- `.claude/settings.json`：どこの `gdd/state.md` も allow。`gdd/` と `simulations/**/gdd/` の goal.md / subgoals.md を ask
- design.md：改善ループ（5）、3案と adr.md（3）、アーカイブ前に学びを雛形へ移す（6）。README：入れ方と始め方
- シミュレーション1 `simulations/morning-review/`（commit しない）：SG0〜SG3 を回し、`/morning-review` で動いた

## 判断ログ

- 予算の概念と constraints.md は廃止。前提は goal.md と CLAUDE.md に置く。
- 大ゴールの切り替え時も `gdd-init` で状態ファイルを作り直す。
- 用語は「サブゴール」「サブゴールレビュー」「サブゴール完了時の判断」。番号は SG。
- state.md は承認なしで書ける。reviews/ は対象にしない。
- SG3 → 方向転換：`simulations/` で題材を1つずつ回す。`simulations/` は commit しない。
- 学びは消さない。振り返りを改善ループにする（SG4）。判断欄は毎回 AskUserQuestion。
- SG4 → 提案 1, 3, 4 採用。SG5 → 提案 1, 2 採用。SG6 → 次は SG7、提案1を修正して採用（毎回理由を聞く、案にはいつもトレードオフ）。SG7 → 提案 1, 2 採用、配り方は plugin だけ、次は SG8。
- SG8：エンジンは `plugins/polaris/` に置く（B）。配るものは全部英語、返す言葉は使う人に合わせる（C）。言語は環境から推測する（B）。ライセンスは MIT（すべて `gdd/adr.md`）。
- 公開リポジトリから勤務先の固有名詞を消し、履歴も書き換えた。作者メールは GitHub の noreply。
- 2026-10-07：Human-on-the-loop の評価の結果、「その先」を SG9 機械的な停止条件 → SG10 公開 → SG11 評価の独立 → SG12 続く既定に並べ直した（人間の指示で即反映）。介入タイミングの設定（goal.md の1行、policy.md）は見送り。
- SG8 → 人間の判断で完了（本来の起動方法での最終確認は人間側で行う）。次は SG9。改善の提案1（定義を1行）を採用、README と design.md に書き SKILL.md は SG12 で。2, 3 は不採用。
- SG9：ask ルールの広さは標準（design.md 7 の項目をファイルとコマンドに対応させる）。理由「design.md 7 に書いた項目は全部機械的に止めたい」（`gdd/adr.md`）。
- SG9 → 次へ進む。次は SG13（GOAL 完了の流れ）。理由「公開前にユーザーが見る動きを揃えたい」。改善の提案 1, 2 は見送り（人間の指示。以後聞かない）。
- SG13 → 次へ進む（起動確認は人間が後で行う）。次は SG14（design.md と plugin の差の洗い出し）。理由「公開前に仕様の抜けを見ておきたい」。改善の提案 1（答えなかった判断は見送りと書く → `gdd-loop` 7）、2（SG14 に hook の論点）を採用。
- SG14 → 次へ進む。アーカイブ一式を SG15 として追加（典型的な並び、N 周無変化は足さない）。SG10 の公開は人間が行い、AI は公開までの plugin 整備だけ。次は順番どおり SG11。理由「サブゴールを順番にやりたい」。提案 2（大きさの指針 → `gdd-loop` 5）を採用、1（design.md の文言）は見送り。
- SG11 → 次へ進む（起動確認済み）。次は順番どおり SG12。提案 1（評価基準の書き方）を採用。
- SG12 → 次へ進む（起動確認済み）。次は順番どおり SG17。提案 1（既にある仕組みで止まるものは条件に書かない）を採用。
- SG17 → 次へ進む（6ケース pass）。次は順番どおり SG15（着手は人間の指示待ち）。提案 1（長い作業は分けて伝える）を採用。
- 2026-10-09：人間の割り込みで SG18（全挙動を eval で）を追加して着手。SG18 → 次へ進む。次は SG19（未カバー8つ）→ SG20（ヒルクライミング）。理由「未カバーを残したままヒルクライミングに入らない」。提案 1（fixture の文は解釈が1つに決まるように）、2（未カバーをサブゴールに）を採用。
- SG19 → 次へ進む（19ケース pass）。次は SG20 ヒルクライミング。理由：安全網が揃った。提案 1（自由文は LLM 判定）、2（fixture は本物の流れ）を採用。

## 未確定事項

- U1 worker サブエージェント（`isolation: worktree`）と background 実行は、eval と実セッションで想定どおり動くか | open
- U2 聞かずに進む条件（直近3件、停滞3件、大きさの上限）は、聞かれすぎ / 聞かなさすぎのどちらにも偏らないか | open

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
- 「権限はまとめて効かせる」を学びに足す（SG5 の提案3）
- 決める系の見本を2案にする（3案にそろえた）
- settings.json の allow 変更が効くタイミングを学びに足す（SG6 の提案2）
- シミュレーションの回し方を design.md に書く（SG6 の提案3）
- 「報告の数字は一覧から数える」「採用された範囲だけ反映する」を手順に入れる（SG7 で選ばれなかった）
- Template Repository を作る（plugin だけにした）
- 介入タイミングを goal.md の1行（ゴール達成時 / サブゴール達成時 / 判断時 / 編集時）や policy.md で設定する（聞かれすぎた実績がない、停止条件が未実装、`ゴール達成時` は design.md 4 条件1と矛盾、却下ゼロで自律度を上げる提案は Goodhart）

## 学び

- 用語は「サブゴール」を使う。「マイルストーン」「Sub-goal」「ゲート」「ゲート報告」は使わない（「サブゴール完了時の判断」と言う）。
- goal.md / subgoals.md は Edit ツールで書く（Bash で書くと ask の承認を通らない）。→ ハーネス化済み：`plugins/polaris/hooks/guard-gdd-writes.sh`
- push は sandbox から通らないので、人間に `! git push origin main` を頼む。
- 権限や設定の変更は、頼まれた範囲だけにする。
- 人間に伝わりにくい言葉（「ゲート」「床」など）は使わず、何が起きるかで言う。design.md 7 のものは「機械的な停止条件」と呼ぶ。
- 人間の指示を仕組みに落とすとき、解釈が分かれる点（数、範囲、どこに書くか）は書く前に確かめる。→ 反映済み：`gdd-loop` の 2
- 作る系の完了は、作ったものを本来の起動方法（skill なら `/<名前>`）で動かして確かめる。AI が会話の中で手順をなぞっただけでは完了にしない。→ 反映済み：`gdd-loop` の 3。起動確認が人間待ちのまま完了にしない（SG8、SG13 で漏れた）。動きを変えたら、それを説明している場所（README、他の skill の文）も同じサブゴールで直す。
- 完了条件に使うデータ（期限など）は、サブゴールを決める前に実データで存在を確かめる。→ 反映済み：`gdd-loop` の 3
- サブゴールには評価基準（定量 / 定性）を決め、完了報告でその基準で振り返る。→ 反映済み：`gdd-loop` の 5、雛形、design.md 3
- `state.md` の学びはそのリポジトリでしか効かない。どの題材でも効く学びは、手順か雛形に移すまで「仕組みになった」とは言わない。
- ファイルを読む Bash は、入力待ちで止まらないように `</dev/null` を付け、ファイル名が空でないか確かめる。
- design.md 7 の「機械的に判定する」は SKILL.md の指示文のままで、hook も ask ルールも無い。これが無い限り、人間に聞く回数を減らすことは AI の自己申告を信じることと同じになる。順序は停止条件 → 評価の独立 → 続く既定。→ 一部ハーネス化済み：SG9（`gdd-init` の ask ルール、`guard-gdd-writes.sh`）。残りは design.md 7 の末尾に列挙
- 仕組みを足すときは、既にある仕組み（ask、hook、評価表の空欄、見送りルール）で止まるものを条件に書かない。1文で言えない条件は多すぎる。SG12 で条件を4つ書き、2つは不要だった。
- eval の実行では AskUserQuestion が使えず（AI は文章で聞く）、`.claude/settings.json` への書き込みは拒否される。これらはグレーダーで「返答の文」「書こうとした」を見る。
- eval が plugin の指示の曖昧さを2つ見つけた（完了セクションの形式、gdd-init の書き方）。挙動を足したら eval のケースも足す。
- 長い作業は小さなコマンドに分け、合間に一言伝える（1コマンドが数分かかると人間には止まって見える）。ディレクトリごとの再帰削除は使わず、消すファイルを個別に指定する（人間側の hook が止める）。
- eval で返答の自由文を見るグレーダーは、最初から LLM 判定（`type: llm`、判定モデルの多数決）にする。正規表現はファイルの中身とツール呼び出しに使う（ambiguous-comment で正規表現が3回落ちた）。
- eval の fixture は本物の流れをそのまま再現する（人間が決めた → AI が動く）。結果だけを置いて AI に察させない（apply-proceed の hardened で CLAUDE.md を置くだけの fixture が落ちた）。
- eval の fixture に書く人間のコメントや答えは、解釈が1つに決まる文にする。曖昧だと AI が正しく聞き返して（手順2の3案）落ちる。
- eval の history_file は本物のセッション記録と同じ構造の .jsonl（sessionId / uuid / parentUuid 付き）なら動く。AskUserQuestion と settings.json 書き込みは eval では使えない。
- eval の `history_file` を使うケースは、実行後にケースのディレクトリへ本物のセッション記録（`<sessionId>.jsonl`）を書き戻す。セッション記録には個人情報が記載される可能性があるので commit しない（`.gitignore` 済み）。commit 前のチェックは `git add` の後に `git grep --cached` で行う（`git grep` は未追跡ファイルを見ない）。
- hook はカレントディレクトリに依存させない。`CLAUDE_PROJECT_DIR` に `cd` してから探す。相対パスの `find .` で実行前リストを作っていたため、cwd が変わった1回で全 goal.md / subgoals.md（10ファイル）が消えた（SG12）。テストは「別のディレクトリから pre を流す」ケースを含める。→ ハーネス化済み：`guard-gdd-writes.sh` 冒頭、`tests/guard-gdd-writes.sh`
- 消す・戻す hook は、消す前の控えを残す。10ファイルの復旧はこの控えからできた。
- Bash コマンドの文字列を見るブロックリストは負ける（25 経路中 6 しか止まらなかった）。止めたいのは結果なので、実行前に控えて実行後に比べて戻す。
- hook は本物と同じ形の JSON を流すテストを先に通してから報告する（`tests/guard-gdd-writes.sh`）。この sandbox からは Claude Code に hook を読み込ませた確認ができないので、そこは人間に頼む。
- 判断を「未判断・持ち越し」で記録しない。人間が答えなかった、または対応不要と言ったら「見送り」として確定し、同じことを二度と聞かない。→ 反映済み：`gdd-loop` の 7
- design.md の流れを plugin に入れるときは、全段階を一度に入れず、今の GOAL で実際に通る段階だけ入れる（SG13 は design.md 6 の①だけ）。
- 評価基準は、evaluator が成果物だけを見て測れる形で短く書く（レビュー自身や採点者を参照しない。確かめ方は結果欄に）。SG11 で採点者が自分の出力を採点する循環になった。
- アーカイブを実装するときは hook と衝突する：state.md の雛形上書きは「学びの削除」、adr.md の雛形書きは「書き換え」として戻される。学びの削除判定を `gdd/archive/*/state.md` にある行は除く形に直し、adr.md は GOAL をまたいで1本にする（harness-engineering-reviewer の指摘）。
- 介入頻度の設定は、人間が「聞かれすぎた」と記録に残すまで作らない。介入頻度のノブは design.md 3 のサブゴールの粒度に既にある。
- この sandbox から headless（`-p`）で起動した Claude Code は Write ツールが一律に拒否される。本来の起動方法の確認は人間に頼む。
- plugin の雛形は作業ディレクトリの外にあるので、設定によっては gdd-init が雛形を読むときに確認が出る。
- サブゴールの途中で長い別作業（評価、調査）が入ると `state.md` の「現状」が古いまま残る。手順3の開始時に「現状」を書く方が安全。
