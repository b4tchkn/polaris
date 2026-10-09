---
type: regex
pattern: "JSON[\\s\\S]*(chosen|Chosen)[^\\n]*A|(chosen|Chosen)[^\\n]*A[\\s\\S]*JSON"
match: contains
target:
  source: file
  path: chosen-test/gdd/adr.md
---

The entry lists the options offered (including the ones not chosen) and names the chosen one.
