# Set or change the goal

The goal is the yardstick for every later decision, so it is checked by a reviewer before the human approves it.

1. Ask the human with AskUserQuestion, avoiding jargon and giving a recommended option first:
   - who it is for and what success looks like
   - what matters more when they conflict: speed (`fast`) or certainty (`careful`)
   When changing the goal, ask only what the change needs.
2. Draft `goal.md` in the shape of the gdd-init template:
   - North star in one sentence.
   - Acceptance scenarios: outcomes of the whole goal from the user's side, 3 to 5 (at most 7). Keep a scenario only if the goal would be unmet when it alone fails. No edge cases; they go into sub-goals' Done when.
   - Each scenario gets an `[id]` and a `Check:`. Prefer a command that exits 0 when the scenario holds (an end-to-end test, a script). Use `observe:` only when a command cannot decide, and `human:` only for what is subjective.
   - Definition of done: `[gate]`, the one command that runs the project's formatter, linter, type check, build, and tests (e.g. `npm run check`). If the project has no such command, write what it would be and add a candidate to create it (formatter, then linter starting with warnings, then type check, then tests).
   - `mode` from the answers.
3. List what is still unknown about reaching the goal as `- U<n> <question> | open` under "Uncertainties" in `state.md`.
4. Run the Agent tool with `subagent_type: "polaris:goal-reviewer"`, giving it only the draft `goal.md` and the uncertainties. Fix what it flags and run it again (at most twice). If you disagree with a finding, tell the human.
5. Write `goal.md` (the ask rule makes the human approve). Before they approve, show them the reviewer's table and any finding you did not fix.
6. Write one to three candidate sub-goals into `gdd/subgoals/candidates/` from `templates/subgoal.md`: small, each with `advances:` naming the scenario ids or uncertainties it moves. Rough is fine; `steps/plan.md` details them when they are chosen. If the gate or the scenarios' checks do not exist yet, one candidate creates them.
7. Record the human's answers from 1 as one file in `gdd/adr/`, then stop. The next run plans the first sub-goal.
