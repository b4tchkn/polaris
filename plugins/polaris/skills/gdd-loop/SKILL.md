---
name: gdd-loop
description: Run Goal Driven Development loops. Picks the next sub-goal by goal distance and uncertainty, has a worker build it in its own worktree, reviews it with an evaluator in a separate context, retrospects, and continues or stops for the human. Independent sub-goals run in parallel; each finished sub-goal becomes a pull request. Use when "gdd-loop", "advance the goal", "run the loop". Do not use when gdd/ does not exist (run gdd-init first).
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/scripts/gdd-status.sh *)
---

# gdd-loop

Human-on-the-loop: the AI decides what to do next and proceeds by default. The human is called in for direction (the goal, Decide sub-goals), when a mechanical stop condition fires (ask rules, hook), and when the gate below says ask. The human can stop or overturn anything at any time.

Talk to the human, write reviews, and ask questions in the language the human uses. Keep template headings and frontmatter keys as they are. Existing files may use translated headings; keep the language the file already uses.

If a directory is passed as an argument (e.g. `simulations/morning-review`), read every `gdd/` below as `<directory>/gdd/` and build inside that directory. Without an argument, target the repository root.

## Files

- `gdd/goal.md`: the goal. Frontmatter holds the mechanical checks (`scenario_<n>_check`, `done_checks`, `max_files`, `max_lines`) and the human's preferences (`prefer`, `avoid`). Every write needs the human's approval (ask rule).
- `gdd/subgoals/{candidates,in-progress,done}/<slug>.md`: one file per sub-goal, in the shape of `templates/subgoal.md`. The directory is its state. Move files with `git mv` (or `mv`). `advances:` is required (the hook refuses a file without it).
- `gdd/state.md`: Now / Built so far / Uncertainties / Rejected ideas / Learnings, rewritten every loop within one page. Never delete learnings.
- `gdd/reviews/<slug>.md`: one review per sub-goal, in the shape of `templates/review.md`.
- `gdd/adr/<YYYY-MM-DD>-<slug>.md`: one file per decision the human made, in the shape of `templates/adr.md`. Never change one once written (the hook restores it); a new decision gets a new file. Any session may add one.

`bash ${CLAUDE_SKILL_DIR}/scripts/gdd-status.sh <gdd-dir>` reports goal progress, done checks, stall, trust streak, and which candidates are ready and which overlap. `... <gdd-dir> gate <slug>` says whether the loop may continue after `<slug>` without the human. Add `--at <worktree path>` to run the scenario and done checks on a worker's branch instead of the main checkout. Run `git fetch -q` first when the repository has a remote. Use the script's answers; do not redo its checks by hand.

## Loop

0. **Goal.** If `goal.md` is still the template (`<goal name>` remains) or the human asked to change the goal, follow `steps/set-goal.md` and stop.
1. **Pending decision.** If the review of a sub-goal still in `in-progress/` has a filled Decision section (the human may write it in the file), apply it as in "Apply the answer" of `steps/decide.md`. If it is empty, ask its question again as in `steps/decide.md`.
2. **Plan.** Follow `steps/plan.md`: choose the next sub-goal(s), write their criteria, move them to `in-progress/`.
3. **Work.** Hand each in-progress sub-goal to a worker (`steps/plan.md` says how). The worker builds on branch `gdd/<slug>` in its own worktree and commits there; it never touches `gdd/`.
4. **Review and retrospect.** Follow `steps/review.md` for each finished sub-goal: evaluator, progress, retrospective, the next choice, the review file.
5. **Decide.** Follow `steps/decide.md`: the gate decides whether to continue without asking; otherwise ask the human one question. Apply the answer, open the pull request, then go back to 2, or stop.

Stop when the human says stop, when you need the human and they are not answering, or when the goal looks reached (`steps/decide.md`).

## Rules for every step

- Work only on in-progress sub-goals. Do not re-propose anything in "Rejected ideas". Follow "Learnings".
- Before deciding how to use outside data (APIs, logs, tickets) or a done condition that depends on it, try it on real data and confirm the data exists.
- A Build sub-goal is done only when it works through its real entry point (`/<name>` for a skill, launching and using it for an app). If you cannot launch it, ask the human to.
- Stop and ask the human (three options with trade-offs via AskUserQuestion, then ask why and record it in `gdd/adr/`) on:
  - hard-to-reverse decisions: data model, external service, billing, authentication, adding a dependency
  - changes that loosen acceptance scenarios, `done_checks`, or tests
  - anything in `avoid:` of `goal.md`
- When an instruction from the human can be read more than one way (a number, a scope, where to write it), offer three readings and let them choose before writing.
- Commit `gdd/` changes on the current branch at the end of each loop (`docs(gdd): <slug> <what happened>`). Never push the default branch without the human.
