#!/bin/bash
# Runs a shell command inside the container as the human (sim-merge, git pull, inspection). No Claude, no token.
H=$(cd "$(dirname "$0")" && pwd)
docker run --rm -v "$H/work/${SIM:-sim1}:/work" -v "$(cd "$H/.." && pwd)/plugins/polaris:/polaris:ro" polaris-sim bash -c "$1"
