#!/bin/bash
# The gate: every shell script parses, and the test of every tool that exists passes.
# A tool not built yet is skipped here; the [tools] Check in gdd/goal.md requires all of them.
set -e
for f in $(git ls-files '*.sh'); do bash -n "$f"; done
for t in tests/*.sh; do [ ! -e "$(basename "$t")" ] || bash "$t"; done
echo "check: ok"
