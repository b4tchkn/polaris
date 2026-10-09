---
type: regex
pattern: "## Learnings[\\s\\S]*uppercase"
match: not_contains
target:
  source: file
  path: adopt-test/gdd/state.md
---

Proposal 2 (not adopted) was not applied: no learning about uppercase file names.
