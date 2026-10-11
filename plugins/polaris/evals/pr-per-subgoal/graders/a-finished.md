---
type: regex
pattern: "## Decision\\s*(<!--.*?-->)?\\s*[^\\n]*(Pull request opened|No pull request)[^\\n]*gdd/"
flags: s
match: contains
target:
  source: file
  path: pr-test/gdd/reviews/a-txt.md
---

a-txt ended as a pull request (or a named branch without a remote), recorded in its Decision section.
