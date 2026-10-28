#!/bin/bash
# Runs one headless Claude Code step with polaris inside the container.
#   run.sh <log-name> <prompt> [session id to resume]
# The work tree, fake GitHub data, Claude config and logs live in sim/work/$SIM (default sim1, mounted at /work).
# acceptEdits with Bash allowed, not bypassing permissions: bypass ignores ask rules, so approve.sh would approve nothing.
# --add-dir lets skills read their own files (templates); Agent runs goal-owner and subgoal-verifier, Bash the worker sessions.
H=$(cd "$(dirname "$0")" && pwd); W="$H/work/${SIM:-sim1}"; P="$(cd "$H/.." && pwd)/plugins/polaris"
mkdir -p "$W/logs"
r=(); [ -n "$3" ] && r=(--resume "$3")
docker run --rm -v "$H/.oauth-token:/run/oauth-token:ro" \
  -v "$W:/work" -v "$P:/polaris:ro" polaris-sim \
  claude -p --plugin-dir /polaris --add-dir /polaris --permission-mode acceptEdits --allowedTools Bash Agent --output-format stream-json --verbose "${r[@]}" "$2" \
  > "$W/logs/$1.jsonl"
echo "exit $? -> $W/logs/$1.jsonl"
