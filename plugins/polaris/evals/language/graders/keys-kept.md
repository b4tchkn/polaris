---
type: regex
pattern: "progress:"
match: contains
target:
  source: file
  path: lang-test/gdd/reviews/hello-txt.md
---

Frontmatter keys stay as they are (gdd-status.sh reads them).
