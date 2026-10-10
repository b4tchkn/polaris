---
scenario_1_check: human
scenario_2_check: human
scenario_3_check: human
scenario_4_check: human
scenario_5_check: claude plugin validate plugins/polaris
done_checks: bash tests/guard-gdd-writes.sh >/dev/null && bash tests/gdd-status.sh >/dev/null && claude plugin validate plugins/polaris >/dev/null
max_files: 15
max_lines: 600
prefer: certainty
avoid: none
---
# Goal: Goal Driven Development 基盤

## 大ゴール（北極星）

Goal Driven Development の基盤を作り、Claude Code の plugin として提供する。

- 新規のサービス開発や事業の立ち上げ（0→1）でも、既存のリポジトリ（1→100）でも、plugin を入れて init すれば同じ手順で始められる。
- AI（Claude Code）が GOAL に向かって自律的に作業し、人間は**要所で理解しながら介在する**。
  - 人間が見るのはコードの細部ではない。「何が出来上がったか」と「本当にそれでいいか」を見る。
  - 人間は毎ステップ承認する係にはならない。ただし、方向を決める瞬間には必ず関わる。

## 受け入れシナリオ

1. 新規リポジトリに plugin と init で導入し、小さな新規アプリのサブゴールを3つ以上回せる。
2. 既存のリポジトリに plugin と init で導入し、サブゴールを1つ以上回せる。
3. 各サブゴールの完了時に、人間がコードを読まずに、サブゴール完了報告とデモだけで「次へ進む / 方向転換 / やめる」を判断できる。
4. 振り返りの「変えること」が実際に次のループに反映され、同じ手戻りが再発しない。
5. GitHub 上で plugin として公開され、誰でも `/plugin install` で入れられる。

## 前提

- なし
