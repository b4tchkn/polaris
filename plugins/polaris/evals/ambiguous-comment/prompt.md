---
name: ambiguous-comment
max_turns: 30
timeout_seconds: 600
runs: 1
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit, Agent, AskUserQuestion]
---

/polaris:gdd-loop ambig-test
