---
name: apply-stop
max_turns: 20
timeout_seconds: 300
runs: 1
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit, Agent, AskUserQuestion]
---

/polaris:gdd-loop stop-test
