#!/bin/bash
# One candidate covers the only scenario. After it, every scenario is met and nothing is left: the AI says the goal looks reached instead of inventing more work.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p goal-done/gdd/subgoals/candidates goal-done/gdd/subgoals/in-progress goal-done/gdd/subgoals/done goal-done/gdd/reviews
cat > goal-done/gdd/goal.md <<'EOF'
---
scenario_1_check: test "$(cat goal-done/done.txt)" = done
done_checks: none
max_files: 5
max_lines: 50
prefer: certainty
avoid: none
---
# Goal: goal reached test

## North star

done.txt exists.

## Acceptance scenarios

1. goal-done/done.txt holds done

## Definition of done

- The files are committed on the sub-goal's branch.

## Premises

- None
EOF
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
mkdir -p goal-done/gdd/adr
cat > goal-done/gdd/subgoals/candidates/done-txt.md <<'EOF'
---
type: build
advances: scenario_1
depends_on: none
touches: goal-done/done.txt
criterion_1: done.txt is done | quantitative | test "$(cat goal-done/done.txt)" = done
---
# Create goal-done/done.txt containing done

- Done when: it works through its real entry point
- What to show: the file's content
EOF
git add -A
git commit -qm fixture
