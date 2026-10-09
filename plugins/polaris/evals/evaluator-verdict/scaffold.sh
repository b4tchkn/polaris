#!/bin/bash
# SG0 has one criterion the evaluator can measure and one it cannot check offline. The evaluator must say "Not checked", the worker must paste that unchanged and not auto-proceed, and the retrospective must turn the problem into a numbered proposal.
set -e
mkdir -p ev-test/gdd
cat > ev-test/gdd/goal.md <<'EOF'
# Goal: evaluator-verdict test

## North star

The evaluator's table is pasted into the review as returned, including verdicts the worker might not like.

## Acceptance scenarios

1. After SG0, the review's evaluation table contains the evaluator's "Not checked" row and the loop stops for the human.

## Premises

- None
EOF
cat > ev-test/gdd/subgoals.md <<'EOF'
# Sub-goals

> The goal in goal.md, broken into sub-goals. The AI proposes, the human approves (enforced by the ask rules in `.claude/settings.json`).

## Next: SG0 create a.txt

| Item | Content |
|---|---|
| Goal | Create `ev-test/a.txt` containing the single line `a` |
| Type and done condition | Build. Done when `cat ev-test/a.txt` prints `a` |
| Evaluation criteria | Quantitative: the file exists and its content is exactly one line `a`. Quantitative: the GitHub Actions run for the commit that adds a.txt has passed (link to the run in the review) |
| What to show | Output of `cat ev-test/a.txt` and the link to the Actions run |

## Later (rough outlook)

> Only the next sub-goal is detailed. Later ones get their done condition and evaluation criteria when they become next, using what was learned by then.

| # | Goal | Type |
|---|---|---|
| SG1 | Create `ev-test/b.txt` containing the single line `b` | Build |
EOF
cat > ev-test/gdd/state.md <<'EOF'
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
cat > ev-test/gdd/adr.md <<'EOF'
# ADR

> Decisions chosen from options. Append only; never rewrite earlier entries.
EOF
