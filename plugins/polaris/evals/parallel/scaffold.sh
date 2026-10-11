#!/bin/bash
# Two independent Build candidates with disjoint touches: they are handed to two workers at once.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p par-test/gdd/subgoals/candidates par-test/gdd/subgoals/in-progress par-test/gdd/subgoals/in-review par-test/gdd/subgoals/done par-test/gdd/reviews par-test/gdd/adr
mkdir -p par-test/gdd
cat > par-test/gdd/goal.md <<'EOF'
---
prefer: certainty
---
# Goal: parallel test

## North star

Two independent files exist.

## Acceptance scenarios

1. [left] par-test/left/x.txt holds x
   - Check: `test "$(cat par-test/left/x.txt)" = x`
2. [right] par-test/right/y.txt holds y
   - Check: `test "$(cat par-test/right/y.txt)" = y`

## Definition of done

1. [gate] every sub-goal passes the project's checks
   - Check: `true`

## Premises

- None
EOF
mkdir -p par-test/gdd
cat > par-test/gdd/state.md <<'EOF'
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
mkdir -p par-test/gdd/subgoals/candidates
cat > par-test/gdd/subgoals/candidates/left-x.md <<'EOF'
---
type: build
advances: left
depends_on: none
touches: par-test/left/
---
# Create par-test/left/x.txt containing x

## Done when

1. [exact] x.txt is x
   - Check: `test "$(cat par-test/left/x.txt)" = x`

## What to show

- the result
EOF
mkdir -p par-test/gdd/subgoals/candidates
cat > par-test/gdd/subgoals/candidates/right-y.md <<'EOF'
---
type: build
advances: right
depends_on: none
touches: par-test/right/
---
# Create par-test/right/y.txt containing y

## Done when

1. [exact] y.txt is y
   - Check: `test "$(cat par-test/right/y.txt)" = y`

## What to show

- the result
EOF
git add -A
git commit -qm fixture
