# sim

Runs polaris in headless Claude Code inside Docker, against a local remote and a fake `gh`.

1. Put an OAuth token in `sim/.oauth-token` (`claude setup-token`; gitignored, copied into worker worktrees by `.worktreeinclude`).
2. `bash sim/smoke.sh` builds the `polaris-sim` image, recreates `sim/work/smoke/` with `setup.sh`, and runs `/polaris:gdd-init` there.
3. For a scenario: `bash sim/setup.sh <name>`, then steps with `SIM=<name> bash sim/run.sh <log> <prompt> [session id]`. Approve ask rules with `approve.sh`, answer questions by resuming the session. `sh.sh` runs the human's commands (`sim-merge <n>`, `sim-close <n>`).
4. The scenario writes `sim/work/<name>/subgoals.txt`, and `bash sim/verify.sh <name>` judges the run.

Scenarios: `bash sim/parallel/run.sh` (three independent sub-goals in `sim/parallel/repo/`, built by parallel workers, merged by the scripted human), then `bash sim/verify.sh parallel`.
