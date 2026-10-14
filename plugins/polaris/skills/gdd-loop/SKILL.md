---
name: gdd-loop
description: Run one Goal Driven Development loop. Advances the sub-goal whose file in gdd/subgoals/ has `status: doing` by one, writes a sub-goal review (with retrospective and next sub-goal options) to gdd/reviews/<slug>.md, asks the human to choose, and stops. Use when "gdd-loop", "advance the next sub-goal", "run the loop". Do not use when gdd/ does not exist (run gdd-init first).
---

# gdd-loop

Human-on-the-loop: the AI proceeds by default; the human is called in when a sub-goal needs their judgment and when a mechanical stop condition fires, and can stop or overturn at any time. Do not commit.

Talk to the human, write reviews, and ask questions in the language the human uses. Keep the headings of the templates as they are, and keep the language a file already uses.

If a directory is passed as an argument (e.g. `simulations/morning-review`), read every `gdd/` below as `<directory>/gdd/`, and put what you build inside that directory. Without an argument, target the repository root.

## State

One item per file, so nothing is rewritten wholesale. Shapes are in `templates/`.

- `gdd/goal.md`: north star, acceptance scenarios, premises.
- `gdd/subgoals/<slug>.md`: one sub-goal. `status:` is `todo`, `doing` (the one being advanced), `done`, or `cancelled`. A cancelled sub-goal is a rejected idea: never re-propose it.
- `gdd/uncertainties/<name>.md`: something still unknown about reaching the goal, as a question. `status:` is `open` or `resolved`; when resolved, write the answer and where it was decided.
- `gdd/reviews/<slug>.md`: the review of one sub-goal. Its Learnings are never deleted.
- `gdd/adr/<YYYY-MM-DD>-<slug>.md`: a decision the human made. Never changed once written.

## 1. Read the situation

- Read `gdd/goal.md` and every file in `gdd/subgoals/` and `gdd/uncertainties/`.
- Read the Learnings of every review in `gdd/reviews/`, and the latest review in full.

## 2. Check the previous decision

If there is no review and `goal.md` is still the template (`<goal name>` remains), do not advance a sub-goal. Do this and stop:

- Ask the human questions with AskUserQuestion to decide the goal (who uses it, what success looks like, and so on). Give options with a recommendation, and avoid jargon.
- From the answers, write `goal.md` (the ask rule makes the human approve), the first sub-goal with `status: doing`, and the later ones with `status: todo`, each as `gdd/subgoals/<slug>.md`. Write an uncertainty file for each important thing that is still unknown.

If there is no review, go to step 3. Otherwise, read the "Decision" section at the end of the latest review.

| Decision | Action |
|---|---|
| Empty | Have the human choose as in step 6, write it into the Decision section, then go through this table again |
| Proceed | Apply the improvement proposals adopted in the Decision section (do not apply the others). Set the previous sub-goal's `status:` to `done` and add a "Result" section. Write the chosen next sub-goal option as `gdd/subgoals/<slug>.md` with `status: doing` (or set an existing `todo` file to `doing` and fill it). Write the options that were not chosen and are rejected as `cancelled`, with a "Why cancelled" section. Then go to step 3 |
| Change direction | Revise the files in `gdd/subgoals/` to reflect the comment (cancel what no longer applies), then stop |
| Stop | Stop |

Writes to `goal.md` need human approval through the ask rule. Stop if they decline.

When applying the human's decisions or comments, if the interpretation can split (a number, a scope, where to write it), offer three options with trade-offs and let the human choose before writing.

## 3. Advance the sub-goal

- Work only on the sub-goal with `status: doing`. Do not touch the others.
- Do not re-propose anything `cancelled`. Follow the Learnings.
- When you offer options, offer three (what to show in a Decide sub-goal, decisions you stop to ask, and next sub-goal options in step 4). The three must differ in what happens next or in trade-offs (speed / certainty / scope, and so on). Write a one-line trade-off for each. Do not offer three rewordings of one idea.
- Before deciding how to use outside data (APIs, logs, tickets, and so on) or a done condition that depends on it, try it on real data and confirm the data you assume actually exists.
- A Build sub-goal is done only when what you built works through its real entry point (`/<name>` for a skill, launching and using it for an app). Walking through the steps yourself in the conversation does not count. If you cannot launch it, ask the human to.
- Stop and ask the human when you hit any of the following (have them choose from three options with AskUserQuestion, then ask the reason and record it in `gdd/adr/` as in step 6):
  - Hard-to-reverse decisions: data model, choice of external service, billing, authentication, adding a dependency
  - Changes that loosen acceptance scenarios or tests
  - Decisions whose outcome affects reaching the goal or a sub-goal
- When you find something unknown that matters for reaching the goal, add it to `gdd/uncertainties/`. When this loop resolves one, set it to `resolved` and write the answer.

## 4. Retrospect

Gather the material for the review before writing it.

