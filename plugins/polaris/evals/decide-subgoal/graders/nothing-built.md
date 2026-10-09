---
type: regex
pattern: "## Done:"
match: not_contains
target:
  source: file
  path: decide-test/gdd/subgoals.md
---

Nothing moved to Done: the human has not agreed on a format yet.
