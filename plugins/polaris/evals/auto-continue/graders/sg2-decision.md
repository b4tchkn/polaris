---
type: regex
pattern: "## Decision\\s*(<!--.*?-->)?\\s*$"
flags: s
match: contains
target:
  source: file
  path: auto-test/gdd/reviews/SG2.md
---

SG2's Decision section is empty (only the template comment, nothing after it): SG2 has a qualitative criterion, so the loop must stop for the human.
