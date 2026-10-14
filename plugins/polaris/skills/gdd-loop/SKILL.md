---
name: gdd-loop
description: Run the Goal Driven Development loop as the coordinator. Reads the goal's progress and the sub-goals' status, has the goal-owner decide what comes next, hands sub-goals out to workers (in parallel when they are independent), merges what is ready into main behind the gate, and keeps going until it must stop (a question for the human, a hold, nothing ready, or the goal reached). Use when "gdd-loop", "advance the goal", "run the loop". Do not use when gdd/ does not exist (run gdd-init first).
---

# gdd-loop

Human-on-the-loop: the AI proceeds by default; the human is called in only at the moments in "Stop and ask" below, and can stop or overturn at any time.

Talk to the human, write reviews, and ask questions in the language the human uses. Keep the headings of the templates as they are, and keep the language a file already uses.

## State

One item per file. Shapes are in `templates/`.

- `gdd/goal.md`: north star, acceptance scenarios and the gate (each with an `[id]` and a `Check:`), premises. The human approves every write.
- `gdd/subgoals/<slug>.md`: one sub-goal. `status:` is `todo`, `doing`, `done`, or `cancelled`. A cancelled sub-goal is a rejected idea: never re-propose it.
- `gdd/uncertainties/<name>.md`: something still unknown about reaching the goal, as a question. `status:` is `open` or `resolved`; when resolved, write the answer and where it was decided.
- `gdd/reviews/<slug>.md`: the review of one sub-goal. Its Learnings are never deleted.
- `gdd/adr/<YYYY-MM-DD>-<slug>.md`: a decision the human made. Never changed once written.

Commit only `gdd/` files you wrote, and only the files of one event: `git commit -m "docs(gdd): <slug> <what happened>" -- gdd/`.

## The loop

1. Run `scripts/gdd-check.sh gdd` (progress toward the goal) and `scripts/gdd-status.sh gdd` (state, what is ready, overlaps, hold).
2. If `goal.md` is still the template (`<goal name>` remains), follow `steps/set-goal.md`, then go on.
3. If a sub-goal is `ready-to-merge`, merge it ("Merge into main" below), then go back to 1.
4. If the status says `hold: yes`, ask the human with AskUserQuestion before starting anything new: continue as is / change direction (then follow `steps/refine.md`) / stop. Record the answer and reason in `gdd/adr/`.
5. Run the Agent tool with `subagent_type: "polaris:goal-owner"` to decide what comes next, giving it the paths of `goal.md`, `gdd/uncertainties/`, `gdd/adr/`, `gdd/subgoals/`, and `gdd/reviews/`, and both outputs. Follow its answer; if you disagree, tell the human why instead of silently picking something else:
   - `refine:` → follow `steps/refine.md`, then go on with any `start:`.
   - `start:` → "Hand out sub-goals" below.
   - `wait:` → tell the human what it waits for, and stop.
   - `reached:` → "Goal reached" below.
6. When a worker returns, go back to 1.

## Hand out sub-goals

Do this in the main checkout.

1. For each sub-goal to start, set `status: doing` and commit it on main: `git commit -m "docs(gdd): <slug> start" -- gdd/`. Do this before handing out, so a branch's change to `done` is a direct descendant of main and cannot conflict.
2. A Decide sub-goal needs no worker: prepare what to show (a spec, a mock, a comparison of three options with trade-offs) yourself, ask the human to choose with AskUserQuestion, ask why, record it in `gdd/adr/` and the review's Decision section, write `gdd/reviews/<slug>.md`, set `status: done`, and commit.
3. For each Build sub-goal, run the Agent tool with `subagent_type: "polaris:worker"`, giving it the slug. With one sub-goal run it in the foreground; with several, run them in the background at once.
4. When a worker returns a question instead of a result, ask the human with AskUserQuestion (three options with trade-offs), record the answer and reason in `gdd/adr/`, and resume the same worker with SendMessage so it continues where it stopped.

## Merge into main

Do this in the main checkout, for each `ready-to-merge` sub-goal.

1. If the sub-goal has a `human:` condition, ask the human for the judgment first (the answer goes in the review's Decision section). If they decline it, leave it unmerged and stop.
2. `git merge --no-ff gdd/<slug>`. On a conflict, stop and show the human what git reported.
3. Run `scripts/gdd-check.sh gdd` on main and read `gate=`. Several branches together can break what each passed alone. If the gate is not `met`, stop and tell the human which check failed and that the merge commit is on main.
4. Report in one to three lines what went into main and the review's path, and ask the human only when the review shows a flagged weak check ("strengthen or accept"). `git push` is an ask rule: the human approves it.

## Stop and ask

These stop the work and need the human's choice (three options with AskUserQuestion, then ask why and record it in `gdd/adr/`):

- Hard-to-reverse decisions: data model, choice of external service, billing, authentication, adding a dependency.
- Changes that loosen acceptance scenarios, checks, or tests.

Options are always three, and differ in what happens next or in trade-offs (speed / certainty / scope), each with a one-line trade-off. Do not offer three rewordings of one idea.

## Goal reached

Show the goal-owner's reason and ask with AskUserQuestion: add sub-goals and continue (follow `steps/refine.md`) / write the goal completion report. For the report, write `gdd/reviews/GOAL.md` with each acceptance scenario and its result, a demo, a retrospective of the whole goal, what was left undone, and two or three candidates for the next goal, then stop.
