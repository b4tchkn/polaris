# Goal: <goal name>

## North star

<What this goal should achieve, in one sentence>

## Acceptance scenarios

> Outcomes of the whole goal, from the user's side: 3 to 5, at most 7. Keep one only if the goal would be unmet when it alone fails. Edge cases belong in a sub-goal's "Done when".
> Each gets an `[id]` and a `Check:` line. Prefer a command (tests, scripts): `` Check: `<command>` ``. Otherwise `Check: observe: <what to look at>` or `Check: human: <why only a human can judge>`.

1. [<id>] <An outcome that shows the goal is reached>
   - Check: `<command that exits 0 when it holds>`

## Definition of done

> The gate every sub-goal passes: one command that runs the project's formatter, linter, type check, build, and tests.

1. [gate] <What every sub-goal must pass>
   - Check: `<one command, e.g. npm run check>`

## Premises

- None
