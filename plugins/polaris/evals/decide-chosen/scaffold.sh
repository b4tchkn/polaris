#!/bin/bash
# A Decide sub-goal with its comparison written; the Decision section is empty. history.jsonl holds the AI's questions; the prompt is the human's choice with a reason.
set -e
mkdir -p chosen-test/gdd/reviews
cat > chosen-test/gdd/goal.md <<'EOF'
# Goal: decide-chosen test

## North star

When the human chooses an option of a Decide sub-goal, the choice and the reason are recorded in adr.md.

## Acceptance scenarios

1. After the human picks option A with a reason, adr.md has a new entry with the options, the chosen one, and the reason in the human's words.

## Premises

- None
EOF
cat > chosen-test/gdd/subgoals.md <<'EOF'
# Sub-goals

> The goal in goal.md, broken into sub-goals. The AI proposes, the human approves (enforced by the ask rules in `.claude/settings.json`).

## Next: SG0 decide the file format for notes

| Item | Content |
|---|---|
| Goal | Decide which file format the notes in `chosen-test/notes/` will use |
| Type and done condition | Decide. Done when the human agrees on a format |
| Evaluation criteria | Qualitative: the human finds the comparison clear enough to choose |
| What to show | A one-page comparison of three formats with trade-offs |

## Later (rough outlook)

> Only the next sub-goal is detailed. Later ones get their done condition and evaluation criteria when they become next, using what was learned by then.

| # | Goal | Type |
|---|---|---|
| SG1 | Create the first note in the chosen format | Build |
EOF
cat > chosen-test/gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- SG0 comparison written; waiting for the human to choose a format.

## Built so far

- `chosen-test/gdd/reviews/SG0.md` (the comparison)

## Decision log

- None

## Rejected ideas

- None

## Learnings

- None
EOF
cat > chosen-test/gdd/adr.md <<'EOF'
# ADR

> Decisions chosen from options. Append only; never rewrite earlier entries.

## Entry format

- Date and sub-goal
- What was decided
- Options offered (with trade-offs)
- Option chosen
- Reason (the human's answer, copied as is)
EOF
cat > chosen-test/gdd/reviews/SG0.md <<'EOF'
# Sub-goal review: SG0 decide the file format for notes

## What was built and how to try it

- Comparison of three formats (below)

| Option | Format | Trade-off |
|---|---|---|
| A | Markdown | Readable as plain text, renders on GitHub; no structure for metadata |
| B | Plain text | Simplest; no headings or links |
| C | JSON | Structured; hard to write by hand |

## Evaluation against the criteria

| Criterion | Quantitative / qualitative | Result | Met? |
|---|---|---|---|
| the human finds the comparison clear enough to choose | qualitative | judged by the human | |

## Least confident decision

- None

## Discarded ideas

- None

## Questions for the human

- Which format?

## Retrospective

| Item | Content |
|---|---|
| Keep | Three options with one-line trade-offs |
| Problems | None |

## Improvement proposals

| # | Kind | Change | Where it goes | Trade-off |
|---|---|---|---|---|

## Next sub-goal options

| Option | Goal | Type and done condition | Evaluation criteria (quantitative / qualitative) | What to show | Trade-off |
|---|---|---|---|---|---|
| A | SG1 create the first note in the chosen format | Build. Done when `chosen-test/notes/` has one note | Quantitative: 1 file | `ls chosen-test/notes` | Follows the planned order |
| B | SG1 write a note template first | Build. Done when a template file exists | Quantitative: 1 file | `cat` the template | Delays the first real note |
| C | Stop here | — | — | — | Nothing more gets built |

## Decision

<!-- gdd-loop writes the human's choice here: Proceed / Change direction / Stop (with a comment for Change direction). Also list the adopted proposals (e.g. Adopt 1, 3) -->
EOF
