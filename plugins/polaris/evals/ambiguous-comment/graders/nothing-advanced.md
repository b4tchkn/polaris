---
type: regex
pattern: "## Done:"
match: not_contains
target:
  source: file
  path: ambig-test/gdd/subgoals.md
---

No sub-goal was advanced while the question is open.
