# Goal: Goal Driven Development 基盤

## North star

Goal Driven Development の基盤を Claude Code の plugin として提供し、新規でも既存のリポジトリでも plugin を入れて init すれば、AI がゴールへ自律的に進み、人間は要所だけ介在する開発を同じ手順で始められるようにする。

## Acceptance scenarios

> Outcomes of the whole goal, from the user's side: 3 to 5, at most 7. Keep one only if the goal would be unmet when it alone fails. Edge cases belong in a sub-goal's "Done when".
> Each gets an `[id]` and a `Check:` line. Prefer a command (tests, scripts): `` Check: `<command>` ``. Otherwise `Check: observe: <what to look at>` or `Check: human: <why only a human can judge>`.

1. [new-repo] 空の新規リポジトリに plugin を入れて `/polaris:gdd-init` と `/polaris:gdd-loop` を実行すると、小さな新規アプリのサブゴールが3つ以上 main に取り込まれ、main で gate が通る。
   - Check: `bash sim/verify.sh new-repo`（直近のシミュレーションの結果について、main にマージされたサブゴールの PR が3件以上あり、それらのサブゴールが status: done で、main で gate が 0 で終わることを確かめる）
2. [parallel] 独立したサブゴール2〜3個を worker サブエージェントの並列で回すと、すべて main に取り込まれ、main で gate が通る。
   - Check: `bash sim/verify.sh parallel`（配ったサブゴールすべての PR が main にマージされて status: done で、main で gate が 0 で終わることを確かめる）
3. [existing-repo] 自分の既存のリポジトリに `/plugin install` で入れ、`/polaris:gdd-init` と `/polaris:gdd-loop` でサブゴールを1つ以上 main に取り込める。
   - Check: human: 本物の既存リポジトリでの使い勝手は人間にしか分からない
4. [published] GitHub 上で plugin として公開され、誰でも `/plugin install` で入れられる。
   - Check: `gh repo view b4tchkn/polaris --json visibility -q .visibility | grep -qx PUBLIC && claude plugin validate plugins/polaris >/dev/null`

## Definition of done

> The gate every sub-goal passes: one command that runs the project's formatter, linter, type check, build, and tests.

1. [gate] plugin の検証が通る（Markdown だけなので、formatter、型チェック、ビルドは無い）
   - Check: `bash tests/check.sh`

## Premises

- 設計は `docs/design.md`（2026-10-19 版）。それに沿った実装（gdd-init、gdd-loop、goal-owner、worker、subgoal-verifier）が main にある。
- new-repo と parallel は Docker のシミュレーション（headless の Claude Code）で確かめる。人間の答えはシミュレーションの中で台本として与える。
