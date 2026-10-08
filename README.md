# polaris

```text
                                ____        __            _          .
                               / __ \____  / /___ ______(_)____    --*--
                              / /_/ / __ \/ / __ `/ ___/ / ___/      '
                             / ____/ /_/ / / /_/ / /  / (__  )
                            /_/    \____/_/\__,_/_/  /_/____/
```

Goal Driven Development (GDD) for Claude Code.

You set a goal. The AI breaks it into sub-goals and advances one at a time. After each sub-goal it stops with a short review and a few options, and you steer by choosing. You decide the direction; you do not have to read the code or approve every step.

Human-on-the-loop, as polaris means it: the AI proceeds by default. You are called in when a sub-goal is done and when a mechanical stop condition fires (a decision that is hard to reverse), and you can stop or overturn it at any time. This matches the "Approver" level (L4) in [Levels of Autonomy for AI Agents](https://arxiv.org/abs/2506.12469) by Feng, McDonald, and Zhang (2025), where the user is involved only when the agent hits a blocker it cannot resolve on its own. Today every sub-goal still stops for you; the automatic continuation is on the roadmap.

## Install

In Claude Code:

```
/plugin marketplace add b4tchkn/polaris
/plugin install polaris@polaris
```

## Start

In the repository where you want to get something done (new or existing):

1. `/polaris:gdd-init` — creates `gdd/` and the approval rules in `.claude/settings.json`.
2. Accept the trust prompt for the new rules (restart Claude Code if it does not appear).
3. `/polaris:gdd-loop` — the AI asks a few questions and writes your goal and first sub-goal.
4. `/polaris:gdd-loop` again, each time you want to advance. Every run ends with a review and choices.

## What you get in your repository

```
gdd/
  goal.md        your goal, acceptance scenarios, premises
  subgoals.md    sub-goals, each with evaluation criteria
  state.md       the AI's one-page notes, rewritten every loop (learnings are kept)
  adr.md         decisions you made, with the options and your reasons
  reviews/       one review per sub-goal
```

The AI can propose changes to `goal.md` and `subgoals.md`, but every write needs your approval.

## What the plugin adds to Claude Code

- Two skills: `/polaris:gdd-init` and `/polaris:gdd-loop`.
- Approval rules for hard-to-reverse actions, written by `gdd-init` into `.claude/settings.json`: adding a dependency, changing migrations, `git push`, merging a PR, rewriting history, and editing the rules themselves. They prompt you whatever the AI thinks.
- One hook on Bash, Edit, and Write (PreToolUse and PostToolUse). It snapshots the `gdd/` state files before a tool runs and checks them after: a `gdd/goal.md` or `gdd/subgoals.md` changed or created by a shell command is restored, a learning removed from `gdd/state.md` is restored, a rewritten `gdd/adr.md` is restored, and an edit that adds a skip or ignore to a test file is refused with an instruction to ask you first. It runs in every repository where the plugin is installed, needs `bash`, `grep`, `sed`, `awk`, `shasum`, and `find`, and checks results, not intent; it is not a sandbox.

## How a loop works

1. The AI applies your last decision and works on the next sub-goal only.
2. It stops to ask when a decision is hard to reverse (data model, external services, authentication, new dependencies) or would loosen the acceptance criteria.
3. It looks back: how it did against the evaluation criteria, what to keep, what went wrong, improvement proposals, and three options for the next sub-goal, each with trade-offs.
4. It writes a review with all of that plus what was built and its least confident decision.
5. You choose. The AI asks why, and records your reason in `adr.md`.

The AI replies in the language you use.
