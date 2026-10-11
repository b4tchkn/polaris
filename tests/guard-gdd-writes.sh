#!/bin/bash
# Self-check for guard-gdd-writes.sh. Prints PASS/FAIL per case; exits 1 on any FAIL.
HOOK="$(cd "$(dirname "$0")/.." && pwd)/plugins/polaris/hooks/guard-gdd-writes.sh"
W=$(mktemp -d "${TMPDIR:-/tmp}/guard-test-XXXX"); cd "$W"
export TMPDIR="$W/tmp"; mkdir -p "$TMPDIR" gdd sub/gdd tests
printf '# Goal: X\n' > gdd/goal.md
mkdir -p gdd/subgoals
printf -- '---\ntype: build\nadvances: scenario_1\n---\n# a\n' > gdd/subgoals/a.md
printf '# Goal: Y\n' > sub/gdd/goal.md
printf '# State\n\n## Now\n\n- a\n\n## Learnings\n\n- keep one\n- keep two\n' > gdd/state.md
printf '# State\n\n## 現状\n\n- a\n\n## 学び\n\n- 学び一\n- 学び二\n' > gdd/state-ja.md
mkdir -p gdd/adr && printf '# 2026-01-01 x\n\n- Decided: a\n' > gdd/adr/2026-01-01-x.md
printf 'def test_a():\n    assert 1\n' > tests/test_a.py

fail=0
check() { # name expected_exit actual_exit
  if [ "$2" = "$3" ]; then echo "PASS $1"; else echo "FAIL $1 (want exit $2, got $3)"; fail=1; fi
}
json() { # tool file_path [cwd] [agent_id]
  printf '{"session_id":"s1",%s%s"tool_name":"%s","tool_input":{"command":"x","file_path":"%s"}}' \
    "${3:+\"cwd\":\"$3\",}" "${4:+\"agent_id\":\"$4\",}" "$1" "$2"
}

# --- Bash writes to goal.md: each must be reverted and refused
bash_case() { # name, command that writes
  json Bash "" | bash "$HOOK" pre
  bash -c "$2" 2>/dev/null
  json Bash "" | bash "$HOOK" post 2>/dev/null; rc=$?
  check "bash: $1" 2 "$rc"
  [ "$(cat gdd/goal.md)" = "# Goal: X" ] || { echo "FAIL bash: $1 goal.md not restored"; fail=1; }
  [ "$(cat sub/gdd/goal.md)" = "# Goal: Y" ] || { echo "FAIL bash: $1 sub goal.md not restored"; fail=1; }
}
bash_case "redirect"        'echo hacked > gdd/goal.md'
bash_case "python open"     'python3 -c "open(\"gdd/goal.md\",\"w\").write(\"hacked\")"'
bash_case "cd then write"   'cd gdd && echo hacked > goal.md'
bash_case "variable path"   'F=gdd/goal.md; echo hacked > $F'
bash_case "glob"            'echo hacked > gdd/go*.md'
bash_case "sed -i"          'sed -i "" "s/X/hacked/" gdd/goal.md'
bash_case "delete"          'rm gdd/goal.md'
bash_case "nested dir"      'echo hacked > sub/gdd/goal.md'
bash_case "git checkout"    'git init -q . 2>/dev/null; git add -A; git -c user.email=a@b -c user.name=a commit -qm i; echo hacked > gdd/goal.md; git add -A; git -c user.email=a@b -c user.name=a commit -qm h; git checkout -q HEAD~1 -- gdd/goal.md; echo hacked2 > gdd/goal.md'

# pre and post from different directories must not treat every file as new (this deleted 10 files once)
export CLAUDE_PROJECT_DIR="$W"
(cd sub && json Bash "" | bash "$HOOK" pre)
json Bash "" | bash "$HOOK" post 2>/dev/null; rc=$?
check "bash: cwd changed between pre and post" 0 "$rc"
[ -f gdd/goal.md ] && [ -f sub/gdd/goal.md ] || { echo "FAIL bash: cwd changed deleted files"; fail=1; }
unset CLAUDE_PROJECT_DIR

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

