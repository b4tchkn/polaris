#!/bin/bash
# Builds the image, recreates sim/work/smoke/ with setup.sh, and runs headless Claude Code with polaris in it:
#   01 gdd-init in the empty repo, then a push to main, whose ask rule approve.sh approves
#   02 gdd-init again, which must ask before overwriting gdd/
#   03 the scripted answer, passed with --resume into the same session
set -e
H=$(cd "$(dirname "$0")" && pwd); W="$H/work/smoke"; export SIM=smoke
[ -s "$H/.oauth-token" ] || { echo "smoke: no sim/.oauth-token" >&2; exit 1; }
fail() { echo "smoke: FAIL: $*" >&2; exit 1; }
field() { python3 -I -c 'import json,sys
for l in open(sys.argv[1]):
  d=json.loads(l)
  if d.get("type")=="result": print(d.get(sys.argv[2],""))' "$W/logs/$1.jsonl" "$2"; }
s=$SECONDS

docker build -q -t polaris-sim "$H" > /dev/null
rm -rf "$W"
bash "$H/setup.sh" smoke
for p in remote.git sim/.git github claude-home; do [ -e "$W/$p" ] || fail "setup did not create $p"; done
grep -q '"ask"' "$W/sim/.claude/settings.json" || fail "setup did not write ask rules"
git -C "$W/remote.git" rev-parse -q --verify main > /dev/null || fail "remote.git has no main"

bash "$H/approve.sh" "Bash(git push *main*)" 01-init "/polaris:gdd-init, then commit everything and push it to origin main."
[ -s "$W/sim/gdd/goal.md" ] || fail "gdd-init did not create gdd/goal.md"
git -C "$W/remote.git" cat-file -e main:gdd/goal.md || fail "the approved push did not reach remote.git's main"
sum=$(shasum "$W/sim/gdd/goal.md")

# A word only the 02 session knows, so a fresh session without --resume cannot pass 03.
word=w$RANDOM$RANDOM
bash "$H/run.sh" 02-reinit "/polaris:gdd-init (also remember the word $word for later)"
sid=$(field 02-reinit session_id)
echo "asked ($sid): $(field 02-reinit result)"
field 02-reinit result | grep -Eqi 'overwrit|replac' || fail "gdd-init did not ask before overwriting gdd/"
bash "$H/run.sh" 03-answer "No, do not overwrite; keep gdd/ as it is. Then reply with the word I asked you to remember." "$sid"
echo "after the answer ($(field 03-answer session_id)): $(field 03-answer result)"
[ "$(field 03-answer session_id)" = "$sid" ] || fail "03 did not continue the 02 session"
[ "$(shasum "$W/sim/gdd/goal.md")" = "$sum" ] || fail "gdd/goal.md was overwritten"
field 03-answer result | grep -q "$word" || fail "the resumed session did not continue with the answer"

cost=$(for l in 01-init 02-reinit 03-answer; do field $l total_cost_usd; done | paste -sd+ - | bc)
echo "smoke: ok in $((SECONDS - s))s, \$$cost (logs in $W/logs)"
