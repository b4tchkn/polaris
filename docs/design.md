# ゴール駆動・人間介在型 AI 作業環境 設計

> 2026-10-14 版。**設計はこの1ファイルだけ**。旧 `docs/redesign-plan.md`（2026-10-10、チームと PR を前提にした改修計画）はここに統合して削除した。経緯は「14. 経緯」、ここまでの実装からの移り方は「15. 移行計画」。

## 0. 目的

0→1 で新しく何かを作るとき（新しいアプリ、将来は事業なども）にも、1→100 で既にあるものを運用するときにも使える作業環境を作る。

人間が達成したいゴールを伝えると、AI がそこへ至るサブゴールを提案する。人間が承認したら、AI がスクラムのように反復と漸進を繰り返し、不確実性の高い問題を自律的に解いていく。人間は必要なときだけ聞かれる（Human-on-the-loop）。

```
GOAL ◀── サブゴール ◀── サブゴール ◀── サブゴール
          (Loop)       (Loop)       (Loop)   ← 依存しないものは並列
```

## 1. 原則

- **Human-on-the-loop**：AI は既定で進む。人間が関わるのは「4. 人間が関わる場面」だけで、いつでも止めて覆せる（Feng・McDonald・Zhang 2025「Levels of Autonomy for AI Agents」 https://arxiv.org/abs/2506.12469 の L4 Approver）。人間は毎ステップ承認する係にはならない。
- **人間の理解はコードではなく、ゴールと完了条件・判断・学びに集中させる**。実装は機械チェックが通れば人間は見なくてよい。その代わり、チェックの中身（完了条件）は作業前に人間が理解して承認する。チェックが甘いと、通っても間違ったものができるため。
- **完了はガードレールで決める**：テスト、lint、型チェック、ビルド、スクリプト、hook など確定的で再現できるチェックを優先する。AI の判断はチェックにできない部分の補助、人間は主観的なものだけ。AI は自信のある誤りに気づけないので、自己申告では止めない。
- **1人用**：1人の人間が、1つのメインセッションと、並列に開く複数のセッション（3つほど）で使う。チームでの共有は対象外（Claude Code の Projects も1人用で、チーム向けは別機能）。状態は git に入るので、結果として他の人が読むことはできる。
- **トランクベース**：長命ブランチは作らない。サブゴール1つごとに main へ取り込む。PR を関門にしない（使う場合も Ship/Show/Ask の Show：チェックが通れば AI がマージし、人間は後から読む）。
- **自作は判断と状態の層だけ**：何を始めるか、いつ人間に聞くか、達成したかの判断と、`gdd/` の状態は Polaris が持つ。セッションの起動と並列実行（サブエージェント、別ターミナルのセッション、将来は Projects のスレッド）は実行環境に任せる。
- **判断軸は「元に戻せるか」**。ガードレールはプロンプトではなくハーネス（sandbox、permissions、hooks、CI）で強制する。人間の介入はルール、テスト、hook の修正に変換する。
- **YAGNI**：今の問題を解くのに要らない仕組みは作らない。仕組みは増やすより削る。

## 2. 構成

エンジン（全プロジェクト共通）と状態（プロジェクトごと）を分ける。

