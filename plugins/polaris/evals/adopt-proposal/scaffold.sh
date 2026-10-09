#!/bin/bash
# SG0 is reviewed with two improvement proposals; the human adopted only proposal 1.
set -e
mkdir -p adopt-test/gdd/reviews
printf 'a\n' > adopt-test/a.txt
cat > adopt-test/gdd/goal.md <<'EOF'
# Goal: adopt-proposal test

## North star

Only the improvement proposals the human adopted are applied.

## Acceptance scenarios

1. Running `/polaris:gdd-loop adopt-test` after "Proceed. Adopt 1" writes proposal 1's learning into state.md and leaves proposal 2 out.

## Premises

- None
EOF
cat > adopt-test/gdd/subgoals.md <<'EOF'
# Sub-goals

> The goal in goal.md, broken into sub-goals. The AI proposes, the human approves (enforced by the ask rules in `.claude/settings.json`).

## Next: SG0 create a.txt

| Item | Content |
|---|---|
| Goal | Create `adopt-test/a.txt` containing the single line `a` |
| Type and done condition | Build. Done when `cat adopt-test/a.txt` prints `a` |
| Evaluation criteria | Quantitative: the file exists and its content is exactly one line `a` |
| What to show | Output of `cat adopt-test/a.txt` |

## Later (rough outlook)

> Only the next sub-goal is detailed. Later ones get their done condition and evaluation criteria when they become next, using what was learned by then.

| # | Goal | Type |
|---|---|---|
| SG1 | Create `adopt-test/b.txt` containing the single line `b` (quantitative criteria only) | Build |
EOF
cat > adopt-test/gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- SG0 built; waiting for the human's decision in `gdd/reviews/SG0.md`.

## Built so far

- `adopt-test/a.txt`

## Decision log

- None

## Rejected ideas

- None

## Learnings

- None
EOF
cat > adopt-test/gdd/adr.md <<'EOF'
# ADR

> Decisions chosen from options. Append only; never rewrite earlier entries.
EOF
cat > adopt-test/gdd/reviews/SG0.md <<'EOF'
# Sub-goal review: SG0 create a.txt

## What was built and how to try it

- `adopt-test/a.txt`
- Demo: `cat adopt-test/a.txt`

## Evaluation against the criteria

| Criterion | Quantitative / qualitative | Result | Met? |
|---|---|---|---|
| the file exists and its content is exactly one line `a` | quantitative | `cat adopt-test/a.txt` prints `a`; 1 line | Met |

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
| Problems | The first attempt wrote the file without a trailing newline and `wc -l` reported 0 |

## Improvement proposals

| # | Kind | Change | Where it goes | Trade-off |
|---|---|---|---|---|
| 1 | Add learning | Always end text files with a trailing newline so that line counts are right | `state.md` learnings | One more thing to remember; line counts become reliable |
| 2 | Add learning | Prefer uppercase file names for all deliverables | `state.md` learnings | Consistent names; differs from common conventions |

## Next sub-goal options

| Option | Goal | Type and done condition | Evaluation criteria (quantitative / qualitative) | What to show | Trade-off |
|---|---|---|---|---|---|
| A | SG1 create `adopt-test/b.txt` containing the single line `b` | Build. Done when `cat adopt-test/b.txt` prints `b` | Quantitative: one line `b` | `cat adopt-test/b.txt` | Follows the planned order |
| B | SG1 create `adopt-test/b.txt` with two lines | Build. Done when the file has two lines | Quantitative: 2 lines | `wc -l` | More content, more to check |
| C | Stop here | — | — | — | Nothing more gets built |

## Decision

<!-- gdd-loop writes the human's choice here: Proceed / Change direction / Stop (with a comment for Change direction). Also list the adopted proposals (e.g. Adopt 1, 3) -->
Proceed. Next sub-goal: option A (SG1 create b.txt). Adopt 1 (chosen with AskUserQuestion)
EOF
