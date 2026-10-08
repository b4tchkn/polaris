---
type: regex
pattern: "## Decision\\s*(<!--.*?-->)?\\s*Proceed \\(automatic\\)"
flags: s
match: contains
target:
  source: file
  path: auto-test/gdd/reviews/SG1.md
---

SG1's Decision section starts with "Proceed (automatic)": the loop reached SG1 and went on without the human.
