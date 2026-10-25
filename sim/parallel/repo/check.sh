#!/bin/bash
# The gate: every shell script in the repository parses.
set -e
for f in $(git ls-files '*.sh'); do bash -n "$f"; done
echo "check: ok"
