---
name: gdd-init
description: Set up Goal Driven Development in a repository. Writes the state files (gdd/goal.md, gdd/subgoals.md, gdd/state.md) from templates and adds rules to .claude/settings.json so that writes to goal.md / subgoals.md need human approval. Use when introducing GDD to a new or existing repository, or when starting a new goal after archiving the previous one. Triggers: "gdd-init", "set up GDD", "initialize GDD state".
---

# gdd-init

Talk to the human in the language they use. Keep the file contents in the templates' language.

## Target directory

If a directory is passed as an argument (e.g. `simulations/morning-review`), read every `gdd/` below as `<directory>/gdd/`. Use the `.claude/settings.json` at the repository root, and prefix rule paths with `/<directory>` (e.g. `Edit(/simulations/morning-review/gdd/goal.md)`). Skip a rule when a broader one already covers it (e.g. `Edit(/simulations/**/gdd/goal.md)`). Without an argument, target the repository root.

## Steps

1. If `gdd/` already has `goal.md`, `subgoals.md`, or `state.md`, ask the human before overwriting. Stop if they decline.
2. Write `goal.md`, `subgoals.md`, and `state.md` from this skill's `templates/` into `gdd/` as they are.
   - Do not touch `gdd/archive/`. Do not create it (it is created when a goal is first completed).
3. Add these rules to `.claude/settings.json`:
   - `permissions.ask`: `Edit(/gdd/goal.md)`, `Edit(/gdd/subgoals.md)`
   - `permissions.allow`: `Edit(/gdd/state.md)`
   - Create the file if missing. Merge without removing existing keys or rules, and skip rules that already exist.
   - Tell the human that changed `allow` rules in a project's `.claude/settings.json` take effect only after they restart Claude Code and accept the trust prompt.
4. Report the files you created or changed, then stop. Do not commit.
5. Tell the human the next step: run `/polaris:gdd-loop` to decide the goal together.
