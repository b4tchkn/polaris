---
subgoal: <slug>
loop: <n>
progress: <the progress line from gdd-status.sh>
pr: <pull request URL, or none>
overridden: false
---
# Sub-goal review: <slug> <what it achieves>

## What was built and how to try it

- <Deliverable, branch gdd/<slug>>
- Demo: <link, recording, or how to run it>

## Checks

| Condition | Check | Result | By |
|---|---|---|---|
| <id> <condition> | <command / observe / human> | <met / not-met / partial / not checked / for the human> | <gdd-status.sh / evaluator / human> |

## Distance to the goal

- <Each acceptance scenario and the gate: met / not-met / observe / human, and what changed in this loop>
- <Open uncertainties, and which were resolved>

## Least confident

- <file:line: what is uncertain and how to check it (each becomes a line comment on the pull request)>

## Retrospective

- Keep: <what worked>
- Problems: <rework, what needed the evaluator or the human that a check could have caught>
- Learnings added: <to state.md, or none>
- Candidates added: <slugs, or none>

## Next

- Next: <slug>: <why it moves the goal or an uncertainty the most>
- Next-reviewer: <agrees / objects: reason>

## Decision

<!-- gdd-loop writes "Pull request opened: <URL>" here. A Decide sub-goal also records the option the human chose. -->
