---
type: regex
pattern: "(goal|build|achieve|users?|success)[^\\n?]*\\?"
flags: i
match: contains
---

With goal.md still the template, gdd-loop asks the human questions to decide the goal (who uses it, what success looks like) instead of advancing a sub-goal. AskUserQuestion is not available in an eval session, so the questions arrive as text in the reply.
