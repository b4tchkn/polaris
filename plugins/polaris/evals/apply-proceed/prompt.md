---
name: apply-proceed
max_turns: 60
timeout_seconds: 900
runs: 1
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit, Agent, AskUserQuestion]
---

/polaris:gdd-loop proceed-test
