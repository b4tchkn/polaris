#!/bin/bash
# A gdd/ exactly as gdd-init leaves it: goal.md is still the template.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p gdd/subgoals/candidates gdd/subgoals/in-progress gdd/subgoals/done gdd/reviews
cat > gdd/goal.md <<'EOF'
---
scenario_1_check: <shell command that exits 0 when scenario 1 holds, run from the repository root; or "human" when only the human can judge it>
done_checks: <shell command every sub-goal must pass (tests, lint), or "none">
max_files: 10
max_lines: 300
prefer: <speed | certainty>
avoid: <areas the AI must not touch, or "none">
---
# Goal: <goal name>

## North star

<What this goal should achieve, in one sentence>

## Acceptance scenarios

1. <A scenario that shows the goal is reached>

## Definition of done

- <The quality bar every sub-goal meets (what done_checks runs, plus anything a command cannot check)>

## Premises

- None
EOF
cat > ./gdd/state.md <<'EOF'
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
cat > ./gdd/adr.md <<'EOF'
# ADR

> Decisions the human made, with the human's reasons. Append only; never rewrite.
EOF
git add -A
git commit -qm fixture
