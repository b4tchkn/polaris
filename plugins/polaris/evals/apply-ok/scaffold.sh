#!/bin/bash
# a-txt is reviewed and the human wrote OK in its Decision section. The run finishes a-txt and goes on to b-txt.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p ok-test/gdd/subgoals/candidates ok-test/gdd/subgoals/in-progress ok-test/gdd/subgoals/done ok-test/gdd/reviews
cat > ok-test/gdd/goal.md <<'EOF'
---
scenario_1_check: test "$(cat ok-test/a.txt)" = a
scenario_2_check: test "$(cat ok-test/b.txt)" = b
scenario_3_check: test "$(cat ok-test/c.txt)" = c
done_checks: none
max_files: 5
max_lines: 50
prefer: certainty
avoid: none
---
# Goal: apply test

## North star

Small files exist.

## Acceptance scenarios

1. ok-test/a.txt holds a
2. ok-test/b.txt holds b
3. ok-test/c.txt holds c

## Definition of done

- The files are committed on the sub-goal's branch.

## Premises

- None
EOF
cat > ok-test/gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- a-txt built; waiting for the human's decision.

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
cat > ok-test/gdd/adr.md <<'EOF'
# ADR

> Decisions the human made, with the human's reasons. Append only; never rewrite.
EOF
cat > ok-test/gdd/subgoals/in-progress/a-txt.md <<'EOF'
---
type: build
advances: scenario_1
depends_on: none
touches: ok-test/a.txt
criterion_1: a.txt is a | quantitative | test "$(cat ok-test/a.txt)" = a
---
# Create ok-test/a.txt containing a

- Done when: it works through its real entry point
- What to show: the file's content
EOF
cat > ok-test/gdd/subgoals/candidates/b-txt.md <<'EOF'
---
type: build
advances: scenario_2
depends_on: none
touches: ok-test/b.txt
criterion_1: b.txt is b | quantitative | test "$(cat ok-test/b.txt)" = b
---
# Create ok-test/b.txt containing b

- Done when: it works through its real entry point
- What to show: the file's content
EOF
cat > ok-test/gdd/subgoals/candidates/c-txt.md <<'EOF'
---
type: build
advances: scenario_3
depends_on: none
touches: ok-test/c.txt
criterion_1: c.txt is c | quantitative | test "$(cat ok-test/c.txt)" = c
---
# Create ok-test/c.txt containing c

- Done when: it works through its real entry point
- What to show: the file's content
EOF
cat > ok-test/gdd/reviews/a-txt.md <<'EOF'
---
subgoal: a-txt
loop: 1
progress: scenario_1=met scenario_2=not-met scenario_3=not-met open_uncertainties=0
auto: false
overridden: false
rework: none
---
# Sub-goal review: a-txt

## What was built and how to try it

- ok-test/a.txt on branch gdd/a-txt

## Evaluation against the criteria

| Criterion | Quantitative / qualitative | Result | Met? |
|---|---|---|---|
| a.txt is a | quantitative | exit 0 | Met |

## Next

- Next: b-txt: moves scenario_2
- Next-reviewer: agrees

## Decision

<!-- gdd-loop writes the outcome here: "Proceed (automatic). Next: <slug>", or the human's answer (OK / Change something with the comment / Stop). -->
OK. Next: b-txt
EOF
git add -A
git commit -qm fixture
git switch -q -c gdd/a-txt
mkdir -p $(dirname ok-test/a.txt)
printf 'a\n' > ok-test/a.txt
git add -A
git commit -qm 'a-txt'
git switch -q main
