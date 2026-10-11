# polaris

```text
                                ____        __            _          .
                               / __ \____  / /___ ______(_)____    --*--
                              / /_/ / __ \/ / __ `/ ___/ / ___/      '
                             / ____/ /_/ / / /_/ / /  / (__  )
                            /_/    \____/_/\__,_/_/  /_/____/
```

Goal Driven Development (GDD) for Claude Code.

You set a goal. The AI decides what to do next by which acceptance scenarios are still unmet and what is still unknown, builds sub-goals in their own worktrees (in parallel when they are independent), checks them with deterministic checks first, and opens a pull request for every finished sub-goal. You review, fix, and merge in the pull requests. You decide the direction; you do not have to approve every step.

Human-on-the-loop, as polaris means it: the AI proceeds by default. You are called in to set the goal, for Decide sub-goals and decisions that are hard to reverse, when the loop stalls, and in every pull request; you can stop or overturn it at any time. This matches the "Approver" level (L4) in [Levels of Autonomy for AI Agents](https://arxiv.org/abs/2506.12469) by Feng, McDonald, and Zhang (2025).

Guardrails first: whether something is done is decided by deterministic, repeatable checks (tests, linters, type checks, builds, scripts, hooks) wherever one can decide it. An AI judges only what no check can decide, and you only what is subjective.

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
3. `/polaris:gdd-loop` — the AI asks a few questions, drafts your goal, has it reviewed, and writes it with your approval.
4. `/polaris:gdd-loop` again to advance. It keeps going, opening a pull request per sub-goal, until it needs you or nothing is ready.

## What you get in your repository

```
gdd/
  goal.md        your goal: acceptance scenarios and the definition of done, each with a Check line;
                 frontmatter holds mode (fast or careful when in doubt)
  subgoals/      one file per sub-goal under candidates/, in-progress/, in-review/ (pull request open), done/ (merged)
  state.md       the AI's one-page notes: now, built so far, uncertainties, rejected ideas, learnings
  adr/           one file per decision you made, with the options and your reasons
  reviews/       one review per sub-goal
```

Every write to `goal.md` needs your approval.

## Goals and checks

```markdown
---
mode: careful
---
# Goal: get tasks done without forgetting them

## Acceptance scenarios
1. [capture] A task can be added right after opening the app
   - Check: `npm run e2e -- capture`
2. [easy] Adding needs no explanation
   - Check: observe: open the app and add a task
3. [no-forget] The family forgets fewer tasks
   - Check: human: only the family can tell

## Definition of done
1. [gate] Formatter, linter, type check, build, and tests pass
   - Check: `npm run check`
```

- Acceptance scenarios are outcomes of the whole goal from the user's side, 3 to 5. Keep one only if the goal would be unmet when it alone fails; edge cases go into a sub-goal's "Done when", which uses the same `[id]` and `Check:` form.
- A `Check:` in backticks is a command that exits 0 when the item holds; it is the default. `observe:` is judged by the subgoal-verifier, `human:` by you.
- `[gate]` is the one command every sub-goal passes. It runs before each pull request and should run in your CI too.

## What the plugin adds to Claude Code

- Two skills, `/polaris:gdd-init` and `/polaris:gdd-loop`, and three subagents that gdd-loop calls, each in a separate context: `goal-owner` is responsible for the goal: it checks a draft goal (outcomes, size, checks that could be deterministic) and decides which sub-goals to start next from the check and status results; `worker` writes a sub-goal's checks and then builds it in its own worktree, `subgoal-verifier` says whether each command check really tests its condition and judges the `observe:` items.
- `gdd-check.sh` runs the checks: the goal's (progress toward the goal) or one sub-goal's plus the gate.
- `gdd-status.sh` says where the sub-goals stand: lists pull requests and whether they were merged, says which candidates can start and which can run in parallel, and holds when progress stalls or a pull request was closed.
- Approval rules for hard-to-reverse actions, written by `gdd-init` into `.claude/settings.json`: adding a dependency, changing migrations, `git push`, merging a PR, rewriting history, and editing the rules themselves. They prompt you whatever the AI thinks, also when a worker running in the background triggers them.
- One hook on Bash, Edit, and Write. It restores a `gdd/goal.md` written by a shell command, a sub-goal file without an `advances:` line, a learning removed from `gdd/state.md`, and a changed or deleted ADR in `gdd/adr/`. It restores test files when an edit adds a skip or removes tests, or a shell command deletes them, and tells the AI to ask you first. Each subagent and each worktree is checked on its own. It needs `bash`, `grep`, `sed`, `awk`, `shasum`, and `find`, and checks results, not intent; it is not a sandbox.

## How a loop works

1. **Pull requests.** The AI checks the pull requests it opened: merged ones move to `done/` and unblock the sub-goals that depend on them; closed ones become rejected ideas. It does not read or answer comments; that is yours.
2. **Plan.** The goal-owner picks the candidate that moves the most unmet scenarios or resolves the biggest open uncertainty, writes its "Done when" with checks, and moves it to `in-progress/`. Independent candidates that touch different paths are picked together.
3. **Work.** A worker writes the checks, builds the sub-goal on branch `gdd/<slug>` in its own worktree, runs the checks and the gate, and commits. When it hits a decision that is hard to reverse (data model, external services, authentication, new dependencies) or would loosen a check, it stops; the AI asks you three options and passes your answer back.
4. **Review.** `gdd-check.sh` runs the checks on the worker's branch; the subgoal-verifier covers what no command can; the AI looks back (learnings go into `state.md`, work becomes new candidates).
5. **Finish.** The AI opens the pull request without asking, with its code, checks, sub-goal file, review, and decisions, and posts what it is unsure of as line comments. You review, have it fixed in any session, and merge or close it.

A Decide sub-goal asks you to choose among three options before its pull request. When the goal's progress has not moved for three reviews, or a pull request was closed, the loop holds and asks you before starting anything new.

When every scenario is met and nothing is left, the AI tells you the goal looks reached and asks whether to add sub-goals or write a goal completion report (`gdd/reviews/GOAL.md`: acceptance scenarios and their results, what was left undone, candidates for the next goal). Archiving a finished goal and starting the next one is not automated yet.

The AI replies in the language you use.

## Testing the skills

`tests/check.sh` runs this repository's own gate: the hook tests, the `gdd-check.sh` and `gdd-status.sh` tests, and `claude plugin validate`.

```
bash tests/check.sh
```
