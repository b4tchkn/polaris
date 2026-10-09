---
name: evaluator-verdict
max_turns: 50
timeout_seconds: 900
runs: 1
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit, Agent, AskUserQuestion]
---

/polaris:gdd-loop ev-test
