#!/bin/bash
# gdd/ already holds real state. gdd-init must ask before overwriting, and must not touch the files without an answer.
set -e
mkdir -p gdd/subgoals/candidates
cat > gdd/goal.md <<'EOF'
---
scenario_1_check: human
done_checks: none
---
# Goal: keep me

## North star

An existing goal that must not be overwritten without asking.

## Acceptance scenarios

1. This file survives a `/polaris:gdd-init` run that nobody confirmed.
EOF
cat > ./gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- Mid-goal.

## Built so far

- Something valuable.

## Uncertainties

> What is still unknown about reaching the goal. One per line: `- U<n> <question> | open` or `| resolved: <answer>`.

- None

## Rejected ideas

- None

## Learnings

- Keep this learning.
EOF
mkdir -p ./gdd/adr
