---
type: regex
pattern: "## Decision\\s*(<!--.*?-->)?\\s*Proceed \\(automatic\\)"
flags: s
match: contains
target:
  source: file
  path: auto-test/gdd/reviews/b-txt.md
---

b-txt continued without the human.