```
plugins/polaris/                 エンジン（plugin として配る。英語で書き、返す言葉は使う人に合わせる）
  skills/gdd-init/               状態ファイルと承認ルールを作る
  skills/gdd-loop/               コーディネーター：状態を読み、次を決めさせ、配り、取り込む
    scripts/gdd-check.sh         チェックを実行する（ゴールまでの距離、またはサブゴールの Done when と gate）
    scripts/gdd-status.sh        各サブゴールの状態、着手できるもの、重なり、停滞（hold）を機械的に出す。ファイルと git だけを読む（gh は使わない）
    scripts/gdd-lint.sh          サブゴール、不確実性、レビューの書式を確かめる（hook が書き込みのたびに呼ぶ）
    steps/                       手順の詳細（ゴール設定、リファインメント）
  skills/gdd-work/               実行役：サブゴール1つを達成する。どのセッションからでも呼べる
  agents/goal-owner.md           判断役：ゴール案の審査、次に始めるもの、リファインメントの要否、待つか、達成したか
  agents/worker.md               gdd-work を worktree で呼ぶだけの薄い器（isolation: worktree）
  agents/subgoal-verifier.md     検証役：コマンドのチェックが本当に条件を試しているかと、observe: の判定だけ
  hooks/                         チェックを緩める変更、goal.md の Bash 書き込み、ADR の変更、学びの削除、書式違反を戻す
.claude-plugin/                  マーケットプレイス（/plugin marketplace add b4tchkn/polaris）
.claude/settings.json            使う側のリポジトリの制約（gdd-init が承認ルールを書く）
gdd/                             状態（使う側のリポジトリに gdd-init が作る。すべて main 上のファイル）
  goal.md                        北極星、受け入れシナリオと完成の定義（[id] と Check: 付き）、前提。書き込みは毎回人間が承認（ask）
  subgoals/<slug>.md             サブゴール1件1ファイル
  uncertainties/<name>.md        不確実性1件1ファイル。status: open | resolved と答え
  reviews/<slug>.md              サブゴールレビュー。Learnings は消さない（hook が戻す）
  adr/<YYYY-MM-DD>-<slug>.md     人間の判断1件1ファイル。書いたら変えない（hook が戻す）
  archive/                       完了した GOAL
docs/design.md                   この設計
```

- 1件1ファイルにするのは、並列のセッションが同じファイルを書いてマージで衝突しないため。各セッションは自分のサブゴール、レビュー、新しい不確実性と ADR だけを書く。
- `state.md` は持たない。今どこか・何ができたかは status から導き、学びはレビューに、却下された案は cancelled のサブゴールに置く。

### 配布方法

新規リポジトリ（0→1）も既存リポジトリ（1→100）も同じ手順にする。

1. `/plugin marketplace add b4tchkn/polaris` → `/plugin install polaris@polaris`
2. やりたいことのリポジトリで `/polaris:gdd-init`
3. `/polaris:gdd-loop`（止まるまで続けて進む）

このリポジトリ自身も `gdd/` に「基盤を作る」GOAL を入れ、`claude --plugin-dir plugins/polaris` で起動してドッグフーディングで進める。

## 3. 役割

| 役割 | 実体 | 動く場所 | やること |
|---|---|---|---|
| コーディネーター | skill `gdd-loop` | メインセッション（main のチェックアウト） | `gdd-check.sh` と `gdd-status.sh` を読み、`goal-owner` に次を決めさせ、サブゴールを配り、終わったものを main に取り込む。人間との対話はここ |
| 判断役 | subagent `goal-owner` | コーディネーターから呼ぶ | 作業する AI とは別のコンテキストで、ゴール案を審査し、次に何をするか決める |
| 実行役 | skill `gdd-work <slug>` | 任意のセッション（worktree） | サブゴール1つを達成し、取り込み待ちにする |
| 実行役の器 | subagent `worker` | コーディネーターから呼ぶ | `gdd-work` を呼ぶだけ。人間が別セッションを開くときは不要 |
| 検証役 | subagent `subgoal-verifier` | `gdd-work` から呼ぶ | コマンドのチェックの妥当性と `observe:` の判定。自己採点はしない |

- `goal-owner` の答えは `reached:` / `wait:` / `refine:` / `start: <slug>[, ...]` のどれか。次に選ぶ基準は「未達の受け入れシナリオを一番前に進めるもの、一番大きな不確実性を潰すもの」。人間が並べた順に消化する方式にはしない。並列に足すのは `gdd-status.sh` の overlaps が互いに空のものだけ。
- `gdd-work` は、サブエージェントからでも、人間が別ターミナルで開いたセッションからでも、同じ手順で動く。

## 4. 人間が関わる場面

これ以外では止まらない。

