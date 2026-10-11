#!/bin/bash
# One candidate covers the only scenario. After it, every scenario is met and nothing is left: the AI says the goal looks reached instead of inventing more work.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p goal-done/gdd/subgoals/candidates goal-done/gdd/subgoals/in-progress goal-done/gdd/subgoals/in-review goal-done/gdd/subgoals/done goal-done/gdd/reviews goal-done/gdd/adr
mkdir -p goal-done/gdd
cat > goal-done/gdd/goal.md <<'EOF'
---
prefer: certainty
avoid: none
---
# Goal: goal reached test

## North star

done.txt exists.

## Acceptance scenarios

1. [done-file] goal-done/done.txt holds done
   - Check: `test "$(cat goal-done/done.txt)" = done`

## Definition of done

1. [gate] every sub-goal passes the project's checks
   - Check: `true`

## Premises

- None
EOF
mkdir -p goal-done/gdd
cat > goal-done/gdd/state.md <<'EOF'
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
mkdir -p goal-done/gdd/subgoals/candidates
cat > goal-done/gdd/subgoals/candidates/done-txt.md <<'EOF'
---
type: build
advances: done-file
depends_on: none
touches: goal-done/done.txt
---
# Create goal-done/done.txt containing done

## Done when

1. [exact] done.txt is done
   - Check: `test "$(cat goal-done/done.txt)" = done`

## What to show

- the result
EOF
git add -A
git commit -qm fixture
