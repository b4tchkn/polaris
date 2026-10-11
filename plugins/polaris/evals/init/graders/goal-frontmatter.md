---
type: regex
pattern: "^---\\nprefer:[^\\n]*\\n---"
match: contains
target:
  source: file
  path: gdd/goal.md
---

The goal template's frontmatter holds only the AI's setting: prefer.
