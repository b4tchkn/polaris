#!/bin/bash
# The last three reviews show the same progress: gdd-status.sh says hold, so the AI asks the human before starting anything.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p hold-test/gdd/subgoals/candidates hold-test/gdd/subgoals/in-progress hold-test/gdd/subgoals/in-review hold-test/gdd/subgoals/done hold-test/gdd/reviews hold-test/gdd/adr
mkdir -p hold-test/gdd
cat > hold-test/gdd/goal.md <<'EOF'
---
prefer: certainty
avoid: none
---
# Goal: stalled

## North star

a.txt exists.

## Acceptance scenarios

1. [a-file] hold-test/a.txt holds a
   - Check: `test "$(cat hold-test/a.txt)" = a`

## Definition of done

1. [gate] every sub-goal passes the project's checks
   - Check: `true`

## Premises

- None
EOF
mkdir -p hold-test/gdd
cat > hold-test/gdd/state.md <<'EOF'
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
mkdir -p hold-test/gdd/subgoals/candidates
cat > hold-test/gdd/subgoals/candidates/a-txt.md <<'EOF'
---
type: build
advances: a-file
depends_on: none
touches: hold-test/a.txt
---
# Create hold-test/a.txt containing a

## Done when

1. [exact] a.txt is a
   - Check: `test "$(cat hold-test/a.txt)" = a`

## What to show

- the result
EOF
mkdir -p hold-test/gdd/reviews
cat > hold-test/gdd/reviews/try-1.md <<'EOF'
---
subgoal: try-1
loop: 1
progress: a-file=not-met open_uncertainties=1
pr: none
overridden: false
---
# Sub-goal review: try-1


## Decision

<!-- gdd-loop writes "Pull request opened: <URL>" here. A Decide sub-goal also records the option the human chose. -->
No pull request (no remote); branch gdd/try
EOF
mkdir -p hold-test/gdd/reviews
cat > hold-test/gdd/reviews/try-2.md <<'EOF'
---
subgoal: try-2
loop: 2
progress: a-file=not-met open_uncertainties=1
pr: none
overridden: false
---
# Sub-goal review: try-2


## Decision

<!-- gdd-loop writes "Pull request opened: <URL>" here. A Decide sub-goal also records the option the human chose. -->
No pull request (no remote); branch gdd/try
EOF
mkdir -p hold-test/gdd/reviews
cat > hold-test/gdd/reviews/try-3.md <<'EOF'
---
subgoal: try-3
loop: 3
progress: a-file=not-met open_uncertainties=1
pr: none
overridden: false
---
# Sub-goal review: try-3


## Decision

<!-- gdd-loop writes "Pull request opened: <URL>" here. A Decide sub-goal also records the option the human chose. -->
No pull request (no remote); branch gdd/try
EOF
git add -A
git commit -qm fixture
