---
name: gdd-init
description: Set up Goal Driven Development in a repository. Writes gdd/goal.md from the template and adds approval rules to .claude/settings.json. Use when introducing GDD to a new or existing repository. Triggers: "gdd-init", "set up GDD".
---

# gdd-init

Talk to the human in the language they use.

Write this skill's `templates/goal.md` to `gdd/goal.md` and create `gdd/subgoals/`. If `gdd/` already exists, ask before overwriting.

Add `permissions.ask` rules to `.claude/settings.json` (merge with what is there) so the human approves edits to `gdd/goal.md`, pushes to main, and the hard-to-reverse actions of this repository's stack: adding a dependency, changing migrations, and editing the settings file itself. Add `.claude/worktrees/` to `.gitignore`.

Report what you changed, and tell the human to run `/polaris:gdd-loop` next.
