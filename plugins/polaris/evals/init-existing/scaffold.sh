#!/bin/bash
# gdd/ already holds real state. gdd-init must ask before overwriting, and must not touch the files without an answer.
set -e
mkdir -p gdd/subgoals/candidates gdd/adr
mkdir -p gdd
cat > gdd/goal.md <<'EOF'
---
prefer: certainty
avoid: none
---
# Goal: keep me

## North star

An existing goal that must not be overwritten without asking.

## Acceptance scenarios

1. [kept] This file survives a `/polaris:gdd-init` run that nobody confirmed.
   - Check: human: look at the file
EOF
mkdir -p ./gdd
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
