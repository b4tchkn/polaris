---
type: regex
pattern: "[ぁ-んァ-ヶ一-龠]{4,}"
match: contains
target:
  source: file
  path: lang-test/gdd/reviews/SG0.md
---

The review is written in Japanese, the language the human used.
