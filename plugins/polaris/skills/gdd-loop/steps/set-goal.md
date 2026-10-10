# Set or change the goal

The goal is the yardstick for every later decision, so it is checked by a reviewer before the human approves it.

1. Ask the human with AskUserQuestion, avoiding jargon and giving a recommended option first:
   - who it is for and what success looks like
   - what matters more when they conflict: speed or certainty
   - areas the AI must not touch
   When changing the goal, ask only what the change needs.
2. Draft `goal.md` in the shape of the gdd-init template:
   - North star in one sentence; acceptance scenarios.
   - For each scenario, `scenario_<n>_check`: a shell command run from the repository root that exits 0 when the scenario holds. Write `human` only when no command can tell.
   - `done_checks` (the tests and linters every sub-goal must pass), `max_files` / `max_lines` (how big a sub-goal may be before the human looks), `prefer`, `avoid`.
   - Definition of done.
3. List what is still unknown about reaching the goal as `- U<n> <question> | open` under "Uncertainties" in `state.md`.
4. Run the Agent tool with `subagent_type: "polaris:goal-reviewer"`, giving it only the draft `goal.md` and the uncertainties. Fix what it flags and run it again (at most twice). Do not argue with it in the draft; if you disagree, tell the human.
5. Write `goal.md` (the ask rule makes the human approve). Before they approve, show them the reviewer's table and any finding you did not fix.
6. Write one to three candidate sub-goals into `gdd/subgoals/candidates/` from `templates/subgoal.md`: small, each with `advances:` naming the scenario or uncertainty it moves. Rough is fine; `steps/plan.md` details them when they are chosen.
7. Record the human's answers from 1 as one file in `gdd/adr/`, then stop. The next run plans the first sub-goal.
