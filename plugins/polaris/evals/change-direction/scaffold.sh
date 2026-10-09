#!/bin/bash
# SG0 is built and reviewed; the human wrote "Change direction" with a comment. The next run must revise subgoals.md from the comment and stop.
set -e
mkdir -p change-test/gdd/reviews
printf 'a\n' > change-test/a.txt
cat > change-test/gdd/goal.md <<'EOF'
# Goal: change-direction test

## North star

The next run applies the human's "Change direction" decision: subgoals.md is revised from the comment, nothing is built.

## Acceptance scenarios

1. Running `/polaris:gdd-loop change-test` after a "Change direction" decision rewrites the Later sub-goals from the comment and stops.

## Premises

- None
EOF
cat > change-test/gdd/subgoals.md <<'EOF'
# Sub-goals

> The goal in goal.md, broken into sub-goals. The AI proposes, the human approves (enforced by the ask rules in `.claude/settings.json`).

## Next: SG0 create a.txt

| Item | Content |
|---|---|
| Goal | Create `change-test/a.txt` containing the single line `a` |
| Type and done condition | Build. Done when `cat change-test/a.txt` prints `a` |
| Evaluation criteria | Quantitative: the file exists and its content is exactly one line `a` |
| What to show | Output of `cat change-test/a.txt` |

## Later (rough outlook)

> Only the next sub-goal is detailed. Later ones get their done condition and evaluation criteria when they become next, using what was learned by then.

| # | Goal | Type |
|---|---|---|
| SG1 | Create `change-test/b.txt` containing the single line `b` | Build |
| SG2 | Create `change-test/c.txt` containing the single line `c` | Build |
EOF
cat > change-test/gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- SG0 built; waiting for the human's decision in `gdd/reviews/SG0.md`.

## Built so far

- `change-test/a.txt`

## Decision log

- None

## Rejected ideas

- None

## Learnings

- None
EOF
cat > change-test/gdd/adr.md <<'EOF'
# ADR

> Decisions chosen from options. Append only; never rewrite earlier entries.
EOF
cat > change-test/gdd/reviews/SG0.md <<'EOF'
# Sub-goal review: SG0 create a.txt

## What was built and how to try it

- `change-test/a.txt`
- Demo: `cat change-test/a.txt`

## Evaluation against the criteria

| Criterion | Quantitative / qualitative | Result | Met? |
|---|---|---|---|
| the file exists and its content is exactly one line `a` | quantitative | `cat change-test/a.txt` prints `a`; 1 line | Met |

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
| A | SG1 create `change-test/b.txt` containing the single line `b` | Build. Done when `cat change-test/b.txt` prints `b` | Quantitative: one line `b` | `cat change-test/b.txt` | Follows the planned order |
| B | SG1 create `change-test/c.txt` first | Build. Done when `cat change-test/c.txt` prints `c` | Quantitative: one line `c` | `cat change-test/c.txt` | Reorders the plan |
| C | Stop here | — | — | — | Nothing more gets built |

## Decision

<!-- gdd-loop writes the human's choice here: Proceed / Change direction / Stop (with a comment for Change direction). Also list the adopted proposals (e.g. Adopt 1, 3) -->
Change direction. Comment: "Drop SG1 and SG2 (b.txt and c.txt). Replace them with one Build sub-goal: create change-test/README.md containing the single line `a.txt`. Done when `cat change-test/README.md` prints `a.txt`." (chosen with AskUserQuestion)
EOF
