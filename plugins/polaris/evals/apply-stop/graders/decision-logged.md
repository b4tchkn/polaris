---
type: regex
pattern: "## Decision log[\\s\\S]*Stop"
match: contains
target:
  source: file
  path: stop-test/gdd/state.md
---

The "Stop" decision was copied into the decision log in state.md before stopping.
