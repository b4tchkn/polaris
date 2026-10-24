#!/bin/bash
# This repository's gate: everything that checks polaris without a model.
set -e
cd "$(dirname "$0")/.."
claude plugin validate plugins/polaris > /dev/null
bash tests/sim-verify.sh
# ask rules must hold in the simulation, or approve.sh approves nothing.
grep -q dangerously-skip-permissions sim/run.sh && { echo "check: sim/run.sh skips permissions" >&2; exit 1; }
echo "check: ok"
