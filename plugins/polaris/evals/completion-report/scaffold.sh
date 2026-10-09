#!/bin/bash
# SG0 is built and reviewed, "Later" is empty. history.jsonl holds the AI asking "add sub-goals or write the completion report?"; the prompt is the human's answer.
set -e
mkdir -p done-test/gdd/reviews
printf 'done\n' > done-test/done.txt
cat > done-test/gdd/goal.md <<'EOF'
# Goal: completion-report test

## North star

When the human chooses the completion report, gdd-loop writes `gdd/reviews/GOAL.md`.

## Acceptance scenarios

1. `cat done-test/done.txt` prints `done`.

## Premises

- None
EOF
cat > done-test/gdd/subgoals.md <<'EOF'
# Sub-goals

> The goal in goal.md, broken into sub-goals. The AI proposes, the human approves (enforced by the ask rules in `.claude/settings.json`).

## Next: SG0 create done.txt

| Item | Content |
|---|---|
| Goal | Create `done-test/done.txt` containing the single line `done` |
| Type and done condition | Build. Done when `cat done-test/done.txt` prints `done` |
| Evaluation criteria | Quantitative: the file exists and its content is exactly one line `done` |
| What to show | Output of `cat done-test/done.txt` |

## Later (rough outlook)

> Only the next sub-goal is detailed. Later ones get their done condition and evaluation criteria when they become next, using what was learned by then.

| # | Goal | Type |
|---|---|---|
EOF
cat > done-test/gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- SG0 built and reviewed. "Later" is empty, so the goal looks reached. Waiting for the human: add sub-goals or write the completion report.

## Built so far

- `done-test/done.txt`

## Decision log

- None

## Rejected ideas

- None

## Learnings

- None
EOF
cat > done-test/gdd/adr.md <<'EOF'
# ADR

> Decisions chosen from options. Append only; never rewrite earlier entries.
EOF
cat > done-test/gdd/reviews/SG0.md <<'EOF'
# Sub-goal review: SG0 create done.txt

## What was built and how to try it

- `done-test/done.txt`
- Demo: `cat done-test/done.txt`

## Evaluation against the criteria

| Criterion | Quantitative / qualitative | Result | Met? |
|---|---|---|---|
| the file exists and its content is exactly one line `done` | quantitative | `cat done-test/done.txt` prints `done`; 1 line | Met |

## Least confident decision

- None

## Discarded ideas

- None

## Questions for the human

- "Later" is empty, so the goal looks reached. Add sub-goals, or write the goal completion report?

## Retrospective

| Item | Content |
|---|---|
| Keep | Small sub-goals |
| Problems | None |

## Improvement proposals

| # | Kind | Change | Where it goes | Trade-off |
|---|---|---|---|---|

## Goal check (Later is empty)

| Acceptance scenario | Result | Met? |
|---|---|---|
| 1. `cat done-test/done.txt` prints `done` | prints `done` | Met |

## Decision

<!-- gdd-loop writes the human's choice here: Proceed / Change direction / Stop (with a comment for Change direction). Also list the adopted proposals (e.g. Adopt 1, 3) -->
EOF
