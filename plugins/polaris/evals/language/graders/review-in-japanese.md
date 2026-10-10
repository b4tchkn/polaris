---
type: regex
pattern: "[\u3041-\u3093\u30a1-\u30f6\u4e00-\u9fa0]{4,}"
match: contains
target:
  source: file
  path: lang-test/gdd/reviews/hello-txt.md
---

The review is written in Japanese, the language the human used.
