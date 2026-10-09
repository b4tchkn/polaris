---
type: regex
pattern: "## Done:"
match: not_contains
target:
  source: file
  path: notes-test/gdd/subgoals.md
---

The sub-goal was not completed while the decision is open.
