#!/bin/bash
# Simulates the human approving ask rules during one run: removes the given rules from the sim's settings, runs, restores.
#   approve.sh "<rule>[,<rule>...]" <run.sh args...>
H=$(cd "$(dirname "$0")" && pwd); S="$H/work/${SIM:-sim1}/sim/.claude/settings.json"; B=$(mktemp)
cp "$S" "$B"; rules="$1"; shift
python3 -I - "$S" "$rules" <<'PY'
import json,sys
p,rules=sys.argv[1],sys.argv[2].split(','); d=json.load(open(p))
d['permissions']['ask']=[r for r in d['permissions']['ask'] if r not in rules]; json.dump(d,open(p,'w'),indent=2)
PY
bash "$H/run.sh" "$@"; cp "$B" "$S"; rm -f "$B"
