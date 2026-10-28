---
name: gdd-loop
description: Run the Goal Driven Development loop. Decides the goal with the human if there is none, breaks it into sub-goals, has workers build them as pull requests (in parallel when independent), merges what is ready, and keeps going until the goal's checks pass. Use when "gdd-loop", "advance the goal", "run the loop". Run gdd-init first if gdd/ does not exist.
---

# gdd-loop

Move this repository toward the goal in `gdd/goal.md`. Talk to the human in the language they use.

If there is no goal yet, decide it with the human: a one-sentence north star and 3-5 outcomes, each with a Check (a command when possible). Have the polaris:goal-owner agent review the draft before the human approves it.

Break what is left into small sub-goals in `gdd/subgoals/<slug>.md`, each with its Done when and Check, and have the human approve the list. Changes to `gdd/` go to main through a pull request like everything else.

Ask the polaris:goal-owner agent what to start next. Build each in its own headless session running `/goal`, in parallel when they are independent. Start each with its own Bash call with `run_in_background`, so you are told when it ends:

`claude -p -w gdd-<slug> --plugin-dir ${CLAUDE_PLUGIN_ROOT} --agent polaris:worker --permission-mode auto --output-format json "/goal <condition>"`

The condition: every Check in `gdd/subgoals/<slug>.md` and the gate in `gdd/goal.md` pass with their output shown, and a pull request is open with its URL printed; or a question for the human is printed; or stop after 30 turns. Each ends as a pull request that shows what was built, how to try it, and the check results. If a worker ends with a question, ask the human and resume it from its worktree with `claude -p --resume <session_id> "<answer>"`.

Before merging, have the polaris:subgoal-verifier agent check the pull request. Merge it yourself once CI passes, unless it has a `human:` condition or changes `goal.md` or existing tests; those the human merges.

Ask the human before anything hard to reverse. When every Check in `goal.md` passes, report and stop.
