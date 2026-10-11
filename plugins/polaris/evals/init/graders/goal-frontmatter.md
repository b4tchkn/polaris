---
type: regex
pattern: "prefer:[\\s\\S]*avoid:"
match: contains
target:
  source: file
  path: gdd/goal.md
---

The goal template's frontmatter holds only the AI's settings: prefer and avoid.
