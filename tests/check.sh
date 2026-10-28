#!/bin/bash
# This repository's gate: everything that checks polaris without a model.
set -e
cd "$(dirname "$0")/.."
claude plugin validate plugins/polaris > /dev/null
bash tests/sim-verify.sh
# ask rules must hold in the simulation, or approve.sh approves nothing.
grep -q dangerously-skip-permissions sim/run.sh && { echo "check: sim/run.sh skips permissions" >&2; exit 1; }
# Without these, skills cannot read their templates and gdd-loop cannot run its agents in the simulation.
grep -q -- '--add-dir /polaris ' sim/run.sh && grep -q -- '--allowedTools Bash Agent ' sim/run.sh || { echo "check: sim/run.sh lacks --add-dir /polaris or the Agent tool" >&2; exit 1; }
echo "check: ok"
