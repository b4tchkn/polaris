---
type: regex
pattern: "done\\.txt[\\s\\S]*(next goal|candidate)"
flags: i
match: contains
target:
  source: file
  path: done-test/gdd/reviews/GOAL.md
---

The report covers the acceptance scenario's result (done.txt) and lists candidates for the next goal.