| いつ | 何を | どう |
|---|---|---|
| ゴールの設定・変更 | `goal.md`（シナリオと Check、gate） | `goal-owner` が審査し、ask ルールで人間が確定する |
| リファインメント | サブゴールの一覧と、各 Done when と Check | 不確実性について最大5問聞き、一覧を見せて AskUserQuestion で1回承認する |
| 決める系のサブゴール | 3案から選ぶ | コーディネーターのセッションで AskUserQuestion。理由を聞いて ADR に残す |
| `human:` のチェックを含むサブゴール | 主観の判定 | main に取り込む前に聞く（Ship/Show/Ask の Ask） |
| 戻しにくい判断、チェックを緩める変更 | 3案から選ぶ | ask ルールと hook が止める（9節）。`gdd-work` は聞けるなら AskUserQuestion、サブエージェントなら質問を返して止まる |
| 停滞（直近3件のレビューの progress が同じ） | 続ける / 変える / やめる | `gdd-status.sh` の `hold: yes` で、新しいサブゴールの前に1回聞く |
| `doing` のまま作業ブランチが無いサブゴール | 作り直すか | `gdd-status.sh` の `doing (no branch)` で聞く |
| ゴール達成 | 続ける / 完了報告を書く | `goal-owner` の `reached:` で聞く |

- 上のどれにも当たらない作る系のサブゴール（コマンドのチェックと gate がすべて通ったもの）は、聞かずに main に取り込む（Show）。人間は `gdd/reviews/<slug>.md` を後から読み、気になれば止めて覆す。
- 選択肢を出すときはいつも3案にし、選んだ結果で行動かトレードオフが変わるものにする。各案にトレードオフを1行書く。人間が選んだら理由を聞き、人間の言葉で `gdd/adr/` に残す。
- 質問はコードや専門用語を知らない人にもわかる言葉にする。

## 5. サブゴール

サブゴールは大ゴールを分解した段階的なゴール。1件ずつ `gdd/subgoals/<slug>.md` に置く。

```markdown
---
status: todo            # todo | doing | done | cancelled
type: build             # build（作る系）| decide（決める系）
advances: capture, storage-format   # 前に進める受け入れシナリオの id、不確実性の名前（必須。無いと hook が戻す）
depends_on: none        # 先に done になっている必要があるサブゴール
touches: src/todo/      # 変えるパス（並列にできるかの判定に使う。なるべく狭く）
---
# <このサブゴールで達成すること、1文>

## Done when
1. [id] <条件。エッジケースはここ>
   - Check: `<条件が成り立つと 0 で終わるコマンド>`   # または observe: … / human: …

## What to show
- <人間が後で見るもの>
```

- **作る系**：Done when のチェックと gate が通り、本当の入口（skill なら `/<name>`、アプリなら起動して使う）で動いたら完了。成果物は動くもの。
- **決める系**：仕様、方式、範囲などを人間が3案から選んだら完了。成果物は仕様書、モック、比較表など。
- **大きさ**：ゴールは1つ。外れたら丸ごと捨てても惜しくない量を上限にする。初期は小さく、方向が固まったら大きくする。
- **完了条件はリファインメントで書く**：作業前に人間が Done when とチェックを承認する。前提が変わったら、もう一度リファインメントする。

0→1 アプリでの典型的な並び（目安）：

| ゴール | 種類 | 見せるもの |
|---|---|---|
| 誰の何を解決するかを決める | 決める | 課題、ペルソナ、コア体験を1枚で |
| コア体験の画面仕様を決める | 決める | クリックできるモック |
| 技術構成とデータモデルを決める | 決める | 構成図と比較案 |
| コア体験1本を端から端まで動かす | 作る | walking skeleton のデモ |
| ユーザーストーリーを1つずつ実現する | 作る | ストーリーごとのデモ |

### 状態の遷移

```
todo ──(コーディネーターが配る：main で status: doing をコミット)──▶ doing
doing ──(gdd-work がブランチ gdd/<slug> で status: done をコミット)──▶ ready-to-merge（表示上の状態）
ready-to-merge ──(コーディネーターが main に取り込み、main で gate が通る)──▶ done
todo / doing ──(リファインメントで不要になった)──▶ cancelled（「Why cancelled」に理由を書く）
```

- ファイルに書く `status:` は `todo | doing | done | cancelled` の4つ。`ready-to-merge` は `gdd-status.sh` が「main では doing、ブランチ `gdd/<slug>` では done」から導く。
- 作業ブランチの名前は `gdd/<slug>` に固定する。これで状態を git だけから読める。
- `doing` を main に先にコミットしてから配るので、ブランチ側の `done` への変更は main の直系になり、衝突しない。
- 依存は、依存先が `done` になって初めて満たされる。
- `cancelled` は却下された案。同じ案を再提案しない。

