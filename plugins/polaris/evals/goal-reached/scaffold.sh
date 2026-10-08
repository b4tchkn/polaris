#!/bin/bash
# Creates the test gdd/ for the goal-reached case in the eval workspace: SG0 is the only sub-goal, "Later" is empty.
set -e
mkdir -p goal-done/gdd
cat > goal-done/gdd/goal.md <<'EOF'
# Goal: goal-reached test

## North star

When "Later" is empty, gdd-loop says the goal looks reached and asks whether to add sub-goals or write the completion report.

## Acceptance scenarios

1. Running `/polaris:gdd-loop goal-done` says the goal looks reached and offers "add sub-goals" / "write the goal completion report".

## Premises

- None
EOF
cat > goal-done/gdd/subgoals.md <<'EOF'
# Sub-goals

> The goal in goal.md, broken into sub-goals. The AI proposes, the human approves (enforced by the ask rules in `.claude/settings.json`).

## Next: SG0 create done.txt

| Item | Content |
|---|---|
| Goal | Create `goal-done/done.txt` containing the single line `done` |
| Type and done condition | Build. Done when `cat goal-done/done.txt` prints `done` |
| Evaluation criteria | Quantitative: the file exists and its content is exactly one line `done` |
| What to show | Output of `cat goal-done/done.txt` |

## Later (rough outlook)

> Only the next sub-goal is detailed. Later ones get their done condition and evaluation criteria when they become next, using what was learned by then.

| # | Goal | Type |
|---|---|---|
EOF
cat > goal-done/gdd/state.md <<'EOF'
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
cat > goal-done/gdd/adr.md <<'EOF'
# ADR

> Decisions chosen from options. Append only; never rewrite earlier entries.
EOF
