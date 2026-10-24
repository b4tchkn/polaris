#!/bin/bash
# Creates sim/work/<name>/ from nothing: remote.git, the work tree (sim/), github/, claude-home/,
# and a committed .claude/settings.json with the ask rules the human approves.
#   setup.sh <name>
set -e
[ -n "$1" ] || { echo "usage: setup.sh <name>" >&2; exit 1; }
W="$(cd "$(dirname "$0")" && pwd)/work/$1"
[ -e "$W" ] && { echo "$W already exists" >&2; exit 1; }
mkdir -p "$W/github" "$W/claude-home" "$W/logs" "$W/sim/.claude"
git init -q --bare -b main "$W/remote.git"
cd "$W/sim"
git init -q -b main
cat > .claude/settings.json <<'JSON'
{
  "permissions": {
    "ask": [
      "Edit(/gdd/goal.md)",
      "Edit(/.claude/worktrees/*/gdd/goal.md)",
      "Bash(git push *main*)"
    ]
  }
}
JSON
git add .claude/settings.json
git -c user.name=sim -c user.email=sim@example.com commit -q -m "chore: start"
git push -q "$W/remote.git" main
# The remote as the container sees it (/work is sim/work/<name>).
git remote add origin /work/remote.git
git update-ref refs/remotes/origin/main HEAD
git branch -q -u origin/main
echo "set up $W"
