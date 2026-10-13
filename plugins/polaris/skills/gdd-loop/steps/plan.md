# Plan and hand out work

1. Run `gdd-check.sh <gdd-dir>` and `gdd-status.sh <gdd-dir>`. Run the Agent tool with `subagent_type: "polaris:goal-owner"` to decide what comes next, giving it the paths of `goal.md`, `state.md`, `gdd/adr/`, and `gdd/subgoals/`, and both outputs. Follow its answer:
   - `new:` → write each as a candidate as in `steps/set-goal.md` 6, in a pull request of its own (`steps/finish.md`).
   - `start:` → those sub-goals, in parallel when there are several.
   - `wait:` → nothing can start now (for example, everything left waits for a merge). Tell the human what it waits for, and stop.
   - `reached:` → go to "Goal reached" in `steps/finish.md`.
   - If you disagree, tell the human why; do not silently pick something else.
2. Hand out each chosen sub-goal with the Agent tool, `subagent_type: "polaris:worker"`. Give it the path of the sub-goal file from the repository root, `goal.md`, and the Learnings and Rejected ideas from `state.md`. With one sub-goal run it in the foreground; with several, run them in the background at once.
   - A Decide sub-goal does not need a worker: make a branch for it from the main branch, prepare what to show on it (a spec, a mock, a comparison of three options with trade-offs), ask the human to choose with AskUserQuestion, ask why, and record it in `gdd/adr/` on that branch.
3. When a worker returns with a question instead of a result, ask the human with AskUserQuestion (three options with trade-offs, as in the rules), record the answer and reason in `gdd/adr/` in the worker's worktree, and pass the answer back with SendMessage to the same worker so it continues where it stopped.
