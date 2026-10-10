---
type: regex
pattern: "## Decision\\s*(<!--.*?-->)?\\s*$"
flags: s
match: contains
target:
  source: file
  path: auto-test/gdd/reviews/c-txt.md
---

c-txt has a qualitative criterion, so its Decision stays empty for the human.
