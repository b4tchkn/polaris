#!/bin/bash
# Three independent candidates, one with a human: check. Each is built, checked, and finished as a pull request (or a branch, without a remote) without asking the human.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p pr-test/gdd/subgoals/candidates pr-test/gdd/subgoals/in-progress pr-test/gdd/subgoals/in-review pr-test/gdd/subgoals/done pr-test/gdd/reviews pr-test/gdd/adr
mkdir -p pr-test/gdd
cat > pr-test/gdd/goal.md <<'EOF'
---
prefer: certainty
avoid: none
---
# Goal: three files

## North star

Three small files exist with the right content.

## Acceptance scenarios

1. [a-file] pr-test/a.txt holds the single line a
   - Check: `test "$(cat pr-test/a.txt)" = a`
2. [b-file] pr-test/b.txt holds the single line b
   - Check: `test "$(cat pr-test/b.txt)" = b`
3. [c-file] pr-test/c.txt holds a short greeting the human finds natural
   - Check: human: whether it reads naturally

## Definition of done

1. [gate] every sub-goal passes the project's checks
   - Check: `true`

## Premises

- None
EOF
mkdir -p pr-test/gdd
cat > pr-test/gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- None

## Built so far

- None

## Uncertainties

> What is still unknown about reaching the goal. One per line: `- U<n> <question> | open` or `| resolved: <answer>`.

- None

## Rejected ideas

- None

## Learnings

- None
EOF
mkdir -p pr-test/gdd/subgoals/candidates
cat > pr-test/gdd/subgoals/candidates/a-txt.md <<'EOF'
---
type: build
advances: a-file
depends_on: none
touches: pr-test/a.txt
---
# Create pr-test/a.txt containing the single line a

## Done when

1. [exact] a.txt is exactly a
   - Check: `test "$(cat pr-test/a.txt)" = a`

## What to show

- the result
EOF
mkdir -p pr-test/gdd/subgoals/candidates
cat > pr-test/gdd/subgoals/candidates/b-txt.md <<'EOF'
---
type: build
advances: b-file
depends_on: none
touches: pr-test/b.txt
---
# Create pr-test/b.txt containing the single line b

## Done when

1. [exact] b.txt is exactly b
   - Check: `test "$(cat pr-test/b.txt)" = b`

## What to show

- the result
EOF
mkdir -p pr-test/gdd/subgoals/candidates
cat > pr-test/gdd/subgoals/candidates/c-txt.md <<'EOF'
---
type: build
advances: c-file
depends_on: none
touches: pr-test/c.txt
---
# Create pr-test/c.txt with a short greeting

## Done when

1. [one-line] c.txt has one line
   - Check: `test $(wc -l < pr-test/c.txt) -eq 1`
2. [natural] it reads naturally as a greeting
   - Check: human: only a reader can tell

## What to show

- the result
EOF
git add -A
git commit -qm fixture
