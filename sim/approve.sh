#!/bin/bash
# Simulates the human approving ask rules during one run: removes the given rules from the sim's settings,
# runs, then puts back only those rules, keeping whatever the run itself changed in the file.
#   approve.sh "<rule>[,<rule>...]" <run.sh args...>
H=$(cd "$(dirname "$0")" && pwd); S="$H/work/${SIM:-sim1}/sim/.claude/settings.json"
rules="$1"; shift
edit() { python3 -I - "$S" "$rules" "$1" <<'PY'
import json,sys
p,rules,mode=sys.argv[1],sys.argv[2].split(','),sys.argv[3]; d=json.load(open(p)); a=d['permissions']['ask']
d['permissions']['ask']=[r for r in a if r not in rules] if mode=='remove' else a+[r for r in rules if r not in a]
json.dump(d,open(p,'w'),indent=2)
PY
}
edit remove; bash "$H/run.sh" "$@"; edit restore
