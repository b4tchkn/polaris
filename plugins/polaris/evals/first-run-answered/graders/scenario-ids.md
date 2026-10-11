---
type: regex
pattern: "\\[[a-z0-9-]+\\][^\\n]*\\n\\s*- Check:"
match: contains
target:
  source: file
  path: gdd/goal.md
---

Scenarios carry an [id] and a Check line.
