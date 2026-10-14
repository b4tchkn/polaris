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
- Candidates added: <slugs, or none>

## Improvement proposals

| # | Kind | Change | Where it goes | Trade-off |
|---|---|---|---|---|
| 1 | <Add learning / Fix the process / Harden a learning / Revise sub-goals> | <What changes> | <File> | <What gets better / what it costs> |

## Next sub-goal options

| Option | Goal | Type | Done when (with Check) | What to show | Trade-off |
|---|---|---|---|---|---|
| A | | | | | |
| B | | | | | |
| C | | | | | |

## Learnings

> What later sub-goals should follow. Never delete one; when it has been turned into a check, hook, or rule, keep it and add "→ hardened: <where>" in the review that does it.

- <learning, or None>

## Decision

<!-- gdd-loop writes the human's choice here: Proceed / Change direction / Stop (with a comment for Change direction). Also list the adopted proposals (e.g. Adopt 1, 3) -->
