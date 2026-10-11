# Plan and hand out work

1. If a sub-goal is already in `in-progress/` without a review, hand it out again (step 4) instead of choosing a new one.
2. Choose among candidates with `ready=yes` in `gdd-status.sh`:
   - First the one that moves the most acceptance scenarios from `not-met` toward `met`, or resolves the biggest open uncertainty (the one that would change the most plans if answered differently).
   - Prefer small sub-goals. Follow `mode:` in `goal.md` when two are close (`fast`: the quicker one; `careful`: the one that removes more risk).
   - Add more ready candidates to work in parallel only when their `overlaps` are empty with respect to each other and to what is in progress.
   - If no candidate fits, write a new one from `templates/subgoal.md`. If every scenario is `met` (and the `human:` ones are confirmed) and nothing advances an open uncertainty, go to "Goal reached" in `steps/finish.md`.
3. For each chosen sub-goal, fill in its file before moving it: the sentence, `depends_on`, `touches` (paths it will change), What to show, and Done when: 1 to 5 `[id]` conditions, edge cases included, each with a `Check:`. Make each check a command (a test or script that exits 0 when the condition holds) unless a command cannot decide it. Then `git mv` it to `gdd/subgoals/in-progress/` and commit `gdd/`.
4. Hand out each in-progress sub-goal with the Agent tool, `subagent_type: "polaris:worker"`. Give it the path of the sub-goal file, `goal.md`, the Learnings and Rejected ideas from `state.md`, and the branch name `gdd/<slug>`. With one sub-goal run it in the foreground; with several, run them in the background at once.
   - A Decide sub-goal does not need a worker: prepare what to show (a spec, a mock, a comparison of three options with trade-offs) yourself, ask the human to choose with AskUserQuestion, ask why, and record it in `gdd/adr/`.
5. When a worker returns with a question instead of a result, ask the human with AskUserQuestion (three options with trade-offs, as in the rules), record the answer and reason in `gdd/adr/`, and pass the answer back with SendMessage to the same worker so it continues where it stopped.
