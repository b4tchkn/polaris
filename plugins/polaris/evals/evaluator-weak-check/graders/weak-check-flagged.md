---
type: regex
pattern: "trivial|does not (test|check)|doesn't (test|check)|only (tests|checks) (that )?the (folder|directory)|weak"
flags: i
match: contains
target:
  source: file
  path: ev-test/gdd/reviews/a-txt.md
---

The review reports that the check for `exact` passes trivially, as the evaluator found.
