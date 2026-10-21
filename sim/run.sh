#!/bin/bash
# Runs one headless Claude Code step with polaris inside the container.
#   run.sh <log-name> <prompt> [session id to resume]
# The work tree, fake GitHub data, Claude config and logs live in sim/work/sim1 (mounted at /work).
H=$(cd "$(dirname "$0")" && pwd); W="$H/work/${SIM:-sim1}"; P="$(cd "$H/.." && pwd)/plugins/polaris"
mkdir -p "$W/logs"
r=(); [ -n "$3" ] && r=(--resume "$3")
CLAUDE_CODE_OAUTH_TOKEN="$(cat "$H/.oauth-token")" docker run --rm -e CLAUDE_CODE_OAUTH_TOKEN \
  -v "$W:/work" -v "$P:/polaris:ro" polaris-sim \
  claude -p --plugin-dir /polaris --dangerously-skip-permissions --output-format stream-json --verbose "${r[@]}" "$2" \
  > "$W/logs/$1.jsonl"
echo "exit $? -> $W/logs/$1.jsonl"
