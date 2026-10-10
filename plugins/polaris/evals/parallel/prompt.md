---
name: parallel
max_turns: 120
timeout_seconds: 1800
runs: 1
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit, Agent, AskUserQuestion]
---

/polaris:gdd-loop par-test
