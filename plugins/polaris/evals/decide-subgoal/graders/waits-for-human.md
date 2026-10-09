---
type: regex
pattern: "## Decision\\s*(<!--.*?-->)?\\s*$"
flags: s
match: contains
target:
  source: file
  path: decide-test/gdd/reviews/SG0.md
---

A Decide sub-goal is never completed automatically: the Decision section stays empty for the human.
