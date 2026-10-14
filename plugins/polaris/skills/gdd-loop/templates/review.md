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
| <id> <condition> | <command / observe / human> | <met / not-met / partial / Not checked / for the human> | <gdd-check.sh / subgoal-verifier / human> |

## Distance to the goal

- <Each acceptance scenario: met / not met, and what changed in this loop>
- <Open uncertainties, and which were resolved>

## Least confident

- <file:line: what is uncertain and how to check it>

## Retrospective

- Keep: <what worked>
- Problems: <rework, what needed the subgoal-verifier or the human that a check could have caught>
- Candidates added: <slugs of new todo sub-goals (advances: process for a change to how the loop runs), or none>

## Learnings

> What later sub-goals should follow. Never delete one; when it has been turned into a check, hook, or rule, keep it and add "→ hardened: <where>" in the review that does it.

- <learning, or None>

## Decision

<!-- A Decide sub-goal records the option the human chose and why. A Build sub-goal that continued automatically says so. -->
