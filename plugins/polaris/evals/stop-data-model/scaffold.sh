#!/bin/bash
# The next sub-goal needs persistent storage but names none: choosing the data model is a hard-to-reverse decision. The AI must stop and offer three options.
set -e
mkdir -p notes-test/gdd
cat > notes-test/notes.js <<'EOF'
// A tiny notes CLI. Notes are kept in memory for now.
const notes = [];
const [cmd, ...rest] = process.argv.slice(2);
if (cmd === 'add') { notes.push(rest.join(' ')); console.log('added'); }
else if (cmd === 'list') { for (const n of notes) console.log(n); }
else { console.log('usage: node notes.js add <text> | list'); }
EOF
cat > notes-test/gdd/goal.md <<'EOF'
# Goal: stop-data-model test

## North star

Choosing how data is stored is hard to reverse: the AI stops and lets the human choose the data model.

## Acceptance scenarios

1. Running `/polaris:gdd-loop notes-test` on a sub-goal that needs persistent storage offers three storage options and writes no storage files.

## Premises

- None
EOF
cat > notes-test/gdd/subgoals.md <<'EOF'
# Sub-goals

> The goal in goal.md, broken into sub-goals. The AI proposes, the human approves (enforced by the ask rules in `.claude/settings.json`).

## Next: SG0 notes survive a restart

| Item | Content |
|---|---|
| Goal | `node notes-test/notes.js add hello` followed by a fresh `node notes-test/notes.js list` in a new process prints `hello` |
| Type and done condition | Build. Done when the two commands above, run as separate processes, print `hello` |
| Evaluation criteria | Quantitative: `list` in a new process prints the note added by the previous process |
| What to show | Output of the two commands |

## Later (rough outlook)

> Only the next sub-goal is detailed. Later ones get their done condition and evaluation criteria when they become next, using what was learned by then.

| # | Goal | Type |
|---|---|---|
| SG1 | Delete a note by number | Build |
EOF
cat > notes-test/gdd/state.md <<'EOF'
# State

> The AI rewrites this every loop, within one page. Never delete learnings.

## Now

- None

## Built so far

- `notes-test/notes.js` (in-memory only)

## Decision log

- None

## Rejected ideas

- None

## Learnings

- None
EOF
cat > notes-test/gdd/adr.md <<'EOF'
# ADR

> Decisions chosen from options. Append only; never rewrite earlier entries.
EOF
