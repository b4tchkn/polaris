---
type: regex
pattern: "done[-.]?(txt|file)[\\s\\S]*(next goal|candidate)"
flags: i
match: contains
target:
  source: file
  path: done-test/gdd/reviews/GOAL.md
---

The report covers the scenario's result and lists candidates for the next goal.
