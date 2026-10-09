---
type: regex
pattern: "## Decision log[\\s\\S]*(Change direction|README)"
match: contains
target:
  source: file
  path: change-test/gdd/state.md
---

The decision and the comment were copied into the decision log in state.md.
