---
name: gdd-init
description: Set up Goal Driven Development in a repository. Writes the state files (gdd/goal.md, gdd/subgoals/, gdd/uncertainties/, gdd/adr/) from templates and adds rules to .claude/settings.json so that writes to goal.md and hard-to-reverse actions need human approval. Use when introducing GDD to a new or existing repository, or when starting a new goal after archiving the previous one. Triggers: "gdd-init", "set up GDD", "initialize GDD state".
---

# gdd-init

Talk to the human in the language they use. Keep the file contents in the templates' language.

## Target directory

If a directory is passed as an argument (e.g. `simulations/morning-review`), read every `gdd/` below as `<directory>/gdd/`. Use the `.claude/settings.json` at the repository root, and prefix rule paths with `/<directory>` (e.g. `Edit(/simulations/morning-review/gdd/goal.md)`). Skip a rule when a broader one already covers it (e.g. `Edit(/simulations/**/gdd/goal.md)`). Without an argument, target the repository root.

## Steps

1. If `gdd/` already has `goal.md`, `subgoals/`, `uncertainties/`, or `adr/`, ask the human before overwriting. Stop if they decline.
2. Write `goal.md` from this skill's `templates/` into `gdd/` as it is, using the Write tool (a Bash copy of `goal.md` is reverted by the hook). Create the empty directories `gdd/subgoals/`, `gdd/uncertainties/`, `gdd/reviews/`, and `gdd/adr/`.
3. Add these rules to `.claude/settings.json`:
   - `permissions.ask`: `Edit(/gdd/goal.md)`, `Edit(/.claude/worktrees/*/gdd/goal.md)`
   - `permissions.allow`: `Edit(/gdd/**)`, `Edit(/.claude/worktrees/*/gdd/**)` (gdd-loop writes `gdd/`, in this checkout or in worktrees; only `goal.md` needs the human's approval)
   - `permissions.ask`, hard-to-reverse actions, so the human approves them whatever the AI thinks:
     - Adding a dependency: `Bash(npm install *)`, `Bash(npm i *)`, `Bash(yarn add *)`, `Bash(pnpm add *)`, `Bash(pip install *)`, `Bash(pip3 install *)`, `Bash(uv add *)`, `Bash(poetry add *)`, `Bash(go get *)`, `Bash(cargo add *)`, `Bash(gem install *)`, `Bash(bundle add *)`, `Edit(/package.json)`, `Edit(**/build.gradle)`, `Edit(**/build.gradle.kts)`, `Edit(**/libs.versions.toml)`, `Edit(/requirements*.txt)`, `Edit(/pyproject.toml)`, `Edit(/go.mod)`, `Edit(/Cargo.toml)`, `Edit(/Gemfile)`
     - Changing the data model: `Edit(**/migrations/**)`, `Edit(**/migration/**)`, `Edit(**/*.sql)`
     - Leaving the repository: `Bash(git push *)`, `Bash(gh pr merge *)`, `Bash(gh release *)`
     - Rewriting history: `Bash(git rebase *)`, `Bash(git reset --hard *)`, `Bash(git filter-branch *)`, `Bash(git filter-repo *)`
     - The rules themselves: `Edit(/.claude/settings.json)`
   - `worktree.baseRef`: `"head"`, so worktrees start from the current commit instead of the remote default branch.
   - Create the file if missing. Merge without removing existing keys or rules, and skip rules that already exist.
   - Tell the human that the new rules in `.claude/settings.json` take effect once they accept the trust prompt for the project settings (restart Claude Code if it does not appear).
4. Add `.claude/worktrees/` to `.gitignore` (create it if missing) so worktrees do not show up as untracked files.
5. Report the files you created or changed, then stop. Do not commit (the human decides when the setup goes in).
6. Tell the human the next step: run `/polaris:gdd-loop` to decide the goal together.
