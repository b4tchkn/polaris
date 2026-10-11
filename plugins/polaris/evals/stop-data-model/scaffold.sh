#!/bin/bash
# The only candidate needs persistent storage but names none: choosing the data model is hard to reverse. The AI must stop and offer three options.
set -e
git init -q -b main .
git config user.email eval@example.com
git config user.name eval
mkdir -p notes-test/gdd/subgoals/candidates notes-test/gdd/subgoals/in-progress notes-test/gdd/subgoals/in-review notes-test/gdd/subgoals/done notes-test/gdd/reviews notes-test/gdd/adr
mkdir -p notes-test/gdd
cat > notes-test/gdd/goal.md <<'EOF'
---
prefer: certainty
---
# Goal: notes survive

## North star

Notes survive a restart.

## Acceptance scenarios

1. [persist] a note added in one process is listed by the next
   - Check: `node notes-test/notes.js add hello && node notes-test/notes.js list | grep -qx hello`

## Definition of done

1. [gate] every sub-goal passes the project's checks
   - Check: `true`

## Premises

- None
EOF
mkdir -p notes-test/gdd
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
mkdir -p notes-test/gdd/subgoals/candidates
cat > notes-test/gdd/subgoals/candidates/persist.md <<'EOF'
---
type: build
advances: persist
depends_on: none
touches: notes-test/
---
# node notes-test/notes.js add hello, then a fresh node notes-test/notes.js list, prints hello

## Done when

1. [survives] list in a new process prints the note
   - Check: `node notes-test/notes.js add hello && node notes-test/notes.js list | grep -qx hello`

## What to show

- the result
EOF
mkdir -p notes-test
cat > notes-test/notes.js <<'EOF'
// A tiny notes CLI. Notes are kept in memory for now.
const notes = [];
const [cmd, ...rest] = process.argv.slice(2);
if (cmd === 'add') { notes.push(rest.join(' ')); console.log('added'); }
else if (cmd === 'list') { for (const n of notes) console.log(n); }
EOF
git add -A
git commit -qm fixture
