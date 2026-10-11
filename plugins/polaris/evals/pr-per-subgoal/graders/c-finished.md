---
type: regex
pattern: "## Decision\\s*(<!--.*?-->)?\\s*[^\\n]*(Pull request opened|No pull request)[^\\n]*gdd/"
flags: s
match: contains
target:
  source: file
  path: pr-test/gdd/reviews/c-txt.md
---

c-txt also ended as a pull request: a human: condition is left to the pull request review, not asked about first.
