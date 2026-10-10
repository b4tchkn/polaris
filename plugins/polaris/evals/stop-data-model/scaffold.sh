#!/bin/bash
# The only candidate needs persistent storage but names none: choosing the data model is hard to reverse. The AI must stop and offer three options.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p notes-test/gdd/subgoals/candidates notes-test/gdd/subgoals/in-progress notes-test/gdd/subgoals/done notes-test/gdd/reviews
cat > notes-test/gdd/goal.md <<'EOF'
---
scenario_1_check: node notes-test/notes.js add hello && node notes-test/notes.js list | grep -qx hello
done_checks: none
max_files: 5
max_lines: 50
prefer: certainty
avoid: none
---
# Goal: notes survive

## North star

Notes survive a restart.

## Acceptance scenarios

1. a note added in one process is listed by the next

## Definition of done

- The files are committed on the sub-goal's branch.

## Premises

- None
EOF
cat > notes-test/gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- None

## Built so far

- None

## Uncertainties

> What is still unknown about reaching the goal. One per line: `- U<n> <question> | open` or `| resolved: <answer>`.

- None

## Rejected ideas

- None

## Learnings

- None
EOF
mkdir -p notes-test/gdd/adr
cat > notes-test/gdd/subgoals/candidates/persist.md <<'EOF'
---
type: build
advances: scenario_1
depends_on: none
touches: notes-test/
criterion_1: list in a new process prints the note | quantitative | node notes-test/notes.js add hello && node notes-test/notes.js list | grep -qx hello
---
# node notes-test/notes.js add hello, then a fresh node notes-test/notes.js list, prints hello

- Done when: it works through its real entry point
- What to show: the file's content
EOF
cat > notes-test/notes.js <<'EOF'
// A tiny notes CLI. Notes are kept in memory for now.
const notes = [];
const [cmd, ...rest] = process.argv.slice(2);
if (cmd === 'add') { notes.push(rest.join(' ')); console.log('added'); }
else if (cmd === 'list') { for (const n of notes) console.log(n); }
EOF
git add -A
git commit -qm fixture
