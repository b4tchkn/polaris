---
type: regex
pattern: "## Learnings[\\s\\S]*trailing newline"
match: contains
target:
  source: file
  path: adopt-test/gdd/state.md
---

Proposal 1 (adopted) became a learning in state.md.
