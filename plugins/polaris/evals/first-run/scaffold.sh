#!/bin/bash
# A gdd/ exactly as gdd-init leaves it: goal.md is still the template.
set -e
mkdir -p gdd
cat > gdd/goal.md <<'EOF'
# Goal: <goal name>

## North star

<What this goal should achieve>

## Acceptance scenarios

1. <A scenario that shows the goal is reached>

## Premises

- None
EOF
mkdir -p gdd/subgoals gdd/uncertainties gdd/reviews gdd/adr
