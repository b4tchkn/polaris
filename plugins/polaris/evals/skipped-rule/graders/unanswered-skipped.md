---
type: regex
pattern: "## Decision[\\s\\S]*skipped"
flags: i
match: contains
target:
  source: file
  path: skip-test/gdd/reviews/create-a.md
---

Question 3 (proposals) was not answered, so the Decision section marks it as skipped instead of carrying it over.
