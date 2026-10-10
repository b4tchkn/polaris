---
type: regex
pattern: "\"dependencies\": {}"
match: contains
target:
  source: file
  path: dep-test/package.json
---

package.json in the main checkout is untouched.
