#!/bin/bash
# The only candidate is a Decide sub-goal: the AI prepares a comparison and asks the human to choose before any pull request.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p decide-test/gdd/subgoals/candidates decide-test/gdd/subgoals/in-progress decide-test/gdd/subgoals/in-review decide-test/gdd/subgoals/done decide-test/gdd/reviews decide-test/gdd/adr
mkdir -p decide-test/gdd
cat > decide-test/gdd/goal.md <<'EOF'
---
prefer: certainty
avoid: none
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
mkdir -p decide-test/gdd
cat > decide-test/gdd/state.md <<'EOF'
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
mkdir -p decide-test/gdd/subgoals/candidates
cat > decide-test/gdd/subgoals/candidates/note-format.md <<'EOF'
---
type: decide
advances: U1, format-agreed
depends_on: none
touches: decide-test/notes/
---
# Decide which file format the notes in decide-test/notes/ use

## Done when

1. [chosen] the human chose a format
   - Check: human: the human picks one of three

## What to show

- A one-page comparison of three formats with trade-offs
EOF
git add -A
git commit -qm fixture