# --- sub-goal files: `advances:` is required; renames keep content and pass
json Bash "" | bash "$HOOK" pre
mv gdd/subgoals/a.md gdd/subgoals/a2.md
json Bash "" | bash "$HOOK" post 2>/dev/null; check "subgoal: rename -> ok" 0 $?

json Bash "" | bash "$HOOK" pre
printf -- '---\ntype: build\n---\n# b\n' > gdd/subgoals/b.md
json Bash "" | bash "$HOOK" post 2>/dev/null; check "subgoal: bash new file without advances -> refused" 2 $?
[ ! -f gdd/subgoals/b.md ] || { echo "FAIL subgoal: file without advances not removed"; fail=1; }

json Bash "" | bash "$HOOK" pre
printf -- '---\ntype: build\nadvances: U1\n---\n# c\n' > gdd/subgoals/c.md
json Bash "" | bash "$HOOK" post 2>/dev/null; check "subgoal: bash new file with advances -> ok" 0 $?

S="$W/gdd/subgoals/a2.md"
json Edit "$S" | bash "$HOOK" pre
printf -- '---\ntype: build\nadvances:\n---\n# a\n' > "$S"
json Edit "$S" | bash "$HOOK" post 2>/dev/null; check "subgoal: edit empties advances -> refused" 2 $?
grep -q "scenario_1" "$S" || { echo "FAIL subgoal: not restored"; fail=1; }

S2="$W/gdd/subgoals/d.md"
json Write "$S2" | bash "$HOOK" pre
printf '# d\n' > "$S2"
json Write "$S2" | bash "$HOOK" post 2>/dev/null; check "subgoal: write without frontmatter -> refused" 2 $?
[ ! -f "$S2" ] || { echo "FAIL subgoal: new file not removed"; fail=1; }

# --- parallel subagents: agent B's snapshot must not overwrite agent A's
json Bash "" "" agentA | bash "$HOOK" pre
echo hacked > gdd/goal.md
json Bash "" "" agentB | bash "$HOOK" pre
json Bash "" "" agentB | bash "$HOOK" post 2>/dev/null
json Bash "" "" agentA | bash "$HOOK" post 2>/dev/null; check "agents: A's change is caught after B ran" 2 $?
[ "$(cat gdd/goal.md)" = "# Goal: X" ] || { echo "FAIL agents: goal.md not restored"; fail=1; }

# --- a worktree created under .claude/worktrees/ during a Bash command is left alone
json Bash "" | bash "$HOOK" pre
mkdir -p .claude/worktrees/w1/gdd && printf '# Goal: X\n' > .claude/worktrees/w1/gdd/goal.md
json Bash "" | bash "$HOOK" post 2>/dev/null; check "worktree: new worktree copy of goal.md is not removed" 0 $?
[ -f .claude/worktrees/w1/gdd/goal.md ] || { echo "FAIL worktree: worktree goal.md removed"; fail=1; }

# --- worktree: the root is the git root of cwd, not CLAUDE_PROJECT_DIR
WT=$(mktemp -d "${TMPDIR}/wt-XXXX"); mkdir -p "$WT/gdd" "$WT/src"; printf '# Goal: WT\n' > "$WT/gdd/goal.md"
git -C "$WT" init -q
export CLAUDE_PROJECT_DIR="$W/sub"
json Bash "" "$WT/src" | bash "$HOOK" pre
echo hacked > "$WT/gdd/goal.md"
json Bash "" "$WT/src" | bash "$HOOK" post 2>/dev/null; check "worktree: goal.md under cwd's git root is guarded" 2 $?
[ "$(cat "$WT/gdd/goal.md")" = "# Goal: WT" ] || { echo "FAIL worktree: goal.md not restored"; fail=1; }
unset CLAUDE_PROJECT_DIR

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

