---
type: regex
pattern: "polaris:worker[^\\n]*polaris:worker"
match: contains
target: trace
---

Both workers were started in the same turn (two Agent calls in one assistant message), not one after the other.