## 6. ループ（コーディネーター）

1. `gdd-check.sh gdd` と `gdd-status.sh gdd` を実行する。
2. `hold: yes` や `doing (no branch)` があれば人間に聞く（4節）。
3. `ready-to-merge` のものを main に取り込む（8節）。
4. `goal-owner` に次を決めさせ、答えに従う。従わないときは人間に理由を言う。
   - `refine:` → リファインメント（`steps/refine.md`）。
   - `start:` → 各サブゴールを `doing` にして main にコミットし、配る。1つなら `worker` をフォアグラウンドで、複数なら `worker` をバックグラウンドで同時に。人間が別セッションで進めると言ったときは、そのセッションで `/polaris:gdd-work <slug>` を実行するよう伝える。決める系はコーディネーター自身が扱う。
   - `wait:` → 何を待っているか伝えて止まる。
   - `reached:` → 11節。
5. 報告が来たら 1 に戻る。止まるのは `wait:`、hold、人間への質問、`reached:` のときだけ。

- ゴールが雛形のまま（`<goal name>` が残っている）なら、まずゴール設定（`steps/set-goal.md`）をする：人間に質問し、`goal.md` の案と不確実性を書き、`goal-owner` に審査させ（最大2回直す）、人間が承認したらリファインメントで最初のサブゴールを書く。
- `gdd/` のコミットは対象を絞る：`git commit -m "docs(gdd): <slug> <what happened>" -- gdd/`。

## 7. サブゴール1つの達成（`gdd-work <slug>`）

1. worktree の中でブランチ `gdd/<slug>` にいることを確かめる（無ければ main から作る）。`git merge main` で最新にする。
2. Done when のコマンドのチェックのうち、まだ無いテストやスクリプトを先に書き、失敗することを確かめる。
3. `touches:` の範囲で作る。範囲外の変更、戻しにくい判断、チェックを緩める変更が要るなら止まって聞く（聞けなければ質問を返す）。`gdd/` は、自分のサブゴール、レビュー、新しい不確実性と ADR だけを書く。
4. `gdd-check.sh gdd <slug>` で、Done when と gate がすべて `met` になるまで直す。チェックは緩めない。`subgoal-verifier` に、コマンドのチェックの妥当性と `observe:` を判定させる。
5. `gdd/reviews/<slug>.md` を書く（Checks の表、ゴールまでの距離、Least confident、振り返り、Learnings）。答えが出た不確実性は `resolved` にし、新しい不確実性はファイルを足す。
6. サブゴールのファイルを `status: done` にしてコミットする。push はしない。
7. 報告する：ブランチ、作ったものと試し方、チェックの結果、Least confident（`file:line: 何が不安か、どう確かめるか`）、`human:` の条件の有無。

## 8. main への取り込み（コーディネーターが main のチェックアウトで行う）

1. main のチェックアウトに `gdd/` 以外の未コミットの変更があれば、人間に聞いて止まる。
2. `human:` の条件があれば、先に人間に聞く（4節）。
3. `git merge --no-ff gdd/<slug>`。衝突したら `git merge --abort` し、`gdd-work <slug>` に main を取り込んで直すよう戻す。
4. main で `[gate]` を実行する。並列の変更を合わせたときに壊れていないかを確かめるため。落ちたら `git revert -m 1 HEAD` で戻し（status も doing に戻る）、`gdd-work` に戻す。
5. 通れば完了。人間には1〜3行で、何が main に入ったかとレビューのパスを伝える。
6. `git push` は ask ルールで人間が承認する。

## 9. 検証とガードレール

- **チェック**：受け入れシナリオ、完成の定義、Done when はすべて `[id]` と `Check:` の組で書く。`Check:` はコマンドが原則（`gdd-check.sh` が実行し、0 で終われば met）。コマンドにできないものだけ `observe:`（`subgoal-verifier` が判定）、主観的なものだけ `human:`（人間が判定）。
- **gate**：`goal.md` の完成の定義にある `[gate]` は、フォーマッタ、lint、型チェック、ビルド、テストをまとめた1コマンド。全サブゴールがブランチで通し、取り込み後に main でも通す。CI でも回す。gate が無いプロジェクトでは最初のサブゴールで作る。
- **受け入れシナリオは人間が確定する**。AI は承認なしに書き換えられない（ask）。
- **止まる条件（機械的に判定する）**：
  - 戻しにくい判断：依存の追加、データモデル（マイグレーション）、リポジトリの外に出る操作（push、PR のマージ、release）、履歴の書き換え、settings の変更 → `gdd-init` が書く ask ルール。外部サービスの選定、課金、認証は今は指示文だけ。
  - チェックを緩める変更：テストへの skip 追加、テストの削除（Edit でも Bash でも）→ hook が戻す。受け入れシナリオの緩和、assert を弱める変更は今は指示文だけ。
  - 停滞：直近3件のレビューの progress が同じ → `gdd-status.sh` の hold。
