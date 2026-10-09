---
type: regex
pattern: "## Done:"
match: not_contains
target:
  source: file
  path: change-test/gdd/subgoals.md
---

After "Change direction" the loop stops: no sub-goal is advanced in the same run.
