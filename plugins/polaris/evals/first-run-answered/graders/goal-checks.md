---
type: regex
pattern: "<shell command"
match: not_contains
target:
  source: file
  path: gdd/goal.md
---

Every scenario got a real check (a command or human) instead of the template placeholder.
