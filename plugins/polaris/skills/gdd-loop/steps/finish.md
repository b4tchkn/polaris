# Finish

Every sub-goal, Build or Decide, ends as a pull request. The AI decides it is done and opens it without asking; the human reviews it there, answers the comments, has it fixed in any session, and merges or closes it. The loop does not read the comments or fix anything after this.

## Open the pull request

1. In the sub-goal's worktree (a Decide sub-goal has none: create one with `git worktree add .claude/worktrees/<slug>`), copy in the sub-goal file, its review, the ADRs written for it, and for a Decide sub-goal what was shown (spec, mock, comparison). Move the sub-goal file to the archive (`mkdir -p gdd/archive/subgoals && git mv gdd/subgoals/<slug>.md gdd/archive/subgoals/`), so merging the pull request is what takes it off the list. Commit them, ending the message with the line `Sub-goal: <archived path from the repository root>` (e.g. `Sub-goal: gdd/archive/subgoals/<slug>.md`).
2. Push the worktree's branch and open the pull request (`gh pr create --head <branch>`; title = the sub-goal sentence; body = the same `Sub-goal: <archived path>` line first, then the review's "What was built", the Checks table, and for a Decide sub-goal the chosen option). That first line is how the loop finds this pull request; keep it exact. Push goes through the human's ask rules. If the repository has no remote, or the human declines the push, leave the branch as it is, say so, and skip 3.
3. Post every item under "Least confident" as a line comment on the changed line it is about, in one review (`gh api repos/{owner}/{repo}/pulls/<number>/reviews --input <json>` with `event: COMMENT`, `commit_id` = the head commit, and `comments` of `{path, line, side: "RIGHT", body}`). Items that are not about a changed line, and conditions for the human, go into the review's body. Say plainly what you are unsure of and how the human can check it.
4. In the main checkout, commit `gdd/`. From here on do not change the sub-goal file or its review in the main checkout; the pull request carries them. Sub-goals that depend on it become ready once it is merged and pulled.

## Goal reached

When `progress:` shows every scenario `met` (scenarios marked `human` need the human's yes) and no candidate advances anything open, do not plan more. Ask: "The goal looks reached. Add sub-goals and continue / Write the goal completion report". For the report, write `gdd/reviews/GOAL.md` with each acceptance scenario and its result, what was left undone, and two or three candidates for the next goal, then stop.
