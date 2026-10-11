---
type: regex
pattern: "^-{3}\\nprefer:[^\\n]*\\n-{3}"
match: contains
target:
  source: file
  path: gdd/goal.md
---

The goal template's frontmatter holds only the AI's setting: prefer.
