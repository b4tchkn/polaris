---
type: regex
pattern: "[^\\n?]{10,}\\?"
match: contains
---

With goal.md still the template, gdd-loop asks the human questions to decide the goal instead of advancing a sub-goal. AskUserQuestion is not available in an eval session, so the questions arrive as text in the reply; any real question line counts.
