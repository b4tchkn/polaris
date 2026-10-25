#!/bin/bash
# Checks sim/verify.sh against fixture runs built with local git only (no Docker, no token).
set -e
V="$(cd "$(dirname "$0")/.." && pwd)/sim/verify.sh"
export SIM_WORK=$(mktemp -d)
trap 'rm -rf "$SIM_WORK"' EXIT
g() { git -c user.name=t -c user.email=t@example.com "$@"; }

# fixture <name> <gate command> <merge sg-b: yes|no> <mark sg-b done: yes|no> [acceptance command]
fixture() {
  W="$SIM_WORK/$1"; mkdir -p "$W"; printf 'sg-a\nsg-b\n' > "$W/subgoals.txt"
  git init -q --bare -b main "$W/remote.git"; git init -q -b main "$W/sim"; cd "$W/sim"
  mkdir -p gdd/subgoals
  printf '# Goal\n\n## Acceptance scenarios\n\n1. [works] works\n   - Check: `%s`\n\n## Definition of done\n\n1. [gate] passes\n   - Check: `%s`\n\n## Premises\n\n- Check: `false`\n' "${5:-true}" "$2" > gdd/goal.md
  for s in sg-a sg-b; do printf -- '---\nstatus: todo\n---\n# %s\n' $s > gdd/subgoals/$s.md; done
  g add -A; g commit -q -m start
  for s in sg-a sg-b; do
    g checkout -q -b $s main
    [ $s = sg-b ] && [ "$4" = no ] || sed -i.bak 's/^status: todo$/status: done/' gdd/subgoals/$s.md
    rm -f gdd/subgoals/*.bak; echo $s > $s.txt; g add -A; g commit -q -m $s
  done
  g checkout -q main; g merge -q --no-ff sg-a -m "merge sg-a"
  [ "$3" = yes ] && g merge -q --no-ff sg-b -m "merge sg-b"
  g push -q "$W/remote.git" main sg-a sg-b; cd - > /dev/null
}

# expect <name> <0 or the reason it must fail with>
expect() {
  out=$(bash "$V" "$1" 2>&1) && rc=0 || rc=$?
  if [ "$2" = 0 ]; then [ $rc = 0 ] || { echo "FAIL $1: expected 0, got $rc: $out"; exit 1; }
  else [ $rc != 0 ] && grep -q "$2" <<< "$out" || { echo "FAIL $1: expected failure '$2', got $rc: $out"; exit 1; }; fi
  echo "ok $1"
}

fixture pass 'test -f sg-a.txt && test -f sg-b.txt' yes yes
expect pass 0
fixture unmerged 'true' no yes
expect unmerged 'sg-b: no branch marking it done is merged'
fixture notdone 'true' yes no
expect notdone 'sg-b: not status: done on main'
fixture gatefails 'test -f missing.txt' yes yes
expect gatefails 'gate failed on main'
fixture acceptfails 'true' yes yes 'test -f missing.txt'
expect acceptfails 'acceptance check failed on main'
mkdir -p "$SIM_WORK/nolist"
expect nolist 'no .*subgoals.txt'
