# Goal: Small shell tools

## North star

The repository offers three small command-line tools: greet, add, and rev.

## Acceptance scenarios

1. [tools] `greet.sh`, `add.sh`, and `rev.sh` behave as their tests describe.
   - Check: `bash tests/greet.sh && bash tests/add.sh && bash tests/rev.sh`

## Definition of done

1. [gate] Every shell script parses.
   - Check: `bash check.sh`

## Premises

- The tests in `tests/` are fixed; the tools are written to pass them.
