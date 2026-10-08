#!/bin/bash
# Self-check for guard-gdd-writes.sh. Prints PASS/FAIL per case; exits 1 on any FAIL.
HOOK="$(cd "$(dirname "$0")/.." && pwd)/plugins/polaris/hooks/guard-gdd-writes.sh"
W=$(mktemp -d "${TMPDIR:-/tmp}/guard-test-XXXX"); cd "$W"
export TMPDIR="$W/tmp"; mkdir -p "$TMPDIR" gdd sub/gdd tests
printf '# Goal: X\n' > gdd/goal.md
printf '# Sub-goals\n' > gdd/subgoals.md
printf '# Goal: Y\n' > sub/gdd/goal.md
printf '# State\n\n## Now\n\n- a\n\n## Learnings\n\n- keep one\n- keep two\n' > gdd/state.md
printf '# State\n\n## 現状\n\n- a\n\n## 学び\n\n- 学び一\n- 学び二\n' > gdd/state-ja.md
printf '# ADR\n\n## 2026-01-01 SG0 x\n\n- Decided: a\n' > gdd/adr.md
printf 'def test_a():\n    assert 1\n' > tests/test_a.py

fail=0
check() { # name expected_exit actual_exit
  if [ "$2" = "$3" ]; then echo "PASS $1"; else echo "FAIL $1 (want exit $2, got $3)"; fail=1; fi
}
json() { printf '{"session_id":"s1","tool_name":"%s","tool_input":{"command":"x","file_path":"%s"}}' "$1" "$2"; }

# --- Bash writes to goal/subgoals: each must be reverted and refused
bash_case() { # name, command that writes
  json Bash "" | bash "$HOOK" pre
  bash -c "$2" 2>/dev/null
  json Bash "" | bash "$HOOK" post 2>/dev/null; rc=$?
  check "bash: $1" 2 "$rc"
  [ "$(cat gdd/goal.md)" = "# Goal: X" ] || { echo "FAIL bash: $1 goal.md not restored"; fail=1; }
  [ "$(cat gdd/subgoals.md)" = "# Sub-goals" ] || { echo "FAIL bash: $1 subgoals.md not restored"; fail=1; }
  [ "$(cat sub/gdd/goal.md)" = "# Goal: Y" ] || { echo "FAIL bash: $1 sub goal.md not restored"; fail=1; }
}
bash_case "redirect"        'echo hacked > gdd/goal.md'
bash_case "python open"     'python3 -c "open(\"gdd/goal.md\",\"w\").write(\"hacked\")"'
bash_case "cd then write"   'cd gdd && echo hacked > subgoals.md'
bash_case "variable path"   'F=gdd/goal.md; echo hacked > $F'
bash_case "glob"            'echo hacked > gdd/go*.md'
bash_case "sed -i"          'sed -i "" "s/X/hacked/" gdd/goal.md'
bash_case "delete"          'rm gdd/goal.md'
bash_case "nested dir"      'echo hacked > sub/gdd/goal.md'
bash_case "git checkout"    'git init -q . 2>/dev/null; git add -A; git -c user.email=a@b -c user.name=a commit -qm i; echo hacked > gdd/goal.md; git add -A; git -c user.email=a@b -c user.name=a commit -qm h; git checkout -q HEAD~1 -- gdd/goal.md; echo hacked2 > gdd/goal.md'

# Bash creating a new goal.md where none existed
mkdir -p new/gdd
json Bash "" | bash "$HOOK" pre
cp gdd/goal.md new/gdd/goal.md
json Bash "" | bash "$HOOK" post 2>/dev/null; rc=$?
check "bash: create new goal.md" 2 "$rc"
[ ! -f new/gdd/goal.md ] || { echo "FAIL bash: new goal.md not removed"; fail=1; }

# Bash read-only and writes elsewhere: must pass
json Bash "" | bash "$HOOK" pre
cat gdd/goal.md > /dev/null; echo x > gdd/state.md.tmp; echo y > notes.md
json Bash "" | bash "$HOOK" post 2>/dev/null; check "bash: read-only / other files" 0 $?

# --- state.md learnings
P="$W/gdd/state.md"
json Edit "$P" | bash "$HOOK" pre
printf '# State\n\n## Now\n\n- b\n\n## Learnings\n\n- keep one\n' > "$P"
json Edit "$P" | bash "$HOOK" post 2>/dev/null; check "state: learning removed -> refused" 2 $?
grep -q "keep two" "$P" || { echo "FAIL state: not restored"; fail=1; }

json Edit "$P" | bash "$HOOK" pre
printf '# State\n\n## Now\n\n- b\n\n## Learnings\n\n- keep one → hardened: hook\n- keep two\n- new three\n' > "$P"
json Edit "$P" | bash "$HOOK" post 2>/dev/null; check "state: learnings kept + suffix + new" 0 $?

PJ="$W/gdd/state-ja.md"; cp "$PJ" "$W/gdd/state.md"
json Edit "$W/gdd/state.md" | bash "$HOOK" pre
printf '# State\n\n## 現状\n\n- b\n\n## 学び\n\n- 学び一\n' > "$W/gdd/state.md"
json Edit "$W/gdd/state.md" | bash "$HOOK" post 2>/dev/null; check "state(ja): 学び removed -> refused" 2 $?

# --- adr.md append-only
A="$W/gdd/adr.md"
json Edit "$A" | bash "$HOOK" pre
printf '\n## 2026-01-02 SG1 y\n\n- Decided: b\n' >> "$A"
json Edit "$A" | bash "$HOOK" post 2>/dev/null; check "adr: append" 0 $?

json Edit "$A" | bash "$HOOK" pre
printf '# ADR\n\n## 2026-01-01 SG0 x\n\n- Decided: CHANGED\n' > "$A"
json Edit "$A" | bash "$HOOK" post 2>/dev/null; check "adr: rewrite -> refused" 2 $?
grep -q "Decided: b" "$A" || { echo "FAIL adr: not restored"; fail=1; }

# --- tests: skip added
T="$W/tests/test_a.py"
json Edit "$T" | bash "$HOOK" pre
printf 'import pytest\n@pytest.mark.skip\ndef test_a():\n    assert 1\n' > "$T"
json Edit "$T" | bash "$HOOK" post 2>/dev/null; check "test: skip added -> refused" 2 $?

json Edit "$T" | bash "$HOOK" pre
printf 'import pytest\n@pytest.mark.skip\ndef test_a():\n    assert 2\n' > "$T"
json Edit "$T" | bash "$HOOK" post 2>/dev/null; check "test: skip unchanged -> ok" 0 $?

# non-test file with 'skip' word must pass
N="$W/notes.md"; json Edit "$N" | bash "$HOOK" pre; echo "it.skip(" > "$N"
json Edit "$N" | bash "$HOOK" post 2>/dev/null; check "non-test file -> ok" 0 $?

# new file via Write (no snapshot) must pass
json Write "$W/gdd/brandnew.md" | bash "$HOOK" pre; echo hi > "$W/gdd/brandnew.md"
json Write "$W/gdd/brandnew.md" | bash "$HOOK" post 2>/dev/null; check "write new file -> ok" 0 $?

echo "workdir: $W"
exit $fail
