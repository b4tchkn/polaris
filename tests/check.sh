#!/bin/bash
# This repository's gate: everything that checks polaris without a model.
set -e
cd "$(dirname "$0")/.."
bash tests/guard-gdd-writes.sh > /dev/null
bash tests/gdd-status.sh > /dev/null
claude plugin validate plugins/polaris > /dev/null
echo "check: ok"
