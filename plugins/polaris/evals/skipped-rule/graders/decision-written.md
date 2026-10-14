---
type: regex
pattern: "## Decision\\s*(<!--.*?-->)?\\s*Proceed"
flags: s
match: contains
target:
  source: file
  path: skip-test/gdd/reviews/create-a.md
---

The answered questions were written into the Decision section (Proceed, option A).
