# polaris

```text
                                ____        __            _          .
                               / __ \____  / /___ ______(_)____    --*--
                              / /_/ / __ \/ / __ `/ ___/ / ___/      '
                             / ____/ /_/ / / /_/ / /  / (__  )
                            /_/    \____/_/\__,_/_/  /_/____/
```

Goal Driven Development (GDD) for Claude Code.

You set a goal and the checks that show it is reached. The AI breaks it into sub-goals, builds the independent ones in parallel, and merges each into `main` once its checks and the gate pass. You steer at the few moments that need your judgment; you do not have to read the code or approve every step.

Human-on-the-loop, as polaris means it: the AI proceeds by default. You are called in when a Decide sub-goal or a `human:` check needs you, and when a mechanical stop condition fires (a decision that is hard to reverse), and you can stop or overturn it at any time. This matches the "Approver" level (L4) in [Levels of Autonomy for AI Agents](https://arxiv.org/abs/2506.12469) by Feng, McDonald, and Zhang (2025), where the user is involved only when the agent hits a blocker it cannot resolve on its own. A Build sub-goal whose checks (commands, plus the gate you define) all pass continues without you; a Decide sub-goal, or one with a `human:` check, stops for your decision.

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
3. `/polaris:gdd-loop` — the AI asks a few questions, writes your goal and its checks, and has you approve the first sub-goals. Then it keeps going until it must stop.

## What you get in your repository

```
gdd/
  goal.md          your goal, acceptance scenarios, premises
  subgoals/        one file per sub-goal (todo, doing, done, cancelled), each with its "Done when"
  uncertainties/   one file per open question about reaching the goal, and its answer once resolved
  reviews/         one review per sub-goal; its learnings are kept
  adr/             one file per decision you made, with the options and your reasons
```

The AI can propose changes to `goal.md`, but every write needs your approval.

## What the plugin adds to Claude Code

- Three skills: `/polaris:gdd-init`, `/polaris:gdd-loop` (the coordinator), and `/polaris:gdd-work <slug>` (builds one sub-goal on its own branch in a worktree; you can open it in another terminal), and three subagents: `worker`, which runs `gdd-work` in an isolated worktree, and `goal-owner`, which reviews the goal and decides what to start next, and `subgoal-verifier`, which gdd-work calls to check that the command checks really test their conditions and to judge `observe:` conditions.
- Approval rules for hard-to-reverse actions, written by `gdd-init` into `.claude/settings.json`: adding a dependency, changing migrations, `git push`, merging a PR, rewriting history, and editing the rules themselves. They prompt you whatever the AI thinks.
- One hook on Bash, Edit, and Write (PreToolUse and PostToolUse). It snapshots the `gdd/` state files before a tool runs and checks them after: a `gdd/goal.md` changed or created by a shell command is restored, a learning removed from a review in `gdd/reviews/` is restored, a changed or deleted file in `gdd/adr/` is restored, a sub-goal, uncertainty, or review file that breaks its format is reverted, and an edit that adds a skip or ignore to a test file is refused with an instruction to ask you first. It runs in every repository where the plugin is installed, needs `bash`, `grep`, `sed`, `awk`, `shasum`, and `find`, and checks results, not intent; it is not a sandbox.

## How a loop works

1. `gdd-check.sh` measures progress toward the goal, and `gdd-status.sh` reads which sub-goals are ready, which overlap, and whether progress has stalled.
2. The `goal-owner` (a separate context from the AI that builds) decides what comes next: start sub-goals, refine the plan, wait, or the goal is reached.
3. The coordinator marks the sub-goals it starts as `doing` on `main` and hands them out: workers run `gdd-work` in parallel for independent ones (no overlapping `touches:`). Each builds on its branch `gdd/<slug>` until its checks and the gate pass, then writes a review with what was built, its least confident decision, and what it learned.
4. The coordinator merges each finished branch into `main` and runs the gate again there, so changes that pass alone but break together are caught.
5. It continues without you when every check is a passing command (or a verified `observe:`). It stops for you at a Decide sub-goal, a `human:` check, a check the verifier found weak, a hard-to-reverse decision, a stall (the last three reviews show the same progress), or when the goal looks reached.
6. When you choose, the AI asks why and records your reason in `gdd/adr/`.

When the goal looks reached, the AI asks whether to add sub-goals or write a goal completion report (`gdd/reviews/GOAL.md`: acceptance scenarios and their results, a demo, a retrospective of the whole goal, what was left undone, candidates for the next goal). Archiving a finished goal and starting the next one is not automated yet.

The AI replies in the language you use.
