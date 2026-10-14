---
name: gdd-work
description: Achieve one Goal Driven Development sub-goal on its own branch gdd/<slug> in a git worktree, with its checks as the gate, and leave it ready to merge. Run by the worker subagent, or by the human in another terminal session as `/polaris:gdd-work <slug>`. Use only for a sub-goal that gdd-loop set to `status: doing`. Does not push or merge.
---

# gdd-work

Talk to the human in the language they use. Several of these may run at once in other worktrees, so touch only your own sub-goal.

Input: `<slug>`, and if given a directory (e.g. `simulations/morning-review`), read every `gdd/` below as `<directory>/gdd/`.

1. Check where you are. In the main checkout (the first entry of `git worktree list`) stop and tell the human to start Claude Code with `claude --worktree`, so the work does not disturb the coordinator. In a worktree, get on the branch `gdd/<slug>`: switch to it if it exists, or `git switch -c gdd/<slug>` from the current commit. Then `git merge main` to catch up.
2. Read `gdd/subgoals/<slug>.md` (its `status:` must be `doing`), `goal.md`, the Learnings of every review in `gdd/reviews/`, and the cancelled sub-goals; follow them and do not repeat what a cancelled sub-goal tried.
3. Write the tests or scripts that the "Done when" command checks need and that do not exist yet, and confirm they fail. These checks are how the sub-goal is judged; do not weaken them later.
4. Build, within `touches:`. Write under `gdd/` only your own sub-goal, its review, and new uncertainties and ADRs. Stop and ask (three options with a one-line trade-off each, recommended first) before: a hard-to-reverse decision (data model, external service, billing, authentication, adding a dependency), a change that loosens acceptance scenarios, checks, or tests (the hook also refuses these), or a change outside `touches:`. Ask with AskUserQuestion when you can talk to the human; otherwise return the question as your result and stop, and you will be resumed with the answer.
5. Run `gdd-loop`'s `scripts/gdd-check.sh <gdd-dir> <slug>` until every command check and the gate are met. Never loosen a check. If the same check fails three times in a row, stop and ask. Run the Agent tool with `subagent_type: "polaris:subgoal-verifier"`, giving it only the sub-goal file, the worktree path and branch, and the output of `gdd-check.sh`; it reports whether each command check really tests its condition and judges the `observe:` conditions.
6. A Build sub-goal is done only when what you built works through its real entry point (`/<name>` for a skill, launching and using it for an app); if you cannot launch it, say so in the report.
7. Write `gdd/reviews/<slug>.md` in the shape of `gdd-loop`'s `templates/review.md` (`loop:` is one more than the highest `loop:` in `gdd/reviews/`; `progress:` is the line `gdd-check.sh <gdd-dir>` prints). Put the check results and the verifier's rows in the Checks table unchanged. Retrospect: what to keep, and the problems (rework, conditions that needed the verifier or the human although a check could have decided them).
   - Learning: something later sub-goals should follow → the Learnings of this review. When this sub-goal turned an earlier learning into a check, hook, or rule, write that learning with "→ hardened: <where>"; do not edit the earlier review.
   - Anything else that needs work → a new `todo` sub-goal file from `gdd-loop`'s `templates/subgoal.md` (`advances: process` for a change to how the loop runs).
   - Uncertainties you answered → `status: resolved` with the answer; new ones → a new file from `templates/uncertainty.md`.
8. Set the sub-goal file's `status: done` and commit everything on the branch (`<prefix>: <message>`). Do not push.
9. Report: the branch, what was built and how to try it, the check results, each place you are unsure of as `file:line: what is uncertain and how to check it`, and whether a `human:` or Decide condition is waiting for the human.
