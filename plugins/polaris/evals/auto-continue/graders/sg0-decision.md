---
type: regex
pattern: "## Decision\\s*(<!--.*?-->)?\\s*Proceed \\(automatic\\)"
flags: s
match: contains
target:
  source: file
  path: auto-test/gdd/reviews/SG0.md
---

SG0's Decision section starts with "Proceed (automatic)": all criteria were quantitative and met, so the loop went on without the human.
