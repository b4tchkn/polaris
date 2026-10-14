# Set or change the goal

The goal is the yardstick for every later decision, so a reviewer checks it before the human approves it.

1. Ask the human with AskUserQuestion, avoiding jargon and giving a recommended option first: who it is for and what success looks like. When changing the goal, ask only what the change needs.
2. Draft `goal.md` in the shape of the gdd-init template:
   - North star in one sentence.
   - Acceptance scenarios: outcomes of the whole goal from the user's side, 3 to 5 (at most 7). Keep a scenario only if the goal would be unmet when it alone fails. No edge cases; they go into sub-goals' Done when.
   - Each scenario gets an `[id]` and a `Check:`. Prefer a command that exits 0 when the scenario holds (an end-to-end test, a script). Use `observe:` only when a command cannot decide, and `human:` only for what is subjective.
   - Premises: what carries over from earlier work (decided specs, stack, existing results, learnings); None for a first goal.
   - Definition of done: `[gate]`, the one command that runs the project's formatter, linter, type check, build, and tests (e.g. `npm run check`). If the project has no such command, write what it would be; one of the first sub-goals creates it.
3. Write each thing still unknown about reaching the goal as `gdd/uncertainties/<name>.md` from `templates/uncertainty.md`.
4. Run the Agent tool with `subagent_type: "polaris:goal-owner"`, giving it only the draft `goal.md` and the uncertainties. Fix what it flags and run it again (at most twice). If you disagree with a finding, tell the human.
5. Write `goal.md` (the ask rule makes the human approve). Before they approve, show them the reviewer's table and any finding you did not fix.
6. Follow `steps/refine.md` to write the first sub-goals.
7. Record the human's answers from 1 as a file in `gdd/adr/`, and commit the `gdd/` files.
