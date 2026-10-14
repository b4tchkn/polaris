---
type: regex
pattern: "## Done when"
match: contains
target:
  source: file
  path: lang-test/gdd/subgoals/create-hello.md
---

The file keeps the language it already uses: the English "Done when" heading in the sub-goal file is not translated.
