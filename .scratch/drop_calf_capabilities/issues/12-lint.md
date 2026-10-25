# 12: Map and verify independent lint and check aggregates

**What to build:** Forge apps get consistent feedback when aggregate script wiring stops selecting intended read-only checks, and authors can find the existing orchestration rules through `capability:lint` independently of Git hook setup.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** completed

**Capability:** lint

**Coverage today:** `require-composed-lint` and `require-composed-check` recognize direct run-p commands, but deliberately do not validate task coverage. `no-write-flags-in-readonly-script` already covers the lint:check namespace in the working tree. Existing task-presence rules belong to the capabilities supplying those tasks.

**Source convention:** The lint capability owns the runner dependency and aggregates. Lint runs the lint:check:* namespace with npm selected and labeled output. Check runs the lint, test, size:check and pack:check selection in parallel independently of Lefthook. Forge-app does not select the package-check capability, so an absent pack:check declaration is not by itself a convention failure; preserve the runner's optional-pattern behavior.

- [x] Add `capability:lint` to both composition rules and the shared read-only guard, preserving any capability:biome mapping appended by ticket 11.
- [x] Add focused same-package task-selection coverage for the generated lint:check glob and complete explicit equivalents. Diagnose a bare run-p command that omits all intended lint tasks rather than treating any argument as full composition compliance; avoid a general shell/glob interpreter.
- [x] Check literal self-selection and inclusion of known write-back tasks in the aggregate where same-file command text proves it; keep supported equivalent explicit task lists and flag ordering. If a richer selection cannot be established from literal text, document the gap rather than invent completeness.
- [x] Accept the current generated check brace pattern without requiring pack:check to exist in forge-app, and test absent optional task behavior through static fixtures/documented runner evidence. Do not require lint:docs to be selected: Drop Calf currently keeps that task outside lint:check:*.
- [x] Keep aggregates independent of Lefthook and avoid moving the package scripts back to hook delegation. Tag-only changes preserve snapshots; intentional matcher changes receive new positive/negative tests and reviewed ratings.

**Boundary:** Individual tool dependencies and tasks are owned by their provider tickets. This ticket checks same-file wiring only, not execution success, shell expansion in arbitrary wrappers or cross-file app identity. The shared definition of done applies.

## Implementation update — 2026-10-25

Selected in dependency order: blocker 01 and tickets 02–11 are complete, so
12 is the lowest-numbered unfinished ready ticket. The user approved the public
capability-report, rule-diagnostic and native package scanner/fixture seams.

### Source and implementation

Reviewed the external Drop Calf checkout at
`be86d05309a32f7eef8988205208c17ca94e7a4c`, including
`src/capabilities/lint.ts`, `tests/capabilities/lint.test.ts` and
`tests/e2e/lint.e2e.test.ts`. The pinned runner tests distinguish optional unmatched
patterns from failing missing literal tasks; the generated check brace pattern is
valid when `pack:check` is absent. No aggregate was executed to establish this.

Added `capability:lint` to the two existing composition rules and the shared
read-only guard. Preserved `capability:biome` and documented the shared relationship.
No rule IDs, tier configurations, native filename scopes or dependencies changed.

The existing composition matchers now require recognizable read-only selections,
not merely any argument following `run-p`. Bounded same-root-`scripts` checks cover
omitted declared standard `lint:check:prelint/biome/forge/format/typecheck` producers
and `lint/test/size:check/pack:check` workflows. Generated patterns and complete
explicit lists pass with varying flag order, ordinary spacing and quote styles.
No absent provider task is required; `lint:docs` remains separate.

Literal self-selection, conventional `:fix` selections and `lint:*` are rejected.
Selecting `format` is rejected when its same-file command contains write/fix flags;
unselected write-back tasks and a read-only owner `format` override remain valid.
The shared guard's matcher, warning severity and snapshot are unchanged.

Both composition rules retain reviewed medium precision, low impact and info
severity: alternate complete orchestration is not inherently unsafe. Updated
messages, notes and precision rationales describe the new evidence and suppression
boundary. Arbitrary producer names, richer glob/brace equivalence, option-argument
roles, inert text, JSON escape spellings, aliases/wrappers, indirect mutation,
execution success and cross-file app identity remain explicit assessment gaps.
No finding is not a completeness or successful-execution guarantee.

