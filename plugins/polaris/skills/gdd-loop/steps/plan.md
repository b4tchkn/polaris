# Plan and hand out work

1. If a sub-goal is already in `in-progress/` without a review, hand it out again (step 4) instead of choosing a new one.
2. Run `gdd-check.sh <gdd-dir>` and `gdd-status.sh <gdd-dir>`. Run the Agent tool with `subagent_type: "polaris:goal-owner"` to decide what comes next, giving it the paths of `goal.md`, `state.md`, `gdd/adr/`, and `gdd/subgoals/`, and both outputs. Follow its answer:
   - `new:` → write each as a candidate from `templates/subgoal.md`.
   - `start:` → those sub-goals, in parallel when there are several.
   - `reached:` → go to "Goal reached" in `steps/finish.md`.
   - If you disagree, tell the human why; do not silently pick something else.
3. For each chosen sub-goal, fill in its file before moving it: the sentence, `depends_on`, `touches` (paths it will change), What to show, and Done when: 1 to 5 `[id]` conditions, edge cases included, each with a `Check:`. Make each check a command (a test or script that exits 0 when the condition holds) unless a command cannot decide it. Then `git mv` it to `gdd/subgoals/in-progress/` and commit `gdd/`.
4. Hand out each in-progress sub-goal with the Agent tool, `subagent_type: "polaris:worker"`. Give it the path of the sub-goal file, `goal.md`, the Learnings and Rejected ideas from `state.md`, and the branch name `gdd/<slug>`. With one sub-goal run it in the foreground; with several, run them in the background at once.
   - A Decide sub-goal does not need a worker: prepare what to show (a spec, a mock, a comparison of three options with trade-offs) yourself, ask the human to choose with AskUserQuestion, ask why, and record it in `gdd/adr/`.
5. When a worker returns with a question instead of a result, ask the human with AskUserQuestion (three options with trade-offs, as in the rules), record the answer and reason in `gdd/adr/`, and pass the answer back with SendMessage to the same worker so it continues where it stopped.
