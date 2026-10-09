---
type: llm
weight: 1
---

The human's "Change direction" comment was ambiguous ("Fewer sub-goals, and make the files bigger."). A passing reply does all of the following:

1. It presents exactly three distinct readings (interpretations) of the comment, labelled in some way (A/B/C, 1/2/3, or a table with three rows), each with a short trade-off.
2. It asks the human which reading they meant, instead of choosing one itself.
3. It says, or makes clear, that subgoals.md has not been rewritten yet.

Fail if the reply picks an interpretation on its own, offers fewer or more than three readings, or does not ask the human.
