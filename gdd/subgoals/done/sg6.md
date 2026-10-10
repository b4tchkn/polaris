---
type: build
advances: history (before the 2026-10-10 redesign)
depends_on: none
touches: plugins/polaris/, docs/, README.md
---
# SG6 シミュレーション1（朝の振り返り skill）を動くところまで回す

| 項目 | 内容 |
|---|---|
| ゴール | `/gdd-loop simulations/morning-review` をくり返し、朝の振り返り skill を動くところまで作る |
| 種類と完了条件 | 作る系。朝に実行すると、昨日の出来事の振り返りと今日まずやることが出る skill が動く。シミュレーションの中の判断はすべて人間が選ぶ |
| 結果 | SG0〜SG3 を回し、6つの集める先から Slack に届く skill が `/morning-review` で動いた。人間の判断15回、adr.md に6件。実際の朝に使って直す前に終えた |