- **状態ファイルの保護（hook）**：`goal.md` への Bash の書き込み、既存の ADR の変更や削除、レビューの削除や学びの削除、書式違反（`gdd-lint.sh`）を戻す。スナップショットはサブエージェントごと・worktree ごとに分け、並列でも混ざらないようにする。

## 10. 振り返りと学び

サブゴールが完了するたびに、`gdd-work` がレビューの中で振り返る。

```
今回のサブゴール ＋ reviews/ の学び全体
   ▼
振り返り（続けること / 問題：手戻り、人間が介入した箇所、チェックで決められたのに AI や人間が判断したもの）
   ▼
学び → そのサブゴールのレビューの Learnings に書く
それ以外の改善 → サブゴール（advances: process など）として次のリファインメントで積み、
                 ほかのサブゴールと同じ基準で選ばれたときに行う
```

- 学びは将来のハーネスの元になるので消さない（hook が戻す）。ハーネスに移した学びは、元のレビューを書き換えず、移したサブゴールのレビューに「→ hardened: <場所>」を付けて書く。
- 繰り返し出る学び、機械的に確かめられる学びは、チェック、hook、ask ルールに変える（ハーネス化）。
- 大ゴールの振り返りは 11節の完了報告で行う。

## 11. 大ゴールの切り替え

```
goal-owner が reached: と判断
   ▼
① 人間に聞く：追加のサブゴールで続ける / 完了報告を書く
   完了報告（gdd/reviews/GOAL.md）：受け入れシナリオと結果の対応、デモ、大ゴールの振り返り、やり残し、次のゴール候補2〜3案
   ▼
② アーカイブ：レビューの学びのうち、どの題材でも効くものを plugin の手順や雛形に移すか、人間に3案で選んでもらう。
   そのあと gdd/archive/NN-<slug>/ に goal.md / subgoals/ / uncertainties/ / reviews/ / 完了報告を移し、
   gdd-init で空の状態を作り直す（未実装）
   ▼
③ 新しい大ゴールの設定：AI が引き継ぐ前提（確定した仕様、技術構成、既存の成果物、学び）の案を出し、人間が承認する
```

- 2つ目以降のゴールは「何を変える / 何を足すか」から始める。引き継ぐものは `goal.md` の「前提」に書く。
- GOAL は完了前でも再設定できる。その場合もリファインメントでサブゴールを作り直す。
- 過去のゴールは `gdd/archive/` に残す。AI は普段は読まない。

## 12. 借りる既存手法

| 要素 | 既存手法 |
|---|---|
| 仕様 → 計画 → タスク、clarify（質問で不確実性を潰す） | GitHub Spec Kit https://github.com/github/spec-kit 、Kiro specs |
| 進捗ファイル、状態を持ち越さないループ | Anthropic「Effective harnesses for long-running agents」 https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents 、Ralph loop |
| planner / generator / evaluator | https://www.anthropic.com/engineering/harness-design-long-running-apps |
| 確定的なチェックを優先し、推論的なチェックは補助にする | Böckeler「Harness engineering for coding agent users」 https://martinfowler.com/articles/harness-engineering.html |
| ガードレール（成果物への柵と行動への柵、1コマンドの門） | kinopeee「ハーネス設計入門」 https://speakerdeck.com/kinopeee/hanesu-sekkei-nyuumon-kontekisuto-no-tsugi |
| 細かく main に入れ、レビューは後から（Ship / Show / Ask） | トランクベース開発、Wilsenach「Ship / Show / Ask」 https://martinfowler.com/articles/ship-show-ask.html |
| コーディネーターが並列のセッションを配って追跡する | Claude Code Projects https://code.claude.com/docs/en/claude-projects.md |
| Markdown 過多への警告 | https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html |

