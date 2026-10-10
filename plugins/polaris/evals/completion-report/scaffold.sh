#!/bin/bash
# done-txt is finished and every scenario is met. history.jsonl holds the AI asking whether to add sub-goals or write the report; the prompt is the human's answer.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p done-test/gdd/subgoals/candidates done-test/gdd/subgoals/in-progress done-test/gdd/subgoals/done done-test/gdd/reviews
cat > done-test/gdd/goal.md <<'EOF'
---
scenario_1_check: test "$(cat done-test/done.txt)" = done
done_checks: none
max_files: 5
max_lines: 50
prefer: certainty
avoid: none
---
# Goal: completion test

## North star

done.txt exists.

## Acceptance scenarios

1. done-test/done.txt holds done

## Definition of done

- The files are committed on the sub-goal's branch.

## Premises

- None
EOF
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
mkdir -p done-test/gdd/adr
cat > done-test/gdd/subgoals/done/done-txt.md <<'EOF'
---
type: build
advances: scenario_1
depends_on: none
touches: done-test/done.txt
criterion_1: done.txt is done | quantitative | test "$(cat done-test/done.txt)" = done
---
# Create done-test/done.txt containing done

- Done when: it works through its real entry point
- What to show: the file's content
EOF
cat > done-test/gdd/reviews/done-txt.md <<'EOF'
---
subgoal: done-txt
loop: 1
progress: scenario_1=met open_uncertainties=0
auto: false
overridden: false
rework: none
---
# Sub-goal review: done-txt


## Decision

<!-- gdd-loop writes the outcome here: "Proceed (automatic). Next: <slug>", or the human's answer (OK / Change something with the comment / Stop). -->
OK.
EOF
printf 'done\n' > done-test/done.txt
git add -A
git commit -qm fixture
