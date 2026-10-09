---
type: regex
pattern: "## Next: SG0"
match: contains
target:
  source: file
  path: lang-test/gdd/subgoals.md
---

The file keeps the language it already uses: the English "Next:" marker in subgoals.md is not translated.
