---
subgoal: <slug>
loop: <n>
progress: <the progress line from gdd-check.sh>
---
# Sub-goal review: <slug> <what it achieves>

## What was built and how to try it

- <Deliverable, and the branch it is on>
- Demo: <link, recording, or how to run it>

## Checks

| Condition | Check | Result | By |
|---|---|---|---|
| <id> <condition> | <command / observe / human> | <met / not-met / partial / not checked / for the human> | <gdd-check.sh / subgoal-verifier / human> |

## Distance to the goal

- <Each acceptance scenario and the gate: met / not-met / observe / human, and what changed in this loop>
- <Open uncertainties, and which were resolved>

## Least confident

- <file:line: what is uncertain and how to check it (each becomes a line comment on the pull request)>

## Retrospective

- Keep: <what worked>
- Problems: <rework, what needed the subgoal-verifier or the human that a check could have caught>
- Learnings added: <to state.md, or none>
- Candidates added: <slugs, or none>

## Decision

<!-- A Decide sub-goal records the option the human chose and why. -->
