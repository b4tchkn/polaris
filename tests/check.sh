#!/bin/bash
# This repository's gate: everything that checks polaris without a model.
set -e
cd "$(dirname "$0")/.."
claude plugin validate plugins/polaris > /dev/null
echo "check: ok"
