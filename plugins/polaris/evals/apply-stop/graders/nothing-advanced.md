---
type: regex
pattern: "## Done:"
match: not_contains
target:
  source: file
  path: stop-test/gdd/subgoals.md
---

After "Stop", no sub-goal is moved to Done and no new one is started.