スクラムからは、反復と漸進、振り返りの型、完成の定義だけを借りる。人間が並べたバックログを上から消化する形はとらない。

## 13. 未決事項

1. **eval で git が使えるか**。旧計画では「eval のサンドボックスは macOS で git を動かせない」として eval を消した。新設計でもコーディネーターはコミットとマージをする。試せない場合、(a) eval は git を使わない判断の部分だけにする、(b) Docker のシミュレーション（`simulations/` は gitignore されていて作り直しが要る。Docker と OAuth トークンも未準備）で試す、のどちらにするか。
2. **Projects のスレッドにいつ対応するか**。クラウドのスレッドは自分のブランチを push して PR を作る。`ready-to-merge` を `origin/gdd/<slug>` からも読めば対応できる。
3. **`doing` のまま止まったサブゴール**は、当面「人間に聞く」だけでよいか。
4. **取り込みの方法**は `--no-ff` のマージコミットでよいか（rebase は ask ルールの対象）。
5. 最初の題材（小さな新規アプリ）、デモの届け方（Web ならプレビュー URL、Android なら録画かビルド）。

## 14. 経緯

- **2026-10-05**：初版メモを4視点で悲観レビューして書き直した。PR のマージで承認する形をやめ、サブゴールの完了時に承認する形にした。止める条件を AI の自己申告から機械的なトリガーに変えた。骨格は既存手法から借り、自作は「理解・介在」の層に絞った。
- **2026-10-10〜11（旧 `docs/redesign-plan.md`、PR #4 `feat/redesign`）**：次の一手を AI（goal-owner）が決める、サブゴールと ADR を1件1ファイルにする、チェックをガードレールにする（`[id]` と `Check:`、`[gate]`）、worker による並列化、を入れた。あわせて、チームで使えるようにサブゴールごとに PR を作り、人間がマージするまで次に進まない形にした。
- **2026-10-14（この版）**：PR 前提の形は、人間がマージするまで止まるので実質 HITL になり、gh や PR 本文の目印などの仕組みで差分が理解できない大きさになった。そこで方針を決め直した：1人用にする、PR を関門にせずトランクベースでサブゴールごとに main へ取り込む、実装は機械チェックで通し人間はゴールと完了条件・判断・学びに集中する、並列のセッション（メインの指示で3つほど）に耐える。

## 15. 移行計画

PR #4 のブランチのコードは 2026-10-11 時点の形（PR 前提）のまま。ここから上の設計へは、**main から切った小さな PR を順に作って移る**。PR #4 は部品の置き場として使い（`git show origin/feat/redesign:<path>` で取り出す）、移行が済んだら閉じる。この `docs/design.md` は PR 1 で main に入れる。

各 PR は `bash tests/check.sh` が通ってから出す。eval は全部消してあり、新しい設計が実装しきってから作り直す。

### PR #4 の部品の扱い

