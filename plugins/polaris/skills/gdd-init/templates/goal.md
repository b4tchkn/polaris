---
scenario_1_check: <shell command that exits 0 when scenario 1 holds, run from the repository root; or "human" when only the human can judge it>
done_checks: <shell command every sub-goal must pass (tests, lint), or "none">
max_files: 10
max_lines: 300
prefer: <speed | certainty>
avoid: <areas the AI must not touch, or "none">
---
# Goal: <goal name>

## North star

<What this goal should achieve, in one sentence>

## Acceptance scenarios

1. <A scenario that shows the goal is reached>

## Definition of done

- <The quality bar every sub-goal meets (what done_checks runs, plus anything a command cannot check)>

## Premises

- None
