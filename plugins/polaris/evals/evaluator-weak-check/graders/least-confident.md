---
type: regex
pattern: "## Least confident[\\s\\S]*(exact|test -d)"
match: contains
target:
  source: file
  path: ev-test/gdd/reviews/a-txt.md
---

The weak check is listed under Least confident, so it becomes a pull request comment.
