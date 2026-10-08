#!/bin/bash
# SG0 is built and reviewed; the human wrote "Stop" in the review's Decision section.
set -e
mkdir -p stop-test/gdd/reviews
printf 'a\n' > stop-test/a.txt
cat > stop-test/gdd/goal.md <<'EOF'
# Goal: apply-stop test

## North star

The next run applies the human's "Stop" decision: nothing is advanced.

## Acceptance scenarios

1. Running `/polaris:gdd-loop stop-test` after a "Stop" decision records it and stops without advancing a sub-goal.

## Premises

- None
EOF
cat > stop-test/gdd/subgoals.md <<'EOF'
# Sub-goals

> The goal in goal.md, broken into sub-goals. The AI proposes, the human approves (enforced by the ask rules in `.claude/settings.json`).

## Next: SG0 create a.txt

| Item | Content |
|---|---|
| Goal | Create `stop-test/a.txt` containing the single line `a` |
| Type and done condition | Build. Done when `cat stop-test/a.txt` prints `a` |
| Evaluation criteria | Quantitative: the file exists and its content is exactly one line `a` |
| What to show | Output of `cat stop-test/a.txt` |

## Later (rough outlook)

> Only the next sub-goal is detailed. Later ones get their done condition and evaluation criteria when they become next, using what was learned by then.

| # | Goal | Type |
|---|---|---|
| SG1 | Create `stop-test/b.txt` containing the single line `b` | Build |
EOF
cat > stop-test/gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- SG0 built; waiting for the human's decision in `gdd/reviews/SG0.md`.

## Built so far

- `stop-test/a.txt`

## Decision log

- None

## Rejected ideas

- None

## Learnings

- None
EOF
cat > stop-test/gdd/adr.md <<'EOF'
# ADR

> Decisions chosen from options. Append only; never rewrite earlier entries.
EOF
cat > stop-test/gdd/reviews/SG0.md <<'EOF'
# Sub-goal review: SG0 create a.txt

## What was built and how to try it

- `stop-test/a.txt`
- Demo: `cat stop-test/a.txt`

## Evaluation against the criteria

| Criterion | Quantitative / qualitative | Result | Met? |
|---|---|---|---|
| the file exists and its content is exactly one line `a` | quantitative | `cat stop-test/a.txt` prints `a`; 1 line | Met |

## Least confident decision

- None

## Discarded ideas

- None

## Questions for the human

- None

## Retrospective

| Item | Content |
|---|---|
| Keep | Small sub-goals |
| Problems | None |

## Improvement proposals

| # | Kind | Change | Where it goes | Trade-off |
|---|---|---|---|---|

## Next sub-goal options

| Option | Goal | Type and done condition | Evaluation criteria (quantitative / qualitative) | What to show | Trade-off |
|---|---|---|---|---|---|
| A | SG1 create `stop-test/b.txt` containing the single line `b` | Build. Done when `cat stop-test/b.txt` prints `b` | Quantitative: the file exists and its content is exactly one line `b` | Output of `cat stop-test/b.txt` | Follows the planned order |
| B | SG1 create `stop-test/b.txt` with two lines | Build. Done when the file has two lines | Quantitative: 2 lines | `wc -l` | More content, more to check |
| C | Stop here | — | — | — | Nothing more gets built |

## Decision

<!-- gdd-loop writes the human's choice here: Proceed / Change direction / Stop (with a comment for Change direction). Also list the adopted proposals (e.g. Adopt 1, 3) -->
Stop. (chosen with AskUserQuestion)
EOF
