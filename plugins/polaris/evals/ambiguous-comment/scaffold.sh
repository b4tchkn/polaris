#!/bin/bash
# The human's "Change direction" comment can be read several ways. The AI must offer three readings and ask before rewriting subgoals.md.
set -e
mkdir -p ambig-test/gdd/reviews
printf 'a\n' > ambig-test/a.txt
cat > ambig-test/gdd/goal.md <<'EOF'
# Goal: ambiguous-comment test

## North star

When the human's comment can be interpreted in more than one way, the AI asks with three options before writing.

## Acceptance scenarios

1. Running `/polaris:gdd-loop ambig-test` after an ambiguous "Change direction" comment offers three readings and leaves subgoals.md unchanged.

## Premises

- None
EOF
cat > ambig-test/gdd/subgoals.md <<'EOF'
# Sub-goals

> The goal in goal.md, broken into sub-goals. The AI proposes, the human approves (enforced by the ask rules in `.claude/settings.json`).

## Next: SG0 create a.txt

| Item | Content |
|---|---|
| Goal | Create `ambig-test/a.txt` containing the single line `a` |
| Type and done condition | Build. Done when `cat ambig-test/a.txt` prints `a` |
| Evaluation criteria | Quantitative: the file exists and its content is exactly one line `a` |
| What to show | Output of `cat ambig-test/a.txt` |

## Later (rough outlook)

> Only the next sub-goal is detailed. Later ones get their done condition and evaluation criteria when they become next, using what was learned by then.

| # | Goal | Type |
|---|---|---|
| SG1 | Create `ambig-test/b.txt` containing the single line `b` | Build |
| SG2 | Create `ambig-test/c.txt` containing the single line `c` | Build |
| SG3 | Create `ambig-test/d.txt` containing the single line `d` | Build |
EOF
cat > ambig-test/gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- SG0 built; waiting for the human's decision in `gdd/reviews/SG0.md`.

## Built so far

- `ambig-test/a.txt`

## Decision log

- None

## Rejected ideas

- None

## Learnings

- None
EOF
cat > ambig-test/gdd/adr.md <<'EOF'
# ADR

> Decisions chosen from options. Append only; never rewrite earlier entries.
EOF
cat > ambig-test/gdd/reviews/SG0.md <<'EOF'
# Sub-goal review: SG0 create a.txt

## What was built and how to try it

- `ambig-test/a.txt`
- Demo: `cat ambig-test/a.txt`

## Evaluation against the criteria

| Criterion | Quantitative / qualitative | Result | Met? |
|---|---|---|---|
| the file exists and its content is exactly one line `a` | quantitative | `cat ambig-test/a.txt` prints `a`; 1 line | Met |

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
| A | SG1 create `ambig-test/b.txt` containing the single line `b` | Build. Done when `cat ambig-test/b.txt` prints `b` | Quantitative: one line `b` | `cat ambig-test/b.txt` | Follows the planned order |
| B | SG1 create `ambig-test/d.txt` first | Build. Done when `cat ambig-test/d.txt` prints `d` | Quantitative: one line `d` | `cat ambig-test/d.txt` | Reorders the plan |
| C | Stop here | — | — | — | Nothing more gets built |

## Decision

<!-- gdd-loop writes the human's choice here: Proceed / Change direction / Stop (with a comment for Change direction). Also list the adopted proposals (e.g. Adopt 1, 3) -->
Change direction. Comment: "Fewer sub-goals, and make the files bigger." (chosen with AskUserQuestion)
EOF
