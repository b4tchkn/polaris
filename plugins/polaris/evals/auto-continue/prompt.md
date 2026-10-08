---
name: auto-continue
max_turns: 80
timeout_seconds: 900
runs: 1
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit, Agent, AskUserQuestion]
---

/polaris:gdd-loop auto-test
