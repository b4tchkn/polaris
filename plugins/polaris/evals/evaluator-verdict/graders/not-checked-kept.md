---
type: regex
pattern: "\\|[^\\n]*Not checked[^\\n]*\\|"
match: contains
target:
  source: file
  path: ev-test/gdd/reviews/a-txt.md
---

The Actions criterion could not be verified offline, so its row says Not checked, pasted unchanged.
