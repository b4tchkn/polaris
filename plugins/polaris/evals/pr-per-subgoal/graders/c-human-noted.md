---
type: regex
pattern: "natural[\\s\\S]*for the human|for the human[\\s\\S]*natural"
flags: i
match: contains
target:
  source: file
  path: pr-test/gdd/reviews/c-txt.md
---

The human: condition is marked for the human in the review, so it becomes a pull request comment.
