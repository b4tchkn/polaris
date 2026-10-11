#!/bin/bash
# The human writes in Japanese; the review must be in Japanese too.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p lang-test/gdd/subgoals/candidates lang-test/gdd/subgoals/in-progress lang-test/gdd/subgoals/in-review lang-test/gdd/subgoals/done lang-test/gdd/reviews lang-test/gdd/adr
mkdir -p lang-test/gdd
cat > lang-test/gdd/goal.md <<'EOF'
---
prefer: certainty
---
# Goal: greeting

## North star

hello.txt holds a friendly greeting.

## Acceptance scenarios

1. [friendly] lang-test/hello.txt holds a friendly one-line greeting
   - Check: human: only a reader can tell

## Definition of done

1. [gate] every sub-goal passes the project's checks
   - Check: `true`

## Premises

- None
EOF
mkdir -p lang-test/gdd
cat > lang-test/gdd/state.md <<'EOF'
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
mkdir -p lang-test/gdd/subgoals/candidates
cat > lang-test/gdd/subgoals/candidates/hello-txt.md <<'EOF'
---
type: build
advances: friendly
depends_on: none
touches: lang-test/hello.txt
---
# Create lang-test/hello.txt with a one-line greeting

## Done when

1. [one-line] the file has one line
   - Check: `test $(wc -l < lang-test/hello.txt) -eq 1`
2. [friendly] the greeting is friendly
   - Check: human: only a reader can tell

## What to show

- the result
EOF
git add -A
git commit -qm fixture
