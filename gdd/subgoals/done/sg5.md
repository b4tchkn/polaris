---
type: build
advances: history (before the 2026-10-10 redesign)
depends_on: none
touches: plugins/polaris/, docs/, README.md
---
# SG5 シミュレーションを回せるようにする

| 項目 | 内容 |
|---|---|
| ゴール | `simulations/<名前>/` の中で `gdd-init` と `gdd-loop` を使えるようにし、1つ目のシミュレーションの状態ファイルを作る |
| 種類と完了条件 | 作る系。`simulations/` が commit されず、対象ディレクトリを渡すとそこの `gdd/` を読み書きする。`simulations/morning-review/gdd/` に雛形一式が揃う |
| 結果 | `gdd-init` / `gdd-loop` が対象ディレクトリを受け取れる。`simulations/` は commit しない。`simulations/**` の goal.md / subgoals.md は ask、どこの state.md も allow。`simulations/morning-review/gdd/` を作った。ゴールが雛形のままなら、`gdd-loop` がゴールと SG0 を一緒に決める |
