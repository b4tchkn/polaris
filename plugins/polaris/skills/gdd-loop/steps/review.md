# Review and retrospect

Do this for each finished sub-goal, one at a time. When several finished together, review all of them before going to `steps/decide.md`.

## Evaluate

- Run the Agent tool with `subagent_type: "polaris:evaluator"`, giving it only the sub-goal file, where the deliverables are (the worker's worktree path and branch), and how to run them. Do not pass your own view of the result. Paste its table into the review unchanged; if you disagree with a verdict, say so under "Least confident decision".
- Run `gdd-status.sh <gdd-dir> --at <worktree path>` (checks run on the sub-goal's work, not on the main checkout) and copy its `progress:` line into the review's frontmatter. For a Decide sub-goal, leave out `--at`.

## Retrospect

- From this sub-goal and all learnings in `state.md`, list what to keep and the problems (rework, where the human stepped in, why something was rejected).
- If this sub-goal had to fix something an earlier done sub-goal claimed to have done, set `rework:` to that slug in the review.
- Turn what you learned into one of two things:
  - **Learning**: something later loops should follow → add it to Learnings in `state.md` now. When a learning has been turned into a rule or a step, keep it and add "→ hardened: <where>".
  - **Candidate**: anything that needs work (fix the process, harden a learning into a hook or rule, a new idea for the goal) → write it as a candidate sub-goal with `advances:` (use `process` for a change to how the loop runs). It is chosen in a later plan like any other.
- Update "Uncertainties" in `state.md`: mark resolved ones `| resolved: <answer>`, add new ones.
- Rewrite `state.md` within one page: Now / Built so far / Uncertainties / Rejected ideas / Learnings.

## Choose what comes next

- Choose the next sub-goal as in `steps/plan.md` step 2 (do not move it yet).
- Run the Agent tool with `subagent_type: "polaris:next-reviewer"`, giving it `goal.md`, the Uncertainties, the files in `gdd/adr/`, the candidates, and your choice with its reason. Put its verdict in the review. If it objects, either take its alternative (say so) or keep yours and let the human decide.

## Write the review

- Write `gdd/reviews/<slug>.md` in the shape of `templates/review.md`. `loop:` is one more than the highest `loop:` in `gdd/reviews/`. Leave the Decision section empty.
- Show the same content in the chat, then go to `steps/decide.md`.
