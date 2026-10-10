#!/bin/bash
# A Decide sub-goal with its comparison written; the Decision section is empty. history.jsonl holds the AI's question; the prompt is the human's choice with a reason.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p chosen-test/gdd/subgoals/candidates chosen-test/gdd/subgoals/in-progress chosen-test/gdd/subgoals/done chosen-test/gdd/reviews
cat > chosen-test/gdd/goal.md <<'EOF'
---
scenario_1_check: human
done_checks: none
max_files: 5
max_lines: 50
prefer: certainty
avoid: none
---
# Goal: notes format

## North star

Notes in chosen-test/notes/ use one agreed file format.

## Acceptance scenarios

1. The team agrees on a note format and the first note uses it

## Definition of done

- The files are committed on the sub-goal's branch.

## Premises

- None
EOF
cat > chosen-test/gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- None

## Built so far

- None

## Uncertainties

> What is still unknown about reaching the goal. One per line: `- U<n> <question> | open` or `| resolved: <answer>`.

- U1 Which file format suits the team's notes? | open

## Rejected ideas

- None

## Learnings

- None
EOF
cat > chosen-test/gdd/adr.md <<'EOF'
# ADR

> Decisions the human made, with the human's reasons. Append only; never rewrite.
EOF
cat > chosen-test/gdd/subgoals/in-progress/note-format.md <<'EOF'
---
type: decide
advances: U1, scenario_1
depends_on: none
touches: chosen-test/notes/
criterion_1: the human finds the comparison clear enough to choose | qualitative
---
# Decide which file format the notes use

- Done when: the human agrees
- What to show: the file's content
EOF
cat > chosen-test/gdd/subgoals/candidates/first-note.md <<'EOF'
---
type: build
advances: scenario_1
depends_on: note-format
touches: chosen-test/notes/
criterion_1: a note file exists | quantitative | ls chosen-test/notes/* >/dev/null
---
# Write the first note in the chosen format

- Done when: it works through its real entry point
- What to show: the file's content
EOF
cat > chosen-test/gdd/reviews/note-format.md <<'EOF'
---
subgoal: note-format
loop: 1
progress: scenario_1=human open_uncertainties=1
auto: false
overridden: false
rework: none
---
# Sub-goal review: note-format

## What was built and how to try it

- Comparison below.

| Option | Format | Trade-off |
|---|---|---|
| A | Markdown | Readable as plain text, renders on GitHub; no structure for metadata |
| B | Plain text | Simplest; no headings or links |
| C | JSON | Structured; hard to write by hand |

## Next

- Next: first-note: uses the chosen format
- Next-reviewer: agrees

## Decision

<!-- gdd-loop writes the outcome here: "Proceed (automatic). Next: <slug>", or the human's answer (OK / Change something with the comment / Stop). -->
EOF
git add -A
git commit -qm fixture
