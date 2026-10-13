---
name: gdd-loop
description: Run Goal Driven Development loops. Picks the next sub-goal by goal distance and uncertainty, has a worker build it in its own worktree, checks it with deterministic checks first (tests, linters, scripts) and the subgoal-verifier only where no check can decide, and opens a pull request for every finished sub-goal. Independent sub-goals run in parallel. Use when "gdd-loop", "advance the goal", "run the loop", "refine the sub-goals", "add a sub-goal". Do not use when gdd/ does not exist (run gdd-init first).
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/scripts/*)
---

# gdd-loop

The goal-owner subagent is responsible for the goal: what to work on next, when to wait, and whether the goal is reached. Do not decide these yourself; ask it and follow its answer. The AI proceeds by default. It finishes a sub-goal by opening a pull request; the human reviews, comments, fixes (in any session), and merges. The human is also called in for direction (the goal, Decide sub-goals), when a stop condition fires (ask rules, hook), and when `gdd-status.sh` says hold.

Check with guardrails first: whether something is done is decided by deterministic, repeatable checks (tests, linters, type checks, builds, scripts, hooks) wherever one can decide it. The subgoal-verifier (an AI judging) covers only what no check can decide, and the human only what is subjective.

Talk to the human, write reviews, and ask questions in the language the human uses. Keep template headings, `[id]` markers, `Check:` lines, and frontmatter keys as they are.

If a directory is passed as an argument (e.g. `simulations/morning-review`), read every `gdd/` below as `<directory>/gdd/` and build inside that directory. Without an argument, target the repository root.

## Files

The main checkout changes only when the human merges a pull request and pulls; never commit there. Write `gdd/` files on a branch made from the main branch and commit them there: a sub-goal's files on that sub-goal's branch, anything else (the goal, an ADR not about one sub-goal, a refinement) in a pull request of its own (`steps/finish.md`, "A pull request of gdd/ files alone").

- `gdd/goal.md`: frontmatter `mode`: `fast` or `careful` (which way to lean when in doubt). Acceptance scenarios and the definition of done are `[id]` items, each with a `Check:` line. The `[gate]` item is the one command every sub-goal passes. Every write needs the human's approval (ask rule).
- `gdd/subgoals/<slug>.md`: one file per sub-goal (`templates/subgoal.md`). `advances:` is required (the hook refuses a file without it). `status:` is `todo`, `done`, or `cancelled`; only the sub-goal's own pull request sets `done`, so the file says `done` once that pull request is merged and pulled. The commit that sets `done` and its pull request's body both carry the line `Sub-goal: <path of the file from the repository root>` (e.g. `Sub-goal: gdd/subgoals/<slug>.md`); that line is how the loop finds them.
- `gdd/uncertainties/<name>.md`: one file per thing still unknown about reaching the goal (`templates/uncertainty.md`), `status: open` or `resolved` with the answer. A sub-goal's `advances:` names it by its file name.
- `gdd/reviews/<slug>.md`: one review per sub-goal (`templates/review.md`). Its Learnings section is what later sub-goals follow; never delete a learning.
- A `cancelled` sub-goal is a rejected idea; its file says why under "Why cancelled".
- `gdd/adr/<YYYY-MM-DD>-<slug>.md`: one file per decision the human made (`templates/adr.md`). Never change one once written; a new decision gets a new file.

Two scripts decide what needs no judgment. Use their answers; do not redo their work by hand.

- `bash ${CLAUDE_SKILL_DIR}/scripts/gdd-check.sh <gdd-dir> [<slug>] [--at <worktree>]` runs checks: without a slug, the goal's checks (`progress:`); with one, the sub-goal's Done when and the gate. `--at` runs them in the worker's worktree.
- `bash ${CLAUDE_SKILL_DIR}/scripts/gdd-status.sh <gdd-dir>` says each sub-goal's state from its pull request (`todo`, `in-review`, `done`, `merged-not-pulled`, `closed`, `cancelled`), which can start and which overlap, and whether to hold. Run `git fetch -q` first when the repository has a remote. If it says gh failed, tell the human to install the GitHub CLI and run `gh auth login`, and stop.
- `bash ${CLAUDE_SKILL_DIR}/scripts/gdd-lint.sh <gdd-dir>` checks the format of the sub-goal and review files (the hook also runs it on every write). Fix what it reports before committing `gdd/`.

## Loop

0. **Goal.** If `goal.md` is still the template (`<goal name>` remains) or the human asked to change the goal, follow `steps/set-goal.md` and stop. If the human asked to refine or to add a sub-goal, follow `steps/refine.md` and stop.
1. **Pull requests.** Run `gdd-status.sh`. For each sub-goal: `merged-not-pulled` → ask the human to pull (sub-goals that depend on it wait); `in-review` with a branch but no pull request (finished, not pushed) → open the pull request (`steps/finish.md` 2–3) when the repository has a remote, otherwise it waits for the human to merge the branch. A `closed` sub-goal is cancelled by the next refinement (`steps/refine.md`). Do not read or answer pull request comments; the human handles those.
2. **Hold.** If `gdd-status.sh` says `hold: yes`, tell the human why and ask once: continue / change something / stop. Record the answer in `gdd/adr/` in a pull request of its own. Stop unless they say continue.
3. **Plan.** Follow `steps/plan.md`: the goal-owner decides the next sub-goal(s) or a refinement; hand the sub-goals to workers.
4. **Review.** Follow `steps/review.md` for each finished sub-goal: run its checks, the subgoal-verifier for the rest, retrospect.
5. **Finish.** Follow `steps/finish.md`: open the pull request with line comments where the AI is unsure. Then go back to 1. The loop stops only on the goal-owner's `wait:`, a hold, or a question for the human. On `reached:`, follow "Goal reached" in `steps/finish.md`.

## Rules for every step

- Work only on the sub-goals the goal-owner chose. A sub-goal the human asks for goes in through `steps/refine.md` like any other; the goal-owner decides when it starts. Do not re-propose a cancelled sub-goal. Follow the learnings in `gdd/reviews/`.
- Before deciding how to use outside data (APIs, logs, tickets) or a done condition that depends on it, try it on real data and confirm the data exists.
- A Build sub-goal is done only when it works through its real entry point (`/<name>` for a skill, launching and using it for an app).
- Stop and ask the human (three options with trade-offs via AskUserQuestion, then ask why and record it in `gdd/adr/`, on the sub-goal's branch when it is about one sub-goal, otherwise in a pull request of its own) on:
  - hard-to-reverse decisions: data model, external service, billing, authentication, adding a dependency
  - changes that loosen acceptance scenarios, the gate, or tests
- When an instruction from the human can be read more than one way (a number, a scope, where to write it), offer three readings and let them choose before writing.
- Commit `gdd/` changes only on the branch they were written on, and only them: `git add gdd/ && git commit -m "docs(gdd): <slug> <what happened>" -- gdd/` (the trailing `-- gdd/` leaves anything else out of the commit). Push only with the human's approval.
