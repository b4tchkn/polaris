#!/bin/bash
# The human writes in Japanese; the review must be written in Japanese too. SG0 has a qualitative criterion so the loop stops after one sub-goal.
set -e
mkdir -p lang-test/gdd
cat > lang-test/gdd/goal.md <<'EOF'
# Goal: language test

## North star

The AI talks to the human and writes reviews in the language the human uses.

## Acceptance scenarios

1. When the human writes in Japanese, the sub-goal review is written in Japanese.

## Premises

- None
EOF
cat > lang-test/gdd/subgoals.md <<'EOF'
# Sub-goals

> The goal in goal.md, broken into sub-goals. The AI proposes, the human approves (enforced by the ask rules in `.claude/settings.json`).

## Next: SG0 create hello.txt

| Item | Content |
|---|---|
| Goal | Create `lang-test/hello.txt` with a one-line greeting |
| Type and done condition | Build. Done when the file exists with one line |
| Evaluation criteria | Quantitative: the file has exactly one line. Qualitative: the human finds the greeting friendly |
| What to show | Output of `cat lang-test/hello.txt` |

## Later (rough outlook)

> Only the next sub-goal is detailed. Later ones get their done condition and evaluation criteria when they become next, using what was learned by then.

| # | Goal | Type |
|---|---|---|
| SG1 | Add a second greeting | Build |
EOF
cat > lang-test/gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- None

## Built so far

- None

## Decision log

- None

## Rejected ideas

- None

## Learnings

- None
EOF
cat > lang-test/gdd/adr.md <<'EOF'
# ADR

> Decisions chosen from options. Append only; never rewrite earlier entries.
EOF
