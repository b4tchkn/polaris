---
type: <build | decide>
advances: <acceptance scenarios and uncertainties this moves forward, e.g. scenario_1, U2>
depends_on: <slugs of sub-goals that must be done and merged first, or none>
touches: <paths this changes, comma-separated, e.g. src/signup/, docs/>
criterion_1: <what is measured> | quantitative | <shell command that exits 0 when met>
criterion_2: <what the human judges> | qualitative
---
# <What this sub-goal achieves, in one sentence>

- Done when: <Decide: the human agrees on a spec, approach, or scope. Build: it works through its real entry point>
- What to show: <What the human looks at to decide>
