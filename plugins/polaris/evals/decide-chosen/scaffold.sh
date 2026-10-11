#!/bin/bash
# A Decide sub-goal with its comparison prepared. history.jsonl holds the AI's question; the prompt is the human's choice with a reason.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p chosen-test/gdd/subgoals/candidates chosen-test/gdd/subgoals/in-progress chosen-test/gdd/subgoals/in-review chosen-test/gdd/subgoals/done chosen-test/gdd/reviews chosen-test/gdd/adr
mkdir -p chosen-test/gdd
cat > chosen-test/gdd/goal.md <<'EOF'
---
prefer: certainty
---
# Goal: notes format

## North star

Notes use one agreed file format.

## Acceptance scenarios

1. [format-agreed] The team agrees on a note format and the first note uses it
   - Check: human: the team decides

## Definition of done

1. [gate] every sub-goal passes the project's checks
   - Check: `true`

## Premises

- None
EOF
mkdir -p chosen-test/gdd
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
mkdir -p chosen-test/gdd/subgoals/in-progress
cat > chosen-test/gdd/subgoals/in-progress/note-format.md <<'EOF'
---
type: decide
advances: U1, format-agreed
depends_on: none
touches: chosen-test/notes/
---
# Decide which file format the notes use

## Done when

1. [chosen] the human chose a format
   - Check: human: the human picks one of three

## What to show

- the result
EOF
mkdir -p chosen-test/docs
cat > chosen-test/docs/note-format.md <<'EOF'
# Note format

| Option | Format | Trade-off |
|---|---|---|
| A | Markdown | Readable as plain text, renders on GitHub; no structure for metadata |
| B | Plain text | Simplest; no headings or links |
| C | JSON | Structured; hard to write by hand |
EOF
git add -A
git commit -qm fixture
