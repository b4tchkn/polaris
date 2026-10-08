---
name: gdd-loop
description: Run one Goal Driven Development loop. Advances the "Next:" sub-goal in gdd/subgoals.md by one, rewrites gdd/state.md, writes a sub-goal review (with retrospective and next sub-goal options) to gdd/reviews/, asks the human to choose, and stops. Use when "gdd-loop", "advance the next sub-goal", "run the loop". Do not use when gdd/ does not exist (run gdd-init first).
---

# gdd-loop

Each run advances one sub-goal, reports, and stops. Do not commit.

Talk to the human, write reviews, and ask questions in the language the human uses. Keep the headings of the templates as they are. Existing files may use translated markers (e.g. `次：` for "Next:", `完了：` for "Done:"); treat them the same and keep the language the file already uses.

If a directory is passed as an argument (e.g. `simulations/morning-review`), read every `gdd/` below as `<directory>/gdd/`, and put what you build inside that directory. Without an argument, target the repository root.

## 1. Read the situation

- Read `gdd/goal.md`, `gdd/subgoals.md`, and `gdd/state.md`.
- If `gdd/reviews/` has reviews, read the latest one.

## 2. Check the previous decision

If there is no previous review and `goal.md` is still the template (`<goal name>` remains), do not advance a sub-goal. Do this and stop:

- Ask the human questions with AskUserQuestion to decide the goal (who uses it, what success looks like, and so on). Give options with a recommendation, and avoid jargon.
- From the answers, write `goal.md`, plus SG0 and "Later" in `subgoals.md` (the ask rule makes the human approve).

If there is no previous review, go to step 3. Otherwise, read the "Decision" section at the end.

| Decision | Action |
|---|---|
| Empty | Have the human choose as in step 7, write it into the Decision section, then go through this table again |
| Proceed | Copy the decision into the decision log in `state.md`. Apply the improvement proposals adopted in the Decision section (do not apply the others). Update `subgoals.md` from the chosen next sub-goal option (move the previous sub-goal to "Done:" and write its result), then go to step 3 |
| Change direction | Copy the decision and comment into the decision log in `state.md`. Write a revision of `subgoals.md` that reflects the comment, then stop |
| Stop | Copy the decision into the decision log in `state.md`, then stop |

Writes to `subgoals.md` / `goal.md` need human approval through the ask rule. Stop if they decline.

When applying the human's decisions or comments, if the interpretation can split (a number, a scope, where to write it), offer three options with trade-offs and let the human choose before writing.

## 3. Advance the sub-goal

- Work only on the "Next:" sub-goal in `subgoals.md`. Do not touch later ones.
- Do not re-propose anything in "Rejected ideas" in `state.md`. Follow "Learnings".
- When you offer options, offer three (what to show in a Decide sub-goal, decisions you stop to ask, and next sub-goal options in step 5). The three must differ in what happens next or in trade-offs (speed / certainty / scope, and so on). Write a one-line trade-off for each. Do not offer three rewordings of one idea.
- Before deciding how to use outside data (APIs, logs, tickets, and so on) or a done condition that depends on it, try it on real data and confirm the data you assume actually exists.
- A Build sub-goal is done only when what you built works through its real entry point (`/<name>` for a skill, launching and using it for an app). Walking through the steps yourself in the conversation does not count. If you cannot launch it, ask the human to.
- Stop and ask the human when you hit any of the following (have them choose from three options with AskUserQuestion, then ask the reason and record it in `gdd/adr.md` as in step 7):
  - Hard-to-reverse decisions: data model, choice of external service, billing, authentication, adding a dependency
  - Changes that loosen acceptance scenarios or tests
  - Decisions whose outcome affects reaching the goal or a sub-goal

## 4. Rewrite state.md

Rewrite the whole file within one page (do not append): Now / Built so far / Decision log / Rejected ideas / Learnings.

- Never delete learnings. Merging duplicates is fine.
- When a learning has been turned into a harness rule or a process step, keep it and add "→ hardened: <where>".

## 5. Retrospect

Gather the material for the review before writing it.

- For each evaluation criterion of the sub-goal (quantitative / qualitative), write the result and whether it was met.
- From this loop and all learnings in `state.md`, list what to keep and the problems (rework, where the human stepped in, why something was rejected).
- From those, derive numbered improvement proposals. For each, write where it goes and its trade-off (what gets better, what it costs). Leave out items with nowhere to go. There are four kinds:
  - Add learning: something the AI should follow in later loops → learnings in `state.md`
  - Fix the process: change how GDD runs in this repository → `CLAUDE.md` or `.claude/` in this repository
  - Harden a learning: turn a recurring or mechanically checkable learning into enforcement → `.claude/settings.json` / hook / `CLAUDE.md`
  - Revise sub-goals: add, remove, or reorder "Later" → `subgoals.md` / `goal.md`
- Only propose. Apply them only after the human adopts them in the Decision section (step 2).
- Draft three next sub-goal options (following step 3) that reflect the retrospective. Give each option evaluation criteria, marked quantitative (measured by numbers) or qualitative (judged by the human).
- If "Later" in `subgoals.md` is empty, the goal may be reached. Instead of the next sub-goal options, write for each acceptance scenario in `goal.md` the result and whether it was met.

## 6. Write the sub-goal review

- Write `gdd/reviews/SG<N>.md` in the shape of `templates/review.md` (`<N>` is this sub-goal's number), filling it from step 5.
- Leave the Decision section empty (filled in step 7).
- Show the same content in the chat, then go to step 7.

## 7. Have the human choose, then stop

Do not just ask the human to fill in the Decision section. Always offer choices with AskUserQuestion.

- Phrase questions so that someone who does not know the code or the jargon understands them. Say in the question what it is about.
  - Question 1 (single choice): "Is SG<N> good as it is?" Options: "OK, proceed", "Change it (change direction)", "Stop". For a Decide sub-goal, split "OK" into the three options (e.g. "Proceed with option A").
  - Question 2 (single choice): "Which sub-goal next?" Offer the three options with descriptions that show their trade-offs.
    - If "Later" is empty, first say that the goal looks reached, and make Question 2: "Add sub-goals and continue" / "Write the goal completion report". If they choose the report, write `gdd/reviews/GOAL.md` with the acceptance scenarios and their results (from step 5), what was left undone, and two or three candidates for the next goal, then stop.
  - Question 3 (multiple choice): "Which improvement proposals should be applied?" For each, describe in one line what changes and its trade-off. Skip this question if there are no proposals.
- Put the recommended option first and add "(Recommended)".
- Write the answers into the Decision section (e.g. `Proceed. Adopt 1, 2 (chosen with AskUserQuestion)`). If they chose "Change it" or Other, copy what they wrote as a comment.
- When the human chose among options (three options for what to show, three next sub-goal options, a decision you stopped to ask in step 3), follow up with AskUserQuestion asking why they chose it. Offer two or three reasons drawn from the options' trade-offs, and let them write freely through Other.
- Append one entry to `gdd/adr.md` in the entry format written at the top of that file (never rewrite earlier entries): date and sub-goal / what was decided / options offered (with trade-offs) / option chosen / reason (the human's answer, copied as is).
- Then stop. Applying the decision and starting the next sub-goal happen from step 2 on the next run.
