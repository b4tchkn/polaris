---
type: regex
pattern: "## Decision\\s*(<!--.*?-->)?\\s*[^\\n]*(A|Markdown)"
flags: s
match: contains
target:
  source: file
  path: chosen-test/gdd/reviews/SG0.md
---

The Decision section records the chosen option.
