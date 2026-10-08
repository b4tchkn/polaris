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
cat > gdd/subgoals.md <<'EOF'
# Sub-goals

> The goal in goal.md, broken into sub-goals. The AI proposes, the human approves (enforced by the ask rules in `.claude/settings.json`).

## Next: SG0 <goal>

| Item | Content |
|---|---|
| Goal | <What this sub-goal achieves, in one sentence> |
| Type and done condition | <Decide: settle a spec, approach, or scope; done when the human agrees. Build: make something that works; done when it works through its real entry point> |
| Evaluation criteria | <How to tell whether it went well. Mark each as quantitative (measured by numbers) or qualitative (judged by the human)> |
| What to show | <What the human looks at to decide when the sub-goal is done> |

## Later (rough outlook)

> Only the next sub-goal is detailed. Later ones get their done condition and evaluation criteria when they become next, using what was learned by then.

| # | Goal | Type |
|---|---|---|
EOF
cat > gdd/state.md <<'EOF'
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
cat > gdd/adr.md <<'EOF'
# ADR

> Decisions chosen from options. Append only; never rewrite earlier entries.
EOF
