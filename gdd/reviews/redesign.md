---
subgoal: redesign
loop: 20
progress: new-repo=human existing-repo=human judge-without-code=human retro-reflected=observe published=not-met gate=met open_uncertainties=2
---
# Sub-goal review: redesign 設計の見直し（PR #4）

## What was built and how to try it

- `docs/redesign-plan.md` の改修を `feat/redesign` に実装した。サブゴールの状態は PR とファイルの `status:` で表し、main へは PR でしか入れない。`state.md` は未確定事項のファイル（`gdd/uncertainties/`）とレビューの学びに分けた。リファインメント（`steps/refine.md`）を足した。
- 以前の `state.md` は `gdd/archive/state-before-redesign.md` に残した。

## Checks

| Condition | Check | Result | By |
|---|---|---|---|
| gate | `bash tests/check.sh` | met | gdd-check.sh |

## Distance to the goal

- new-repo=human existing-repo=human judge-without-code=human retro-reflected=observe published=not-met gate=met open_uncertainties=2

## Least confident

- None

## Retrospective

- Keep: シミュレーション（Docker サンドボックス）で見つけた問題を直してから次を回した
- Problems: None
- Candidates added: none

## Learnings

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
