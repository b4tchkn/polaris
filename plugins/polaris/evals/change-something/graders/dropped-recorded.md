---
type: regex
pattern: "Rejected ideas[\\s\\S]*b[-.]txt"
match: contains
target:
  source: file
  path: change-test/gdd/state.md
---

The dropped candidates are listed under Rejected ideas so they are not proposed again.
