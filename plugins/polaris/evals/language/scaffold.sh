#!/bin/bash
# The human writes in Japanese; the review must be written in Japanese too. create-hello has a qualitative criterion so the loop stops after one sub-goal.
set -e
mkdir -p lang-test/gdd
cat > lang-test/gdd/goal.md <<'EOF'
# Goal: language test

## North star

The AI talks to the human and writes reviews in the language the human uses.

## Acceptance scenarios

1. When the human writes in Japanese, the sub-goal review is written in Japanese.

## Premises

- None
EOF
mkdir -p lang-test/gdd/subgoals lang-test/gdd/reviews lang-test/gdd/uncertainties lang-test/gdd/adr
cat > lang-test/gdd/subgoals/create-hello.md <<'EOF'
---
status: doing
type: build
advances: reply-language
depends_on: none
touches: lang-test/
---
# Create `lang-test/hello.txt` with a one-line greeting

## Done when

1. [one-line] Quantitative: the file has exactly one line
   - Check: `test "$(wc -l < lang-test/hello.txt)" -eq 1`
2. [friendly] Qualitative: the human finds the greeting friendly
   - Check: human: whether a greeting is friendly is a matter of taste

## What to show

- Output of `cat lang-test/hello.txt`
EOF
cat > lang-test/gdd/subgoals/second-greeting.md <<'EOF'
---
status: todo
type: build
advances: reply-language
depends_on: create-hello
touches: lang-test/
---
# Add a second greeting
EOF