- Run `gdd-check.sh <gdd-dir> <slug>` (in this skill's `scripts/`): it runs every command check of the sub-goal's "Done when" and the gate in `goal.md`. Its results are final for those conditions; put them in the review's Checks table with "gdd-check.sh" as the source.
- Run the Agent tool with `subagent_type: "polaris:subgoal-verifier"`, giving it only the sub-goal file, where the work is, and the output of the step above. Do not pass your own view of the result. It reports whether each command check really tests its condition, and judges the `observe:` conditions. Add its rows to the table unchanged; if you disagree, say so under "Least confident" instead of editing the table.
- `human:` conditions stay "for the human".
- Run `gdd-check.sh <gdd-dir>` and copy its `progress:` line into the review's `progress:`.
- A failing command check or gate means the sub-goal is not done: fix it, then check again. Do not loosen the check.
- From this loop and all Learnings in `gdd/reviews/`, list what to keep and the problems (rework, where the human stepped in, why something was rejected).
- From those, derive numbered improvement proposals. For each, write where it goes and its trade-off (what gets better, what it costs). Leave out items with nowhere to go. There are four kinds:
  - Add learning: something the AI should follow in later loops → the Learnings of this review
  - Fix the process: change how GDD runs in this repository → `CLAUDE.md` or `.claude/` in this repository
  - Harden a learning: turn a recurring or mechanically checkable learning into enforcement → `.claude/settings.json` / hook / `CLAUDE.md`
  - Revise sub-goals: add, remove, or reorder the `todo` ones → `gdd/subgoals/` / `goal.md`
- Only propose. Apply them only after the human adopts them in the Decision section (step 2).
- Draft three next sub-goal options (following step 3) that reflect the retrospective. Give each option "Done when" conditions, each with a `Check:` (`command`, `observe:`, or `human:`; prefer a command). Size: one goal per sub-goal, no larger than what could be thrown away if it misses; smaller after rejections, larger after approvals.
- If no sub-goal is `todo`, the goal may be reached. Instead of the next sub-goal options, write for each acceptance scenario in `goal.md` the result and whether it was met.

## 5. Write the sub-goal review

- Write `gdd/reviews/<slug>.md` in the shape of `templates/review.md` (`<slug>` is this sub-goal's file name; `loop:` is the number of reviews in `gdd/reviews/`, excluding `GOAL.md`, plus one; `progress:` is the line `gdd-check.sh` printed), filling it from step 4.
- Leave the Decision section empty (filled in step 6).
- Show the same content in the chat, then go to step 6.

## 6. Have the human choose, then stop

A Build sub-goal with no `human:` condition, whose command checks and gate are all met, whose `observe:` conditions the subgoal-verifier judged met, and with no command check the subgoal-verifier flagged as weak (when it flags one, ask the human whether to strengthen the check or accept it), is done without asking the human (they read the review afterwards and can stop or overturn it): write "Proceed (automatic)" in the Decision section and go to step 2 with the first `todo` sub-goal as the next one.

Otherwise, do not just ask the human to fill in the Decision section. Always offer choices with AskUserQuestion.

- Phrase questions so that someone who does not know the code or the jargon understands them. Say in the question what it is about.
  - Question 1 (single choice): "Is <slug> good as it is?" Options: "OK, proceed", "Change it (change direction)", "Stop". For a Decide sub-goal, split "OK" into the three options (e.g. "Proceed with option A").
  - Question 2 (single choice): "Which sub-goal next?" Offer the three options with descriptions that show their trade-offs.
    - If no sub-goal is `todo`, first say that the goal looks reached, and make Question 2: "Add sub-goals and continue" / "Write the goal completion report". If they choose the report, write `gdd/reviews/GOAL.md` with the acceptance scenarios and their results (from step 4), what was left undone, and two or three candidates for the next goal, then stop.
  - Question 3 (multiple choice): "Which improvement proposals should be applied?" For each, describe in one line what changes and its trade-off. Skip this question if there are no proposals.
- Put the recommended option first and add "(Recommended)".
- Write the answers into the Decision section (e.g. `Proceed. Adopt 1, 2 (chosen with AskUserQuestion)`). If they chose "Change it" or Other, copy what they wrote as a comment. If they did not answer a question, write "skipped" for it and do not ask it again on a later run.
- When the human chose among options (three options for what to show, three next sub-goal options, a decision you stopped to ask in step 3), follow up with AskUserQuestion asking why they chose it. Offer two or three reasons drawn from the options' trade-offs, and let them write freely through Other.
- Write a new file `gdd/adr/<YYYY-MM-DD>-<slug>.md` in the shape of `templates/adr.md` (add `-2`, `-3` if the name is taken; never rewrite an earlier one): what was decided / options offered (with trade-offs) / option chosen / reason (the human's answer, copied as is).
- Then stop. Applying the decision and starting the next sub-goal happen from step 2 on the next run.
