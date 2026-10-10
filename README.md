# polaris

```text
                                ____        __            _          .
                               / __ \____  / /___ ______(_)____    --*--
                              / /_/ / __ \/ / __ `/ ___/ / ___/      '
                             / ____/ /_/ / / /_/ / /  / (__  )
                            /_/    \____/_/\__,_/_/  /_/____/
```

Goal Driven Development (GDD) for Claude Code.

You set a goal. The AI decides what to do next by how far each acceptance scenario still is and what is still unknown, builds sub-goals in their own worktrees (in parallel when they are independent), and opens a pull request for each. After a sub-goal it either continues on its own or asks you one question. You decide the direction; you do not have to read the code or approve every step.

Human-on-the-loop, as polaris means it: the AI proceeds by default. You are called in when a sub-goal is done and when a mechanical stop condition fires (a decision that is hard to reverse), and you can stop or overturn it at any time. This matches the "Approver" level (L4) in [Levels of Autonomy for AI Agents](https://arxiv.org/abs/2506.12469) by Feng, McDonald, and Zhang (2025), where the user is involved only when the agent hits a blocker it cannot resolve on its own. The AI continues without you only when a script and two reviewers agree it is safe (see "When the AI continues on its own"); everything else stops for your decision.

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
4. `/polaris:gdd-loop` again to advance. It keeps going until it needs you, then asks one question.

## What you get in your repository

```
gdd/
  goal.md        your goal, acceptance scenarios, definition of done; frontmatter holds a check per scenario
  subgoals/      one file per sub-goal under candidates/, in-progress/, done/
  state.md       the AI's one-page notes: now, built so far, uncertainties, rejected ideas, learnings
  adr.md         decisions you made, with the options and your reasons
  reviews/       one review per sub-goal
```

Every write to `goal.md` needs your approval.

## What the plugin adds to Claude Code

- Two skills: `/polaris:gdd-init` and `/polaris:gdd-loop`, and four subagents that gdd-loop calls, each in a separate context: `goal-reviewer` checks a draft goal, `worker` builds one sub-goal in its own worktree, `evaluator` scores it, and `next-reviewer` checks the AI's choice of what comes next.
- `gdd-status.sh` (inside gdd-loop): reads the frontmatter and runs the scenario checks to report goal progress, which candidates are ready, whether the loop has stalled, and whether it may continue without you.
- Approval rules for hard-to-reverse actions, written by `gdd-init` into `.claude/settings.json`: adding a dependency, changing migrations, `git push`, merging a PR, rewriting history, and editing the rules themselves. They prompt you whatever the AI thinks, also when a worker running in the background triggers them.
- One hook on Bash, Edit, and Write (PreToolUse and PostToolUse). It snapshots the `gdd/` state files before a tool runs and checks them after: a `gdd/goal.md` changed or created by a shell command is restored, a sub-goal file without an `advances:` line is reverted, a learning removed from `gdd/state.md` is restored, a rewritten `gdd/adr.md` is restored, and an edit that adds a skip or ignore to a test file is refused with an instruction to ask you first. Each subagent and each worktree is checked on its own. It runs in every repository where the plugin is installed, needs `bash`, `grep`, `sed`, `awk`, `shasum`, and `find`, and checks results, not intent; it is not a sandbox.

## How a loop works

1. **Plan.** The AI picks the candidate that moves the most acceptance scenarios or resolves the biggest open uncertainty, writes its done condition and criteria (with a command wherever a command can tell), and moves it to `in-progress/`. Independent candidates that touch different paths are picked together.
2. **Work.** A worker builds each one on branch `gdd/<slug>` in its own worktree and commits. When it hits a decision that is hard to reverse (data model, external services, authentication, new dependencies) or would loosen the acceptance criteria, it stops; the AI asks you three options and passes your answer back.
3. **Review.** The evaluator scores the criteria from evidence it gathers itself, the scenario checks run on the worker's branch, and the AI looks back: learnings go into `state.md` at once, anything that needs work becomes a new candidate. It picks what comes next and the next-reviewer checks that choice.
4. **Decide.** If the gate allows it, the loop continues. Otherwise you get one question: "Done, next is X because Y. OK / Change something / Stop". If you change its plan, it asks why and records your reason in `adr.md`.
5. **Finish.** Each finished Build sub-goal becomes a pull request. Sub-goals that depend on it start once it is merged.

### When the AI continues on its own

All of these must hold, checked by `gdd-status.sh` and the two reviewers: a Build sub-goal (Decide sub-goals always ask you), no qualitative criterion, every evaluator row Met, `done_checks` pass, the change within `max_files` / `max_lines`, the goal's progress not stuck for 3 reviews, the last 3 reviews kept without you overturning them or later rework, and the next-reviewer agrees. So it asks you often at first and less as it earns your trust in that repository. Changing the goal and the stop conditions always come to you.

When every scenario is met and nothing is left, the AI tells you the goal looks reached and asks whether to add sub-goals or write a goal completion report (`gdd/reviews/GOAL.md`: acceptance scenarios and their results, what was left undone, candidates for the next goal). Archiving a finished goal and starting the next one is not automated yet.

The AI replies in the language you use.

## Testing the skills

`plugins/polaris/evals/` holds eval cases for `claude plugin eval`: each case scaffolds a small git repository with a `gdd/`, runs `/polaris:gdd-loop` on it, and checks the files, reviews, and subagent calls it leaves behind. `tests/guard-gdd-writes.sh` and `tests/gdd-status.sh` check the hook and the status script without a model. Run them from the repository root (each case is one real Claude session, so it costs tokens):

```
claude plugin eval plugins/polaris --scaffold --allow-tools Bash Write Edit --ablation none --runs 1 --no-publish
```
