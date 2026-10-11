#!/bin/bash
# a-txt's branch was merged into main. The run moves it to done/, which makes b-txt (depends on a-txt) ready, and builds b-txt.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p merged-test/gdd/subgoals/candidates merged-test/gdd/subgoals/in-progress merged-test/gdd/subgoals/in-review merged-test/gdd/subgoals/done merged-test/gdd/reviews merged-test/gdd/adr
mkdir -p merged-test/gdd
cat > merged-test/gdd/goal.md <<'EOF'
---
prefer: certainty
---
# Goal: two files

## North star

Two files exist.

## Acceptance scenarios

1. [a-file] merged-test/a.txt holds a
   - Check: `test "$(cat merged-test/a.txt)" = a`
2. [b-file] merged-test/b.txt holds b
   - Check: `test "$(cat merged-test/b.txt)" = b`

## Definition of done

1. [gate] every sub-goal passes the project's checks
   - Check: `true`

## Premises

- None
EOF
mkdir -p merged-test/gdd
cat > merged-test/gdd/state.md <<'EOF'
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
mkdir -p merged-test/gdd/subgoals/in-review
cat > merged-test/gdd/subgoals/in-review/a-txt.md <<'EOF'
---
type: build
advances: a-file
depends_on: none
touches: merged-test/a.txt
---
# Create merged-test/a.txt containing a

## Done when

1. [exact] a.txt is a
   - Check: `test "$(cat merged-test/a.txt)" = a`

## What to show

- the result
EOF
mkdir -p merged-test/gdd/subgoals/candidates
cat > merged-test/gdd/subgoals/candidates/b-txt.md <<'EOF'
---
type: build
advances: b-file
depends_on: a-txt
touches: merged-test/b.txt
---
# Create merged-test/b.txt containing b

## Done when

1. [exact] b.txt is b
   - Check: `test "$(cat merged-test/b.txt)" = b`

## What to show

- the result
EOF
mkdir -p merged-test/gdd/reviews
cat > merged-test/gdd/reviews/a-txt.md <<'EOF'
---
subgoal: a-txt
loop: 1
progress: a-file=met b-file=not-met open_uncertainties=0
pr: none
overridden: false
---
# Sub-goal review: a-txt


## Decision

<!-- gdd-loop writes "Pull request opened: <URL>" here. A Decide sub-goal also records the option the human chose. -->
No pull request (no remote); branch gdd/a-txt
EOF
git add -A
git commit -qm fixture
git switch -q -c gdd/a-txt
printf 'a\n' > merged-test/a.txt
git add -A
git commit -qm a-txt
git switch -q main
git merge -q gdd/a-txt
