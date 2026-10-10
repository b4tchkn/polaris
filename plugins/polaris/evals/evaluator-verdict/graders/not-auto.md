---
type: regex
pattern: "## Decision\\s*(<!--.*?-->)?\\s*$"
flags: s
match: contains
target:
  source: file
  path: ev-test/gdd/reviews/a-txt.md
---

A table that is not all Met does not continue automatically.
