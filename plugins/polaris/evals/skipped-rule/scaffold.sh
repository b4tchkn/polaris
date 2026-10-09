#!/bin/bash
# SG0 is built and reviewed with two proposals; the Decision section is empty. history.jsonl holds the AI's three questions; the prompt answers 1 and 2 only.
set -e
mkdir -p skip-test/gdd/reviews
printf 'a\n' > skip-test/a.txt
cat > skip-test/gdd/goal.md <<'EOF'
# Goal: skipped-rule test

## North star

A question the human did not answer is recorded as skipped and never asked again.

## Acceptance scenarios

1. After the human answers questions 1 and 2 but not 3, the Decision section records the answers and marks question 3 as skipped.

## Premises

- None
EOF
cat > skip-test/gdd/subgoals.md <<'EOF'
# Sub-goals

> The goal in goal.md, broken into sub-goals. The AI proposes, the human approves (enforced by the ask rules in `.claude/settings.json`).

## Next: SG0 create a.txt

| Item | Content |
|---|---|
| Goal | Create `skip-test/a.txt` containing the single line `a` |
| Type and done condition | Build. Done when `cat skip-test/a.txt` prints `a` |
| Evaluation criteria | Quantitative: the file exists and its content is exactly one line `a` |
| What to show | Output of `cat skip-test/a.txt` |

## Later (rough outlook)

> Only the next sub-goal is detailed. Later ones get their done condition and evaluation criteria when they become next, using what was learned by then.

| # | Goal | Type |
|---|---|---|
| SG1 | Create `skip-test/b.txt` containing the single line `b` | Build |
EOF
cat > skip-test/gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- SG0 built and reviewed; waiting for the human's answers to the three questions.

## Built so far

- `skip-test/a.txt`

## Decision log

- None

## Rejected ideas

- None

## Learnings

- None
EOF
cat > skip-test/gdd/adr.md <<'EOF'
# ADR

> Decisions chosen from options. Append only; never rewrite earlier entries.
EOF
cat > skip-test/gdd/reviews/SG0.md <<'EOF'
# Sub-goal review: SG0 create a.txt

## What was built and how to try it

- `skip-test/a.txt`
- Demo: `cat skip-test/a.txt`

## Evaluation against the criteria

| Criterion | Quantitative / qualitative | Result | Met? |
|---|---|---|---|
| the file exists and its content is exactly one line `a` | quantitative | `cat skip-test/a.txt` prints `a`; 1 line | Met |

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
| Problems | The first attempt wrote the file without a trailing newline |

## Improvement proposals

| # | Kind | Change | Where it goes | Trade-off |
|---|---|---|---|---|
| 1 | Add learning | Always end text files with a trailing newline | `state.md` learnings | Line counts become reliable |
| 2 | Add learning | Prefer uppercase file names | `state.md` learnings | Consistent names, unusual convention |

## Next sub-goal options

| Option | Goal | Type and done condition | Evaluation criteria (quantitative / qualitative) | What to show | Trade-off |
|---|---|---|---|---|---|
| A | SG1 create `skip-test/b.txt` containing the single line `b` | Build. Done when `cat skip-test/b.txt` prints `b` | Quantitative: one line `b` | `cat skip-test/b.txt` | Follows the planned order |
| B | SG1 create `skip-test/b.txt` with two lines | Build. Done when the file has two lines | Quantitative: 2 lines | `wc -l` | More content, more to check |
| C | Stop here | — | — | — | Nothing more gets built |

## Decision

<!-- gdd-loop writes the human's choice here: Proceed / Change direction / Stop (with a comment for Change direction). Also list the adopted proposals (e.g. Adopt 1, 3) -->
EOF
