---
type: regex
pattern: "## Learnings[\\s\\S]*trailing newline[^\\n]*hardened[^\\n]*CLAUDE\\.md"
match: contains
target:
  source: file
  path: proceed-test/gdd/state.md
---

The learning that already lives in CLAUDE.md was kept in state.md and marked "→ hardened: CLAUDE.md" when state.md was rewritten.
