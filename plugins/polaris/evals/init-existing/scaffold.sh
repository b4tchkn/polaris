#!/bin/bash
# gdd/ already holds real state. gdd-init must ask before overwriting, and must not touch the files without an answer.
set -e
mkdir -p gdd
cat > gdd/goal.md <<'EOF'
# Goal: keep me

## North star

An existing goal that must not be overwritten without asking.

## Acceptance scenarios

1. This file survives a `/polaris:gdd-init` run that nobody confirmed.

## Premises

- None
EOF
mkdir -p gdd/uncertainties
printf -- '---\nstatus: open\n---\n# Is this uncertainty kept?\n' > gdd/uncertainties/keep-me.md
