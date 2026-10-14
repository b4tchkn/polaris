---
name: gdd-loop
description: Run the Goal Driven Development loop. Reads the goal's progress and the sub-goals' status, has the goal-owner decide what comes next, builds the sub-goals one at a time (each gated by its checks), writes a review for each, and keeps going until it must stop (a question for the human, a hold, nothing ready, or the goal reached). Use when "gdd-loop", "advance the goal", "run the loop". Do not use when gdd/ does not exist (run gdd-init first).
---

# gdd-loop

Human-on-the-loop: the AI proceeds by default; the human is called in only at the moments in "Stop and ask" below, and can stop or overturn at any time.

Talk to the human, write reviews, and ask questions in the language the human uses. Keep the headings of the templates as they are, and keep the language a file already uses.

If a directory is passed as an argument (e.g. `simulations/morning-review`), read every `gdd/` below as `<directory>/gdd/`, and put what you build inside that directory. Without an argument, target the repository root.

## State

One item per file. Shapes are in `templates/`.

- `gdd/goal.md`: north star, acceptance scenarios and the gate (each with an `[id]` and a `Check:`), premises. The human approves every write.
- `gdd/subgoals/<slug>.md`: one sub-goal. `status:` is `todo`, `doing`, `done`, or `cancelled`. A cancelled sub-goal is a rejected idea: never re-propose it.
- `gdd/uncertainties/<name>.md`: something still unknown about reaching the goal, as a question. `status:` is `open` or `resolved`; when resolved, write the answer and where it was decided.
- `gdd/reviews/<slug>.md`: the review of one sub-goal. Its Learnings are never deleted.
- `gdd/adr/<YYYY-MM-DD>-<slug>.md`: a decision the human made. Never changed once written.

Commit only `gdd/` files you wrote, and only the files of one event: `git commit -m "docs(gdd): <slug> <what happened>" -- gdd/`.

## The loop

1. Run `scripts/gdd-check.sh <gdd-dir>` (progress toward the goal) and `scripts/gdd-status.sh <gdd-dir>` (state, what is ready, overlaps, hold).
2. If a sub-goal has `status: doing` (an interrupted run), resume it first with "Build a sub-goal", from what is already there, instead of asking the goal-owner.
3. If `goal.md` is still the template (`<goal name>` remains), follow `steps/set-goal.md`, then go on.
4. If the status says `hold: yes`, ask the human with AskUserQuestion before starting anything new: continue as is / change direction (then follow `steps/refine.md`) / stop. Record the answer and reason in `gdd/adr/`.
5. Run the Agent tool with `subagent_type: "polaris:goal-owner"` to decide what comes next, giving it the paths of `goal.md`, `gdd/uncertainties/`, `gdd/adr/`, and `gdd/subgoals/`, and both outputs. Follow its answer; if you disagree, tell the human why instead of silently picking something else:
   - `refine:` → follow `steps/refine.md`, then go on with any `start:`.
   - `start:` → build each named sub-goal, one at a time (below).
   - `wait:` → tell the human what it waits for, and stop.
   - `reached:` → "Goal reached" below.
6. After each sub-goal, go back to 1.

## Build a sub-goal

1. Set the sub-goal's `status: doing` and commit it.
2. Read the Learnings of every review in `gdd/reviews/` and the cancelled sub-goals; follow them.
3. Write the tests or scripts that the "Done when" command checks need and that do not exist yet, and confirm they fail.
4. Build, within `touches:`. Before deciding how to use outside data (APIs, logs, tickets, and so on) or a condition that depends on it, try it on real data and confirm the data you assume exists. A Build sub-goal is done only when what you built works through its real entry point (`/<name>` for a skill, launching and using it for an app); if you cannot launch it, ask the human to. A Decide sub-goal prepares what to show (a spec, a mock, a comparison of three options with trade-offs), and is done when the human chooses.
5. Run `scripts/gdd-check.sh <gdd-dir> <slug>` until every command check and the gate are met. Never loosen a check to make it pass. If the same check fails three times in a row, stop and ask ("Stop and ask" below) instead of trying again.
6. Run the Agent tool with `subagent_type: "polaris:subgoal-verifier"`, giving it only the sub-goal file, where the work is, and the output of step 5. Do not pass your own view of the result. It reports whether each command check really tests its condition, and judges the `observe:` conditions.
7. Write `gdd/reviews/<slug>.md` in the shape of `templates/review.md` (`loop:` is the number of reviews in `gdd/reviews/`, excluding `GOAL.md`, plus one; `progress:` is the line `gdd-check.sh <gdd-dir>` prints). Put the check results and the verifier's rows in the Checks table unchanged; if you disagree with the verifier, say so under "Least confident". Retrospect: what to keep, the problems (rework, conditions that needed the verifier or the human although a check could have decided them), and every earlier Learning in `gdd/reviews/`.
   - Learning: something later sub-goals should follow → Learnings of this review. When this sub-goal turned an earlier learning into a check, hook, or rule, write that learning with "→ hardened: <where>"; do not edit the earlier review.
   - Anything else that needs work → a new `todo` sub-goal from `templates/subgoal.md` (`advances: process` for a change to how the loop runs).
   - Uncertainties this sub-goal answered → `status: resolved` with the answer; new ones → a new file.
8. If the sub-goal is a Decide sub-goal or has a `human:` condition, do step 9 first, then write the Decision and the ADR, and only then set `status: done`. Otherwise set `status: done` now. Commit the review, the uncertainties, and the sub-goal file together with what you built.
9. Report in one to three lines what was built, the review's path, and what is "Least confident". Then ask the human only in these cases, with AskUserQuestion (three options with trade-offs, recommended first, in words that need no knowledge of the code); otherwise do not ask and go back to the loop:
   - A Decide sub-goal: the three options. Then ask why they chose it, and record the decision and reason in `gdd/adr/`.
   - The sub-goal has a `human:` condition: ask for the judgment now; the answer goes in the review's Decision section.
   - The verifier flagged a command check as weak: strengthen the check or accept it.

## Stop and ask

These stop the work and need the human's choice (three options with AskUserQuestion, then ask why and record it in `gdd/adr/`):

- Hard-to-reverse decisions: data model, choice of external service, billing, authentication, adding a dependency.
- Changes that loosen acceptance scenarios, checks, or tests.
- Decisions whose outcome affects reaching the goal or a sub-goal.
- When the interpretation of the human's words can split (a number, a scope, where to write it): offer three options with trade-offs before writing.

Options are always three, and differ in what happens next or in trade-offs (speed / certainty / scope), each with a one-line trade-off. Do not offer three rewordings of one idea.

## Goal reached

Show the goal-owner's reason and ask with AskUserQuestion: add sub-goals and continue (follow `steps/refine.md`) / write the goal completion report. For the report, write `gdd/reviews/GOAL.md` with each acceptance scenario and its result, what was left undone, and two or three candidates for the next goal, then stop.
