#!/bin/bash
# The parallel scenario: a repository with an approved goal and three independent, approved sub-goals (repo/).
# /polaris:gdd-loop builds them with workers and merges them itself (the fake gh has pr checks and pr merge).
# This script only gives the human's scripted answers: it resumes the session until verify.sh passes and the
# loop reports that the goal's Checks pass, at most 5 steps.
#   bash sim/parallel/run.sh, then bash sim/verify.sh parallel
set -e
P=$(cd "$(dirname "$0")" && pwd); H=$(dirname "$P"); W="$H/work/parallel"; export SIM=parallel
[ -s "$H/.oauth-token" ] || { echo "parallel: no sim/.oauth-token" >&2; exit 1; }
# A field of a step's last result. With background workers a step has several, each with the cost so far.
field() { python3 -I -c 'import json,sys
r={}
for l in open(sys.argv[1]):
  d=json.loads(l)
  if d.get("type")=="result": r=d
print(r.get(sys.argv[2],""))' "$W/logs/$1.jsonl" "$2"; }
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
The goal and the sub-goals in gdd/subgoals/ are approved."
sid=$(field 01-loop session_id)
echo "01: $(field 01-loop result)"
for i in 2 3 4 5; do
  bash "$H/verify.sh" parallel > /dev/null 2>&1 && field "${logs[${#logs[@]}-1]}" result | grep -Eiq 'goal.*(pass|met|reached)' && break
  bash "$H/run.sh" 0$i-resume "Go ahead with your recommendation for anything you asked me." "$sid"
  logs+=(0$i-resume)
  echo "0$i: $(field 0$i-resume result)"
done

cost=$(for l in "${logs[@]}"; do field $l total_cost_usd; done | paste -sd+ - | bc)
echo "parallel: ${#logs[@]} steps in $((SECONDS - s))s, \$$cost (logs in $W/logs)"
