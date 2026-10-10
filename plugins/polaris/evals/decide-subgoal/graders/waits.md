---
type: regex
pattern: "## Decision\\s*(<!--.*?-->)?\\s*$"
flags: s
match: contains
target:
  source: file
  path: decide-test/gdd/reviews/note-format.md
---

A Decide sub-goal never continues automatically: the Decision section stays empty for the human.
