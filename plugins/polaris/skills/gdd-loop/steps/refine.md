# Refine

Turns what is left between here and the goal into sub-goals, like Spec Kit's clarify and tasks. The human approves each sub-goal's Done when and Check before any work starts.

1. Read `goal.md`, `gdd/uncertainties/`, `gdd/adr/`, the sub-goals in `gdd/subgoals/`, and the Learnings in `gdd/reviews/`, with the output of `gdd-check.sh <gdd-dir>` and `gdd-status.sh <gdd-dir>`. Add what the human asked for, if anything.
2. Clarify: ask the human about the open uncertainties whose answers would change the plan the most, at most five questions, with AskUserQuestion (a recommended option first, no jargon). For each answer, set the uncertainty's `status: resolved`, write the answer in its file, and record the decision in `gdd/adr/`. Leave the others open; a Decide sub-goal can resolve them.
3. Write the sub-goals that move the `not-met` scenarios and the open uncertainties, from `templates/subgoal.md`: small, each with `advances:` naming the scenario ids or uncertainty names it moves, `depends_on`, `touches` (paths it will change, as narrow as you can so independent ones can run in parallel), What to show, and Done when: 1 to 5 `[id]` conditions, edge cases included, each with a `Check:`. Make each check a command (a test or script that exits 0 when the condition holds) unless a command cannot decide it. If the gate or the scenarios' checks do not exist yet, one sub-goal creates them.
4. Set `status: cancelled` and add "## Why cancelled" to each `todo` sub-goal the answers made unnecessary.
5. Run `gdd-lint.sh <gdd-dir>` and fix what it reports.
6. Show the list of sub-goals with their Done when and Check, and have the human approve it once with AskUserQuestion (approve / change / stop). On approval, commit the `gdd/` files: `git commit -m "docs(gdd): refine <why, in one line>" -- gdd/`.
