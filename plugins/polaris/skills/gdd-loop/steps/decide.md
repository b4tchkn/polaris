# Decide

## Gate

Continue without asking only when all of these hold:

- `gdd-status.sh <gdd-dir> gate <slug> --at <worktree path>` prints `auto` (it checks: Build type, no qualitative criterion, `done_checks` pass, size within `max_files` / `max_lines`, no stall, and enough recent reviews kept without override or rework);
- every row of the evaluator table is "Met";
- the next-reviewer did not object.

Then write `Proceed (automatic). Next: <slug>` in the Decision section, set `auto: true`, finish the sub-goal (below), and go back to `steps/plan.md`.

When several sub-goals were reviewed together, finish every one the gate allows first, then ask about the rest in one AskUserQuestion call (one question per sub-goal).

## Ask

Otherwise ask one question with AskUserQuestion, phrased so someone who does not know the code understands it. Say what was built, how to try it, and what comes next:

"<sub-goal> is done (<one line on the result>). Next I will do <next slug>: <reason>. OK?"

- "OK, go on (Recommended)"
- "Change something" (the comment says what: redo part of this sub-goal, a different next sub-goal, add or drop candidates, change the goal)
- "Stop"

For a Decide sub-goal, replace "OK" with its three options (e.g. "Go with option A") and ask why they chose it.

Write the answer into the Decision section (e.g. `OK. Next: <slug> (chosen with AskUserQuestion)`). If the human did not answer, write "skipped" and stop.

## Apply the answer

- **OK**: finish the sub-goal (below) and go back to `steps/plan.md`.
- **Change something**: set `overridden: true` in the review, ask why unless the comment already says (two or three reasons drawn from the situation, plus Other), and record it in `gdd/adr/`. Then apply it: redo work (the sub-goal stays in progress; resume its worker with SendMessage or hand it out again), add or drop candidates, or change the goal (`steps/set-goal.md`). Go back to `steps/plan.md`.
- **Stop**: commit `gdd/` and stop.

## Finish a sub-goal

- Build: push `gdd/<slug>` and open a pull request (`gh pr create --head gdd/<slug>`; title = the sub-goal sentence, body = the review's "What was built" and evaluator table plus a link to the review file). Push and merge go through the human's ask rules. Write the pull request URL into the sub-goal file. Merging is the human's or CI's. If the repository has no remote, or the human declines the push, leave the branch as it is and say so.
- Decide: no pull request; the decision is in the review and `gdd/adr/`.
- `git mv` the sub-goal file to `gdd/subgoals/done/`, add a "Result" line to it, and commit `gdd/`. Sub-goals that depend on it become ready once its pull request is merged.

## Goal reached

When `progress:` shows every scenario `met` (scenarios marked `human` need the human's yes) and no candidate advances anything open, do not plan more. Ask: "The goal looks reached. Add sub-goals and continue / Write the goal completion report". For the report, write `gdd/reviews/GOAL.md` with each acceptance scenario and its result, what was left undone, and two or three candidates for the next goal, then stop.
