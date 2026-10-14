#!/bin/bash
# create-a is built and reviewed with two proposals; the Decision section is empty. history.jsonl holds the AI's three questions; the prompt answers 1 and 2 only.
set -e
mkdir -p skip-test/gdd/reviews skip-test/gdd/subgoals skip-test/gdd/uncertainties skip-test/gdd/adr
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
cat > skip-test/gdd/subgoals/create-a.md <<'EOF'
---
status: doing
type: build
advances: skipped-question
depends_on: none
touches: skip-test/
---
# Create `skip-test/a.txt` containing the single line `a`

## Done when

1. [a-line] Quantitative: the file exists and its content is exactly one line `a`
   - Check: `test "$(cat skip-test/a.txt)" = a`

## What to show

- Output of `cat skip-test/a.txt`
EOF
cat > skip-test/gdd/subgoals/create-b.md <<'EOF'
---
status: todo
type: build
advances: skipped-question
depends_on: create-a
touches: skip-test/
---
# Create `skip-test/b.txt` containing the single line `b`
EOF
cat > skip-test/gdd/reviews/create-a.md <<'EOF'
---
subgoal: create-a
loop: 1
progress: 1 of 1 met
---
# Sub-goal review: create-a create a.txt

## What was built and how to try it

- `skip-test/a.txt`
- Demo: `cat skip-test/a.txt`

## Checks

| Condition | Check | Result | By |
|---|---|---|---|
| a-line the file exists and its content is exactly one line `a` | command | Met | evaluator |

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
| 1 | Add learning | Always end text files with a trailing newline | the Learnings of this review | Line counts become reliable |
| 2 | Add learning | Prefer uppercase file names | the Learnings of this review | Consistent names, unusual convention |

## Next sub-goal options

| Option | Goal | Type and done condition | Evaluation criteria (quantitative / qualitative) | What to show | Trade-off |
|---|---|---|---|---|---|
| A | create `skip-test/b.txt` containing the single line `b` | Build. Done when `cat skip-test/b.txt` prints `b` | Quantitative: one line `b` | `cat skip-test/b.txt` | Follows the planned order |
| B | create `skip-test/b.txt` with two lines | Build. Done when the file has two lines | Quantitative: 2 lines | `wc -l` | More content, more to check |
| C | Stop here | — | — | — | Nothing more gets built |

## Decision

<!-- gdd-loop writes the human's choice here: Proceed / Change direction / Stop (with a comment for Change direction). Also list the adopted proposals (e.g. Adopt 1, 3) -->
EOF
