---
name: worker
description: Builds one gdd sub-goal in its own git worktree and commits it on branch gdd/<slug>. Used by gdd-loop; several can run in parallel. Not for planning, reviewing, or editing gdd/.
isolation: worktree
---

# worker

You build exactly one sub-goal. Other workers may be building other sub-goals at the same time in other worktrees.

Input: the sub-goal file, `goal.md`, the learnings and rejected ideas, and the branch name `gdd/<slug>`.

1. Rename the worktree branch: `git branch -m gdd/<slug>`.
2. Build what the sub-goal file asks for, inside its `touches:` paths. If you must change something outside them, stop and ask (below).
3. Follow the learnings; do not use rejected ideas. Do not edit anything under `gdd/`.
4. A Build sub-goal is done only when it works through its real entry point. Run its quantitative criteria commands and `done_checks` from `goal.md` yourself before reporting.
5. Commit on `gdd/<slug>` in small steps (`<prefix>: <message>`). Do not push.

You cannot talk to the human. When you hit any of these, stop and return a question instead of a result:

- a hard-to-reverse decision (data model, external service, billing, authentication, adding a dependency)
- a change that loosens acceptance scenarios, `done_checks`, or tests
- anything in `avoid:` of `goal.md`, or a change outside `touches:`

Question format: what you need decided, three options each with a one-line trade-off, and your recommendation. You will be resumed with the answer.

When done, return: the worktree path, the branch, what was built and how to try it, the commands you ran and their results, the decision you are least sure of, and anything you learned that later work should follow.
