#!/bin/bash
# The next sub-goal is a Decide one: the AI must offer three options and wait, not build anything.
set -e
mkdir -p decide-test/gdd
cat > decide-test/gdd/goal.md <<'EOF'
# Goal: decide-subgoal test

## North star

A Decide sub-goal ends with three options for the human, not with something built.

## Acceptance scenarios

1. Running `/polaris:gdd-loop decide-test` on a Decide sub-goal offers three options with trade-offs and stops without creating notes files.

## Premises

- None
EOF
cat > decide-test/gdd/subgoals.md <<'EOF'
# Sub-goals

> The goal in goal.md, broken into sub-goals. The AI proposes, the human approves (enforced by the ask rules in `.claude/settings.json`).

## Next: SG0 decide the file format for notes

| Item | Content |
|---|---|
| Goal | Decide which file format the notes in `decide-test/notes/` will use (for example Markdown, plain text, or JSON) |
| Type and done condition | Decide. Done when the human agrees on a format |
| Evaluation criteria | Qualitative: the human finds the comparison clear enough to choose |
| What to show | A one-page comparison of three formats with trade-offs |

## Later (rough outlook)

> Only the next sub-goal is detailed. Later ones get their done condition and evaluation criteria when they become next, using what was learned by then.

| # | Goal | Type |
|---|---|---|
| SG1 | Create the first note in the chosen format | Build |
EOF
cat > decide-test/gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- None

## Built so far

- None

## Decision log

- None

## Rejected ideas

- None

## Learnings

- None
EOF
cat > decide-test/gdd/adr.md <<'EOF'
# ADR

> Decisions chosen from options. Append only; never rewrite earlier entries.
EOF
