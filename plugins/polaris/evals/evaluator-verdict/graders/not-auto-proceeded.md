---
type: regex
pattern: "## Decision\\s*(<!--.*?-->)?\\s*$"
flags: s
match: contains
target:
  source: file
  path: ev-test/gdd/reviews/SG0.md
---

A table that is not all "Met" does not continue automatically: the Decision section stays empty for the human.
