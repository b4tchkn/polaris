---
type: regex
pattern: "<command that exits 0|<goal name>|<id>"
match: not_contains
target:
  source: file
  path: gdd/goal.md
---

No template placeholder is left in goal.md.
