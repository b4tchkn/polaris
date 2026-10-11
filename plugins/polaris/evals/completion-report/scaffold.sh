#!/bin/bash
# done-txt is merged and every scenario is met. history.jsonl holds the AI asking whether to add sub-goals or write the report; the prompt is the human's answer.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p done-test/gdd/subgoals/candidates done-test/gdd/subgoals/in-progress done-test/gdd/subgoals/in-review done-test/gdd/subgoals/done done-test/gdd/reviews done-test/gdd/adr
mkdir -p done-test/gdd
cat > done-test/gdd/goal.md <<'EOF'
---
prefer: certainty
avoid: none
---
# Goal: completion test

## North star

done.txt exists.

## Acceptance scenarios

1. [done-file] done-test/done.txt holds done
   - Check: `test "$(cat done-test/done.txt)" = done`

## Definition of done

1. [gate] every sub-goal passes the project's checks
   - Check: `true`

## Premises

- None
EOF
mkdir -p done-test/gdd
cat > done-test/gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- None

## Built so far

- done-test/done.txt

## Uncertainties

> What is still unknown about reaching the goal. One per line: `- U<n> <question> | open` or `| resolved: <answer>`.

- None

## Rejected ideas

- None

## Learnings

- None
EOF
mkdir -p done-test/gdd/subgoals/done
cat > done-test/gdd/subgoals/done/done-txt.md <<'EOF'
---
type: build
advances: done-file
depends_on: none
touches: done-test/done.txt
---
# Create done-test/done.txt containing done

## Done when

1. [exact] done.txt is done
   - Check: `test "$(cat done-test/done.txt)" = done`

## What to show

- the result
EOF
mkdir -p done-test/gdd/reviews
cat > done-test/gdd/reviews/done-txt.md <<'EOF'
---
subgoal: done-txt
loop: 1
progress: done-file=met open_uncertainties=0
pr: none
overridden: false
---
# Sub-goal review: done-txt


## Decision

<!-- gdd-loop writes "Pull request opened: <URL>" here. A Decide sub-goal also records the option the human chose. -->
No pull request (no remote); branch gdd/done-txt
EOF
printf 'done\n' > done-test/done.txt
git add -A
git commit -qm fixture