# --- gdd/adr/: new files are fine, existing ones never change
A="$W/gdd/adr/2026-01-02-y.md"
json Write "$A" | bash "$HOOK" pre
printf '# 2026-01-02 y\n\n- Decided: b\n' > "$A"
json Write "$A" | bash "$HOOK" post 2>/dev/null; check "adr: new file" 0 $?

json Edit "$A" | bash "$HOOK" pre
printf '# 2026-01-02 y\n\n- Decided: CHANGED\n' > "$A"
json Edit "$A" | bash "$HOOK" post 2>/dev/null; check "adr: edit existing -> refused" 2 $?
grep -q "Decided: b" "$A" || { echo "FAIL adr: not restored"; fail=1; }

json Bash "" | bash "$HOOK" pre
rm "$A"; printf '# z\n' > gdd/adr/2026-01-03-z.md
json Bash "" | bash "$HOOK" post 2>/dev/null; check "adr: bash delete existing -> refused" 2 $?
[ -f "$A" ] && [ -f gdd/adr/2026-01-03-z.md ] || { echo "FAIL adr: delete not restored or new file removed"; fail=1; }

# --- tests: skip added
T="$W/tests/test_a.py"
json Edit "$T" | bash "$HOOK" pre
printf 'import pytest\n@pytest.mark.skip\ndef test_a():\n    assert 1\n' > "$T"
json Edit "$T" | bash "$HOOK" post 2>/dev/null; check "test: skip added -> refused" 2 $?

grep -q skip "$T" && { echo "FAIL test: skip not restored"; fail=1; }
printf 'import pytest\n@pytest.mark.skip\ndef test_a():\n    assert 1\n' > "$T"
json Edit "$T" | bash "$HOOK" pre
printf 'import pytest\n@pytest.mark.skip\ndef test_a():\n    assert 2\n' > "$T"
json Edit "$T" | bash "$HOOK" post 2>/dev/null; check "test: skip unchanged -> ok" 0 $?

printf 'def test_a():\n    assert 1\n\ndef test_b():\n    assert 1\n' > "$T"
json Edit "$T" | bash "$HOOK" pre
printf 'def test_a():\n    assert 1\n' > "$T"
json Edit "$T" | bash "$HOOK" post 2>/dev/null; check "test: test removed by Edit -> refused" 2 $?
grep -q test_b "$T" || { echo "FAIL test: removed test not restored"; fail=1; }

J="$W/tests/list.test.js"; printf "test('a', () => {})\n" > "$J"
json Edit "$J" | bash "$HOOK" pre
printf "test('a', () => {})\ntest('b', () => {})\n" > "$J"
json Edit "$J" | bash "$HOOK" post 2>/dev/null; check "test: test added -> ok" 0 $?

# --- Bash deleting a test file is restored from git; moving one is fine
git add -A >/dev/null 2>&1; git -c user.email=a@b -c user.name=a commit -qm t >/dev/null 2>&1
json Bash "" | bash "$HOOK" pre
rm tests/test_a.py
json Bash "" | bash "$HOOK" post 2>/dev/null; check "test: bash delete -> refused" 2 $?
[ -f tests/test_a.py ] || { echo "FAIL test: deleted test not restored"; fail=1; }
json Bash "" | bash "$HOOK" pre
mkdir -p tests/unit && git mv tests/test_a.py tests/unit/test_a.py
json Bash "" | bash "$HOOK" post 2>/dev/null; check "test: bash move -> ok" 0 $?

# non-test file with 'skip' word must pass
N="$W/notes.md"; json Edit "$N" | bash "$HOOK" pre; echo "it.skip(" > "$N"
json Edit "$N" | bash "$HOOK" post 2>/dev/null; check "non-test file -> ok" 0 $?

# new file via Write (no snapshot) must pass
json Write "$W/gdd/brandnew.md" | bash "$HOOK" pre; echo hi > "$W/gdd/brandnew.md"
json Write "$W/gdd/brandnew.md" | bash "$HOOK" post 2>/dev/null; check "write new file -> ok" 0 $?

echo "workdir: $W"
exit $fail
