# Review and retrospect

Do this for each finished sub-goal. When several finished together, review all of them before `steps/finish.md`. Write every `gdd/` file below (uncertainties, candidates, the review) on the sub-goal's branch (in the worker's worktree), not in the main checkout; its pull request carries them.

## Check

- Run `gdd-check.sh <gdd-dir> <slug> --at <worktree path>`: it runs every command check of the sub-goal and the gate on the worker's branch. Its results are final for those conditions; put them in the review's Checks table with "gdd-check.sh" as the source.
- Run the Agent tool with `subagent_type: "polaris:subgoal-verifier"`, giving it only the sub-goal file, the worktree path and branch, and the output of the step above. Do not pass your own view of the result. It reports whether each command check really tests its condition, and judges the `observe:` conditions. Add its rows to the table unchanged; if you disagree, say so under "Least confident".
- `human:` conditions stay "for the human"; they become line comments on the pull request.
- Run `gdd-check.sh <gdd-dir> --at <worktree path>` and copy its `progress:` line into the review's frontmatter.
- A failing command check or gate means the sub-goal is not done: resume the worker with SendMessage to fix it, then check again. Do not loosen the check.

## Retrospect

- From this sub-goal and all learnings in `gdd/reviews/`, list what to keep and the problems (rework, conditions that needed the subgoal-verifier or the human although a check could have decided them).
- Turn what you learned into one of two things:
  - **Learning**: something later loops should follow → add it to the Learnings section of this review. When this sub-goal turned an earlier learning into a check, hook, or rule, add that learning's text with "→ hardened: <where>" here; do not edit the earlier review.
  - **Candidate**: anything that needs work → write it as a candidate sub-goal with `advances:` (use `process` for a change to how the loop runs). Conditions that needed the subgoal-verifier or the human more than once are candidates for a deterministic check.
- Uncertainties: for each one this sub-goal answered, set `status: resolved` and write the answer in its file; write each new one as a file from `templates/uncertainty.md`.

## Write the review

- Write `gdd/reviews/<slug>.md` in the shape of `templates/review.md`. `loop:` is one more than the highest `loop:` in `gdd/reviews/`.
- Under "Least confident", list every place you are unsure of as `file:line: what is uncertain and how to check it`, plus every condition that is `partial`, `not checked`, or for the human. Be honest: these become the pull request's line comments.