The coverage reference records the pinned convention and these limits. Native
fixtures apply only pinned aggregate/producer wiring to temporary copies of the
older generated snapshot. Stored snapshots of generated applications, hooks,
individual provider rules and generator code are untouched. Only the two
intentionally changed composition-rule diagnostic snapshots were updated.

### Red → green evidence

1. Added a public capability-discovery assertion for exactly the three lint IDs.
   It failed with `lint\tnot-mapped` (exit 1), then passed after additive tags.
   Evidence: `.scratch/tmp_rovo_ticket12_mapping_red.log` and
   `.scratch/tmp_rovo_ticket12_mapping_green.log`.
2. A flags-only lint command was incorrectly accepted (exit 4). Requiring an
   intended lint-family task token made the focused suite pass. Evidence:
   `.scratch/tmp_rovo_ticket12_lint_red.log` and
   `.scratch/tmp_rovo_ticket12_lint_green.log`.
3. A partial explicit lint list omitted a declared Prelint producer (exit 4).
   Same-file declaration/selection checks, then equivalent cases for the remaining
   standard producers, made the expanded suite pass. Evidence:
   `.scratch/tmp_rovo_ticket12_omission_red.log` and
   `.scratch/tmp_rovo_ticket12_producers_green.log`.
4. A flags-only check command was accepted (exit 4), then rejected by requiring
   recognizable verification selections. Evidence:
   `.scratch/tmp_rovo_ticket12_check_red.log` and
   `.scratch/tmp_rovo_ticket12_check_green.log`.
5. Omitting declared lint, test, size or package checks failed the new tests
   (exit 4). Same-file coverage checks passed them without requiring absent
   optional tasks. Evidence: `.scratch/tmp_rovo_ticket12_workflows_red.log` and
   `.scratch/tmp_rovo_ticket12_workflows_green.log`.
6. Literal self-selection and known write-back selection cases initially escaped
   both rules (exit 4), then passed after bounded unsafe-selection checks.
   Evidence: `.scratch/tmp_rovo_ticket12_unsafe_red.log` and
   `.scratch/tmp_rovo_ticket12_unsafe_green.log`.
7. Additional characterization checks cover token suffix lookalikes, unrelated
   tasks, nested lookalikes, generated optional brace forms, read-only owner
   overrides, unselected mutations and unchanged hook-delegation diagnostics.
   Evidence: `.scratch/tmp_rovo_ticket12_boundaries.log`.

### Validation

- Focused rule tests plus reviewed snapshot updates: all 3 suites passed;
  `.scratch/tmp_rovo_ticket12_snapshots.log`.
- All consumer rule suites and snapshots: 210 passed, zero failures;
  `.scratch/tmp_rovo_ticket12_full_rules.log` (`RULE_TEST_EXIT=0`).
- `sh scripts/check-fixtures.sh`: passed, including 14 native lint variants,
  exact diagnostic IDs/tags/severities, optional pack absent/present, existing
  security cases, all 210 definition routes across four tiers and page-title gates;
  `.scratch/tmp_rovo_ticket12_fixtures.log` (`FIXTURE_EXIT=0`).
- `bash scripts/test-authoring.sh`: passed, including values, metadata recipes,
  capability discovery (Biome preserved), scope composition, severity matrices,
  consumer gates, enforcement and packed-package boundaries;
  `.scratch/tmp_rovo_ticket12_full_authoring.log` (`AUTHORING_TEST_EXIT=0`).
- Explicit authoring checks for changed definitions passed;
  `.scratch/tmp_rovo_ticket12_authoring.log`.
- Repository-wide `bun run format:check`, ShellCheck, shfmt and `git diff --check`
  passed; `.scratch/tmp_rovo_ticket12_format_check.log`.
- Independent correctness review found no blockers; tests observe public report
  and scanner behavior with literal expected outcomes, not internal helpers.

No generated aggregate, formatter/linter, Forge command, secret resolution,
release, deployment or hook was executed as static-rule test evidence. The final
Git commit and its normal repository pre-commit formatting hook are the user's
explicitly requested delivery action. The final status check confirmed this
specific scratch ticket is tracked; its completion record is included in the same
local commit as the implementation. No other scratch artifacts are staged. The
commit body identifies local ticket 12; no Jira issue was invented.
