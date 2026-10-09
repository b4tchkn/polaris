---
type: regex
pattern: "## Improvement proposals[\\s\\S]*\\|\\s*1\\s*\\|\\s*(Add learning|Fix the process|Harden a learning|Revise sub-goals)\\s*\\|[^|\\n]+\\|[^|\\n]+\\|[^|\\n]+\\|"
match: contains
target:
  source: file
  path: ev-test/gdd/reviews/SG0.md
---

The unverifiable criterion is a real problem, so the retrospective produced at least one numbered proposal of one of the four kinds, with where it goes and a trade-off.
