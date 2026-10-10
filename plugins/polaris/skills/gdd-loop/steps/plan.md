# Plan and hand out work

1. Run `gdd-status.sh <gdd-dir>`. If a sub-goal is already in `in-progress/` without a review, hand it out again (step 4) instead of choosing a new one.
2. If the last review's Decision already names the next sub-goal ("Next: <slug>"), take it. Otherwise choose among candidates with `ready=yes`:
   - First the one that moves the most acceptance scenarios from `not-met` toward `met`, or resolves the biggest open uncertainty (the one that would change the most plans if answered differently).
   - Prefer small sub-goals after a rejection, larger after approvals. Follow `prefer:` in `goal.md` when two are close.
   - Add more ready candidates to work in parallel only when their `overlaps` are empty with respect to each other and to what is in progress.
   - If no candidate fits, write a new one from `templates/subgoal.md`. If the goal looks reached, go to "Goal reached" in `steps/decide.md`.
3. For each chosen sub-goal, fill in its file before moving it: the sentence, Done when, What to show, `depends_on`, `touches` (paths it will change), and criteria. Make criteria quantitative with a command wherever a command can tell (`criterion_<n>: <what> | quantitative | <command>`); use `| qualitative` only for what the human must judge. Then `git mv` it to `gdd/subgoals/in-progress/` and commit `gdd/`.
4. Hand out each in-progress sub-goal with the Agent tool, `subagent_type: "polaris:worker"`. Give it the path of the sub-goal file, `goal.md`, the Learnings and Rejected ideas from `state.md`, and the branch name `gdd/<slug>`. With one sub-goal run it in the foreground; with several, run them in the background at once.
   - A Decide sub-goal does not need a worker: prepare what to show (a spec, a mock, a comparison) yourself in `gdd/` or `docs/`, then review it.
5. When a worker returns with a question instead of a result, ask the human with AskUserQuestion (three options with trade-offs, as in the rules), append the answer and reason to `gdd/adr.md`, and pass the answer back with SendMessage to the same worker so it continues where it stopped.
