#!/bin/bash
# A gdd/ exactly as gdd-init leaves it: goal.md is still the template.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p gdd/subgoals/candidates gdd/subgoals/in-progress gdd/subgoals/in-review gdd/subgoals/done gdd/reviews gdd/adr
mkdir -p gdd
cat > gdd/goal.md <<'EOF'
---
prefer: <speed | certainty>
avoid: <paths the AI must not edit without asking, comma-separated, or none>
---
# Goal: <goal name>

## North star

<What this goal should achieve, in one sentence>

## Acceptance scenarios

> Outcomes of the whole goal, from the user's side: 3 to 5, at most 7. Keep one only if the goal would be unmet when it alone fails. Edge cases belong in a sub-goal's "Done when".
> Each gets an `[id]` and a `Check:` line. Prefer a command (tests, scripts): `` Check: `<command>` ``. Otherwise `Check: observe: <what to look at>` or `Check: human: <why only a human can judge>`.

1. [<id>] <An outcome that shows the goal is reached>
   - Check: `<command that exits 0 when it holds>`

## Definition of done

> The gate every sub-goal passes: one command that runs the project's formatter, linter, type check, build, and tests.

1. [gate] <What every sub-goal must pass>
   - Check: `<one command, e.g. npm run check>`

## Premises

- None
EOF
mkdir -p gdd
cat > gdd/state.md <<'EOF'
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
git add -A
git commit -qm fixture
