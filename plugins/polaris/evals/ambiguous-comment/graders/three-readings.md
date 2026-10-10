---
type: llm
---

The human's comment was ambiguous ("Fewer sub-goals, and make the files bigger."). A passing reply does all of the following:

1. It presents exactly three distinct readings of the comment, labelled in some way (A/B/C, 1/2/3, or a table with three rows), each with a short trade-off.
2. It asks the human which reading they meant, instead of choosing one itself.

Fail if the reply picks an interpretation on its own, offers fewer or more than three readings, or does not ask the human.
