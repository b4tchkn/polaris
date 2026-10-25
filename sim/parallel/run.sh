#!/bin/bash
# The parallel scenario: a repository with an approved goal and three independent, approved sub-goals (repo/).
# /polaris:gdd-loop builds them with workers. This script is the human: after each step it merges the open
# pull requests with sim-merge and resumes the session with its answer, until verify.sh passes (at most 4 steps).
#   bash sim/parallel/run.sh, then bash sim/verify.sh parallel
set -e
P=$(cd "$(dirname "$0")" && pwd); H=$(dirname "$P"); W="$H/work/parallel"; export SIM=parallel
[ -s "$H/.oauth-token" ] || { echo "parallel: no sim/.oauth-token" >&2; exit 1; }
field() { python3 -I -c 'import json,sys
for l in open(sys.argv[1]):
  d=json.loads(l)
  if d.get("type")=="result": print(d.get(sys.argv[2],""))' "$W/logs/$1.jsonl" "$2"; }
s=$SECONDS

docker build -q -t polaris-sim "$H" > /dev/null
rm -rf "$W"
bash "$H/setup.sh" parallel
cp -R "$P/repo/." "$W/sim/"
git -C "$W/sim" add -A
git -C "$W/sim" -c user.name=sim -c user.email=sim@example.com commit -q -m "chore: add the goal and sub-goals"
git -C "$W/sim" push -q "$W/remote.git" main
git -C "$W/sim" update-ref refs/remotes/origin/main HEAD
ls "$P/repo/gdd/subgoals" | sed 's/\.md$//' > "$W/subgoals.txt"

logs=(01-loop)
bash "$H/run.sh" 01-loop "/polaris:gdd-loop
The goal and the sub-goals in gdd/subgoals/ are approved. There is no CI here. I merge the pull requests myself: when they are ready, tell me and stop."
sid=$(field 01-loop session_id)
echo "01: $(field 01-loop result)"
for i in 2 3 4; do
  open=$(for d in "$W"/github/prs/*/; do [ "$(cat "$d/state" 2>/dev/null)" = OPEN ] && basename "$d"; done; true)
  for n in $open; do bash "$H/sh.sh" "sim-merge $n" || echo "parallel: could not merge #$n" >&2; done
  bash "$H/verify.sh" parallel > /dev/null 2>&1 && break
  msg="Go ahead with your recommendation for anything you asked me."
  [ -n "$open" ] && msg="I merged pull requests $(echo $open) into main. $msg"
  bash "$H/run.sh" 0$i-resume "$msg" "$sid"
  logs+=(0$i-resume)
  echo "0$i: $(field 0$i-resume result)"
done

# A step with background workers has several results, each with the cost so far: take the last.
cost=$(for l in "${logs[@]}"; do field $l total_cost_usd | tail -1; done | paste -sd+ - | bc)
echo "parallel: ${#logs[@]} steps in $((SECONDS - s))s, \$$cost (logs in $W/logs)"
