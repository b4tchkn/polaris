---
name: gdd-loop
description: Run Goal Driven Development loops. Picks the next sub-goal by goal distance and uncertainty, has a worker build it in its own worktree, checks it with deterministic checks first (tests, linters, scripts) and an evaluator only where no check can decide, and opens a pull request for every finished sub-goal. Independent sub-goals run in parallel. Use when "gdd-loop", "advance the goal", "run the loop". Do not use when gdd/ does not exist (run gdd-init first).
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/scripts/gdd-status.sh *)
---

# gdd-loop

The AI decides what to do next and proceeds by default. It finishes a sub-goal by opening a pull request; the human reviews, comments, fixes (in any session), and merges. The human is also called in for direction (the goal, Decide sub-goals), when a stop condition fires (ask rules, hook), and when `gdd-status.sh` says hold.

Check with guardrails first: whether something is done is decided by deterministic, repeatable checks (tests, linters, type checks, builds, scripts, hooks) wherever one can decide it. The evaluator (an AI judging) covers only what no check can decide, and the human only what is subjective.

Talk to the human, write reviews, and ask questions in the language the human uses. Keep template headings, `[id]` markers, `Check:` lines, and frontmatter keys as they are.

If a directory is passed as an argument (e.g. `simulations/morning-review`), read every `gdd/` below as `<directory>/gdd/` and build inside that directory. Without an argument, target the repository root.

## Files

- `gdd/goal.md`: frontmatter `mode`: `fast` or `careful` (which way to lean when in doubt). Acceptance scenarios and the definition of done are `[id]` items, each with a `Check:` line. The `[gate]` item is the one command every sub-goal passes. Every write needs the human's approval (ask rule).
- `gdd/subgoals/{candidates,in-progress,in-review,done}/<slug>.md`: one file per sub-goal (`templates/subgoal.md`). `in-review` = pull request open, `done` = merged. Move files with `git mv`. `advances:` is required (the hook refuses a file without it).
- `gdd/state.md`: Now / Built so far / Uncertainties (`- U<n> <question> | open`) / Rejected ideas / Learnings, rewritten every loop within one page. Never delete learnings.
- `gdd/reviews/<slug>.md`: one review per sub-goal (`templates/review.md`).
- `gdd/adr/<YYYY-MM-DD>-<slug>.md`: one file per decision the human made (`templates/adr.md`). Never change one once written; a new decision gets a new file.

`bash ${CLAUDE_SKILL_DIR}/scripts/gdd-status.sh <gdd-dir>` is the loop's manager: it runs the goal's checks (progress), lists pull requests in review with their state, says which candidates can start and which overlap, and whether to hold. `... <gdd-dir> check <slug> --at <worktree>` runs a sub-goal's checks and the gate on the worker's branch. Run `git fetch -q` first when the repository has a remote. Use its answers; do not redo its work by hand.

## Loop

0. **Goal.** If `goal.md` is still the template (`<goal name>` remains) or the human asked to change the goal, follow `steps/set-goal.md` and stop.
1. **Pull requests.** Run `gdd-status.sh`. For each sub-goal in `in-review/`: `MERGED` → `git mv` it to `done/`; `CLOSED` → delete it, add it to "Rejected ideas", set `overridden: true` in its review. Do not read or answer pull request comments; the human handles those.
2. **Hold.** If `gdd-status.sh` says `hold: yes`, tell the human why and ask once: continue / change something / stop. Record the answer in `gdd/adr/`. Stop unless they say continue.
3. **Plan.** Follow `steps/plan.md`: choose the next sub-goal(s), write their Done when with checks, hand them to workers.
4. **Review.** Follow `steps/review.md` for each finished sub-goal: run its checks, the evaluator for the rest, retrospect, choose what comes next.
5. **Finish.** Follow `steps/finish.md`: open the pull request with line comments where the AI is unsure. Then go back to 1, or stop when nothing is ready or the goal looks reached.

## Rules for every step

- Work only on in-progress sub-goals. Do not re-propose anything in "Rejected ideas". Follow "Learnings".
- Before deciding how to use outside data (APIs, logs, tickets) or a done condition that depends on it, try it on real data and confirm the data exists.
- A Build sub-goal is done only when it works through its real entry point (`/<name>` for a skill, launching and using it for an app).
- Stop and ask the human (three options with trade-offs via AskUserQuestion, then ask why and record it in `gdd/adr/`) on:
  - hard-to-reverse decisions: data model, external service, billing, authentication, adding a dependency
  - changes that loosen acceptance scenarios, the gate, or tests
- When an instruction from the human can be read more than one way (a number, a scope, where to write it), offer three readings and let them choose before writing.
- Commit `gdd/` changes on the current branch at the end of each loop (`docs(gdd): <slug> <what happened>`). Push only with the human's approval.