| 部品（`origin/feat/redesign:` から） | 扱い |
|---|---|
| `plugins/polaris/skills/gdd-loop/scripts/gdd-check.sh` | そのまま使う |
| `.../scripts/gdd-lint.sh` | 使う。status に `doing` を足す |
| `.../scripts/gdd-status.sh` | 書き直す。gh、PR、`refining:` を削り、ファイルとブランチ `gdd/<slug>` から状態を読む。ready、overlaps、stalled、hold は残す |
| `plugins/polaris/agents/goal-owner.md` | 使う。`mode`、`refining`、PR まわりの記述を削る |
| `plugins/polaris/agents/subgoal-verifier.md` | そのまま使う（main の `evaluator.md` を置き換える） |
| `plugins/polaris/agents/worker.md` | 薄くする：`gdd-work` を呼ぶだけ |
| `.../gdd-loop/templates/`（subgoal、uncertainty、review、adr） | 使う。subgoal の status に `doing` を足し、PR の語を削る |
| `.../gdd-init/templates/goal.md` | 使う。`mode` の frontmatter は削る |
| `.../gdd-init/SKILL.md` | 使う。`worktree.baseRef: "head"` と `.gitignore` の `.claude/worktrees/` は残す。`Edit(/gdd/**)` を allow にする理由から PR を削る |
| `plugins/polaris/hooks/guard-gdd-writes.sh` | 使う |
| `.../gdd-loop/steps/set-goal.md`、`refine.md` | 使う。PR を作る部分を「人間の承認 → main にコミット」に変え、閉じた PR による cancel を削る |
| `.../gdd-loop/steps/plan.md`、`review.md`、`finish.md` | 分けて使う：plan → `gdd-loop` 本体、review → `gdd-work` の 4〜5、finish → 8節と 11節 |
| `tests/`（`check.sh`、`gdd-check.sh`、`gdd-lint.sh`、`gdd-status.sh`、`guard-gdd-writes.sh`） | 使う。`gdd-status` のテストは gh の偽物をやめ、git リポジトリを作って試す形にする |
| `mode: fast \| careful` | 使わない（必要になったら足す） |
| main を PR でしか変えない方針、`Sub-goal:` と `Refine:` の目印、`merged-not-pulled` / `in-review` / `closed`、gh が失敗したら止まる処理、PR の行コメント | 使わない |
| eval スイート | 使わない。旧設計向けなので PR 1 で全部消し、新しい設計が実装しきってから作り直す |
| このリポジトリ自身の `gdd/` の移行（`archive/state-before-redesign.md`、`reviews/redesign.md`） | PR 1 で使う |

### PR 1：状態を1件1ファイルにする（振る舞いはほぼ変えない）

- `gdd/subgoals/<slug>.md`、`uncertainties/`、`adr/`、`reviews/<slug>.md`（Learnings）に移し、`state.md`、`subgoals.md`、`adr.md` をなくす。
- 変更：`gdd-init`（SKILL.md、templates）、`gdd-loop/templates/`、`gdd-lint.sh` を追加、hook を PR #4 版に、`gdd-loop/SKILL.md` は読み書きするファイルを新しい配置に合わせるだけ（1回の起動で1サブゴール、サブゴールごとの人間の判断はまだ残す）、tests、このリポジトリの `gdd/` の移行、README、この `docs/design.md`。
- 確認：`tests/check.sh`。

### PR 2：チェックを関門にする

- `[id]` と `Check:` と `[gate]`、`gdd-check.sh`、`subgoal-verifier`（`evaluator` を置き換え）。作る系はコマンドのチェックと gate がすべて met なら人間に聞かずに次へ。サブゴールごとの「OK / 変える / やめる」の質問は、決める系と `human:` を含むものだけに残す。
- 変更：`gdd-init/templates/goal.md`、`templates/subgoal.md`、`gdd-check.sh`、`agents/subgoal-verifier.md`、`agents/evaluator.md` の削除、`gdd-loop/SKILL.md` の振り返りと判断の部分、tests。

### PR 3：goal-owner、続けて回るループ、リファインメント

- `goal-owner`、`gdd-status.sh`（ファイルとブランチから状態を読む）、止まる条件まで回り続けるループ、`steps/set-goal.md`、`steps/refine.md`（会話の中で承認）、hold、ゴール達成。
- この PR ではまだ並列にしない（`start:` が複数でも、コーディネーター自身が1つずつ `gdd-work` と同じ手順で作る）。
- 変更：`agents/goal-owner.md`、`gdd-status.sh`、`gdd-loop/SKILL.md`、`steps/`、tests。

### PR 4：並列のセッション

- `skills/gdd-work/`、薄い `worker`、`doing` とブランチ `gdd/<slug>`、`ready-to-merge` の判定、8節の取り込みと main での gate、`gdd-init` の `worktree.baseRef` と `.gitignore`。
- 変更：`skills/gdd-work/SKILL.md` を新規、`agents/worker.md`、`gdd-loop/SKILL.md`（配る、取り込む）、`gdd-status.sh`、`gdd-init/SKILL.md`、tests（2つのブランチを並列に作って取り込む git のテスト）、README。
- 確認：実モデルで、独立したサブゴール2〜3個を、(a) `worker` サブエージェントの並列、(b) 人間が別ターミナルで `/polaris:gdd-work` を開く、の2通りで回す。

### 最後に

- PR #4 を閉じる（理由と、この文書へのリンクを書く）。
