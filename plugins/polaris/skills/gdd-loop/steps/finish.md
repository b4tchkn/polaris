# Finish

Every sub-goal, Build or Decide, ends as a pull request. The AI decides it is done and opens it without asking; the human reviews it there, answers the comments, has it fixed in any session, and merges or closes it. The loop does not read the comments or fix anything after this.

## Open the pull request

1. On the sub-goal's branch, set the sub-goal file's `status:` to `done`, so merging the pull request is what marks it done. Commit the `gdd/` files written there (and for a Decide sub-goal what was shown: spec, mock, comparison), ending the message with the line `Sub-goal: <path of the sub-goal file from the repository root>` (e.g. `Sub-goal: gdd/subgoals/<slug>.md`).
2. Push the branch and open the pull request (`gh pr create --head <branch>`; title = the sub-goal sentence; body = the same `Sub-goal: <path>` line first, then the review's "What was built", the Checks table, and for a Decide sub-goal the chosen option). That first line is how the loop finds this pull request; keep it exact. Push goes through the human's ask rules. If the repository has no remote, or the human declines the push, leave the branch as it is, say so, and skip 3.
3. Post every item under "Least confident" as a line comment on the changed line it is about, in one review (`gh api repos/{owner}/{repo}/pulls/<number>/reviews --input <json>` with `event: COMMENT`, `commit_id` = the head commit, and `comments` of `{path, line, side: "RIGHT", body}`). Items that are not about a changed line, and conditions for the human, go into the review's body. Say plainly what you are unsure of and how the human can check it.

Sub-goals that depend on it become ready once it is merged and pulled.

## A pull request of gdd/ files alone

For `gdd/` files that belong to no sub-goal (the goal, an ADR, a refinement, the goal completion report): make a branch from the main branch, write the files on it, commit as in the rules, push, and open the pull request (`gh pr create --head <branch>`, title = what it records). If the repository has no remote, or the human declines the push, leave the branch and say so.

## Goal reached

When the goal-owner answers `reached:` (`steps/plan.md`), do not plan more. Show its reason and ask: "The goal looks reached. Add sub-goals and continue / Write the goal completion report". To continue, follow `steps/refine.md`. For the report, write `gdd/reviews/GOAL.md` in a pull request of its own, with each acceptance scenario and its result, what was left undone, and two or three candidates for the next goal, then stop.
