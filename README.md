# polaris

Goal Driven Development (GDD) for Claude Code.

You set a goal. The AI breaks it into sub-goals and advances one at a time. After each sub-goal it stops with a short report and a few options, and you steer by choosing. You decide the direction; you do not have to read the code or approve every step.

## Install

In Claude Code:

```
/plugin marketplace add b4tchkn/polaris
/plugin install polaris@polaris
```

## Start

In the repository where you want to get something done (new or existing):

1. `/polaris:gdd-init` — creates `gdd/` and the approval rules in `.claude/settings.json`.
2. Restart Claude Code and accept the trust prompt so the new rules take effect.
3. `/polaris:gdd-loop` — the AI asks a few questions and writes your goal and first sub-goal.
4. `/polaris:gdd-loop` again, each time you want to advance. Every run ends with a report and choices.

## What you get in your repository

```
gdd/
  goal.md        your goal, acceptance scenarios, premises
  subgoals.md    sub-goals, each with evaluation criteria
  state.md       the AI's one-page notes, rewritten every loop (learnings are kept)
  adr.md         decisions you made, with the options and your reasons
  reports/       one report per sub-goal
```

The AI can propose changes to `goal.md` and `subgoals.md`, but every write needs your approval.

## How a loop works

1. The AI applies your last decision and works on the next sub-goal only.
2. It stops to ask when a decision is hard to reverse (data model, external services, authentication, new dependencies) or would loosen the acceptance criteria.
3. It writes a report: what was built, how it did against the evaluation criteria, its least confident decision, a retrospective, improvement proposals, and three options for the next sub-goal, each with trade-offs.
4. You choose. The AI asks why, and records your reason in `adr.md`.

The AI replies in the language you use.
