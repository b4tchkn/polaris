---
type: regex
pattern: "\\[gate\\][\\s\\S]*Check:"
match: contains
target:
  source: file
  path: gdd/goal.md
---

The template asks for a gate with a Check line.
