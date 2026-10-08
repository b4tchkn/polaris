---
type: regex
pattern: "Proceed \\(automatic\\)"
match: not_contains
target:
  source: file
  path: auto-test/gdd/reviews/SG2.md
---

SG2 has a qualitative criterion, so the loop must stop for the human instead of proceeding automatically.
