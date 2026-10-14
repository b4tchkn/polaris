#!/bin/bash
# This repository's gate: everything that checks polaris without a model.
set -e
cd "$(dirname "$0")/.."
for t in tests/*.sh; do [ "$t" = tests/check.sh ] || bash "$t" > /dev/null; done
claude plugin validate plugins/polaris > /dev/null
echo "check: ok"
