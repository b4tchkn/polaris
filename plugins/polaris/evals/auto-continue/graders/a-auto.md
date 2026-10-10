---
type: regex
pattern: "## Decision\\s*(<!--.*?-->)?\\s*Proceed \\(automatic\\)"
flags: s
match: contains
target:
  source: file
  path: auto-test/gdd/reviews/a-txt.md
---

a-txt continued without the human: only quantitative criteria, all met, trusted streak.
