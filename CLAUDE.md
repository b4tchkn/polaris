# CLAUDE.md

## 前提

- 設計は docs/design.md に従う。
- 骨格は既存手法（Spec Kit、Anthropic の long-running harness など）から借り、自作するのは「理解・介在」の層に絞る。
- GDD の仕組み（skill、雛形、設定、design.md）を変えるときは、必要最低限の変更にとどめ、複雑にしすぎない。
- YAGNI：今の問題を解くのに要らないもの（将来に備えた拡張、使われていない設定、1か所でしか使わない抽象化）は作らない。必要になったときに足す。

## Git

- コミットメッセージは英語で、`<prefix>: <message>` の形で書く（例：`feat: add gdd-loop skill`）。
- prefix は `feat` / `fix` / `refactor` / `docs` / `chore` などを使う。
