#!/bin/bash
# Self-check for gdd-status.sh. Prints PASS/FAIL per case; exits 1 on any FAIL.
S="$(cd "$(dirname "$0")/.." && pwd)/plugins/polaris/skills/gdd-loop/scripts/gdd-status.sh"
W=$(mktemp -d "${TMPDIR:-/tmp}/status-test-XXXX"); cd "$W"
export GIT_AUTHOR_NAME=a GIT_AUTHOR_EMAIL=a@b GIT_COMMITTER_NAME=a GIT_COMMITTER_EMAIL=a@b
git init -q -b main . && git commit -q --allow-empty -m init
mkdir -p gdd/subgoals gdd/reviews bin
printf -- '---\nmode: careful\n---\n# Goal: t\n' > gdd/goal.md
sg() { # slug depends touches [status]
  printf -- '---\nstatus: %s\ntype: build\nadvances: capture\ndepends_on: %s\ntouches: %s\n---\n# %s\n' "${4:-todo}" "$2" "$3" "$1" > "gdd/subgoals/$1.md"
}
work() { # slug branch: the commit setting done, carrying the sub-goal line, on its own branch
  git switch -q -c "$2"
  git commit -q --allow-empty -m "feat: $1" -m "Sub-goal: gdd/subgoals/$1.md"
  git switch -q main
}
review() { # slug loop progress
  printf -- '---\nsubgoal: %s\nloop: %s\nprogress: %s\n---\n' "$1" "$2" "$3" > "gdd/reviews/$1.md"
}
fail=0
has() { if printf '%s\n' "$out" | grep -qF -- "$2"; then echo "PASS $1"; else echo "FAIL $1: no '$2' in:"; printf '%s\n' "$out"; fail=1; fi; }

# Without a remote, `done` comes from the file and in-review from the commit on a branch.
sg base none src/base/ done
sg cur none src/cur/; work cur w1
sg indep none src/other/
sg dep base src/x/
sg waits cur src/y/
sg clash none src/cur/sub/
out=$(bash "$S" gdd)
has "done is listed once"                         "done: base "
has "no remote: commit off HEAD is in review"      "cur state=in-review type=build advances=capture branch=w1"
has "ready: no deps"                               "indep state=todo type=build advances=capture ready=yes"
has "ready: dependency merged"                     "dep state=todo type=build advances=capture ready=yes"
has "ready: dependency not merged"                 "ready=no ( cur in-review )"
has "overlap: shared path prefix"                  "clash state=todo type=build advances=capture ready=yes overlaps=[cur ]"
has "no hold"                                      "hold: no"
printf '%s\n' "$out" | grep -q '^  base ' && { echo "FAIL done sub-goal listed in detail"; fail=1; }
sg old none src/o/ cancelled; out=$(bash "$S" gdd)
has "cancelled is listed once"                     "cancelled: old "
printf '%s\n' "$out" | grep -q '^  old ' && { echo "FAIL cancelled sub-goal listed in detail"; fail=1; }
rm gdd/subgoals/old.md

# With a remote, states come from pull requests found by their "Sub-goal:" line (gh is faked).
git remote add origin https://example.invalid/r.git
printf '#!/bin/bash\n[ -f "%s/gh-fails" ] && exit 1\ncat "%s/prs.tsv"\n' "$W" "$W" > bin/gh; chmod +x bin/gh
export PATH="$W/bin:$PATH"
sg rev none src/rev/; sg late none src/late/; sg after late src/z/; sg near none src/rev/a/
printf '%s\t%s\t%s\n' \
  gdd/subgoals/rev.md OPEN https://example.invalid/pr/1 \
  gdd/subgoals/late.md MERGED https://example.invalid/pr/2 \
  gdd/subgoals/base.md MERGED https://example.invalid/pr/3 \
  gdd/subgoals/gone.md CLOSED https://example.invalid/pr/4 > prs.tsv
out=$(bash "$S" gdd)
has "pr: open"                          "rev state=in-review type=build advances=capture pr=https://example.invalid/pr/1"
has "pr: merged and pulled (file done)"  "done: base "
has "pr: merged but not pulled"         "late state=merged-not-pulled"
has "ready: dependency not pulled"      "ready=no ( late merged-not-pulled )"
has "overlap: open pull request"        "near state=todo type=build advances=capture ready=yes overlaps=[rev ]"
touch gh-fails; out=$(bash "$S" gdd 2>&1); code=$?; rm gh-fails
has "gh fails: tells how to fix it"     "install the GitHub CLI"
[ "$code" = 1 ] && echo "PASS gh fails: exit 1" || { echo "FAIL gh fails: exit $code"; fail=1; }

review r1 2 p; review r2 3 p
out=$(bash "$S" gdd); has "two equal reviews: not stalled" "stalled: no"
review r3 4 p
out=$(bash "$S" gdd); has "three equal reviews: stalled" "stalled: yes"
has "stall holds" "hold: yes ( stalled; )"
review r4 5 q; sg gone none src/gone/
out=$(bash "$S" gdd); has "closed pull request holds" "hold: yes ( a pull request was closed; )"
rm gdd/subgoals/gone.md
out=$(bash "$S" gdd); has "deleting the closed sub-goal releases the hold" "hold: no"

echo "workdir: $W"
exit $fail
