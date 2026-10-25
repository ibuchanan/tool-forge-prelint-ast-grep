# 18: Offer advisory coverage for the seeded TODO workflow

**What to build:** Forge app owners can discover missing or inert TODO tooling as optional seed-convention advice, without having their intentionally customized or removed workflow treated as a broken Drop Calf installation.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** completed

**Capability:** todo

**Coverage today:** No consumer rule checks scripts.todo. General placeholder rules intentionally do not cover this owner-managed entrypoint.

**Source convention:** Drop Calf seeds a tracked-file Git grep command with line numbers and literal text matching. The generated command assembles the TODO token to avoid matching itself, treats no matches as success, and preserves real error exit status. Update deliberately neither replaces nor re-adds this script; it is owner-managed after init.

- [x] Add a narrowly advisory rule for absent/non-string/obviously inert root scripts.todo, tagged `capability:todo`; clearly state that this is a seeded convenience rather than an enforced update policy and document intentional-removal suppression.
- [x] Accept the exact generated command, including split token quoting and its no-match handling. Accept nonempty owner-authored alternatives without pretending the matcher can prove they implement identical grep/exit semantics.
- [x] Do not enforce a particular command string, fixed quote style, presence of TODO markers, a ban on TODO comments, or automatic ticket creation. Never match generic todos merely to increase diagnostics.
- [x] Add passing generated/custom-script examples and failing missing/non-string/inert/metadata-nested examples. Use a low-consequence reviewed assessment under the severity matrix; do not promote this into a deployment blocker.
- [x] Explain that tracked-file membership, no-match exit handling and actual Git errors are beyond the generic script-presence check. No Git invocation or repository mutation is needed for static-rule verification.

**Boundary:** If maintainers prefer to leave seed-only absence entirely unchecked, a reviewed metadata/coverage-gap disposition is preferable to mandatory exact enforcement. The shared definition of done applies.

## Completion update — 2026-10-25

- Selected by dependency order: 01 was complete; 18 was the lowest-numbered ready ticket. Confirmed the source checkout remains at `be86d05309a32f7eef8988205208c17ca94e7a4c`.
- Added `prefer-todo-script`, an ecosol `hint` with reviewed low precision/low impact and `capability:todo`. It checks only a direct root `scripts.todo` string; absent, non-string, blank and bounded standalone inert forms receive one optional hint. Exact generated text, custom commands, quote styles, environment assignments and logging-first chains are accepted.
- The note and capability reference distinguish seed-only convenience from update policy, document `--off=prefer-todo-script` for intentional removal, and explicitly exclude shell semantics, tracked-file membership, marker presence, no-match handling and Git error validation. No owner TODO command, grep process or automatic ticket creation was run for verification.
- TDD red → green: a real scan of the generated package with `scripts.todo` removed first lacked the expected advisory (`.scratch/tmp_rovo_ticket18_missing_behavior_red.log`), then produced one metadata-bearing hint (`.scratch/tmp_rovo_ticket18_missing_green.json`). Next, the inert echo regression failed before its bounded screen (`.scratch/tmp_rovo_ticket18_inert_red.log`) and passed afterward (`.scratch/tmp_rovo_ticket18_inert_green.log`).
- Extended coverage to 9 valid and 31 invalid examples, generated-package mutations, native basename/directory/test/tier routing, capability discovery, the error-only gate and explicit suppression. All 31 invalid cases have snapshots; valid cases are checked directly, not snapshotted.
- Updated only the legacy zero-findings fixture with the seeded TODO declaration; the stored Drop Calf snapshot remains unchanged. The legacy fixture first demonstrated the expected new hint (`.scratch/tmp_rovo_ticket18_legacy_red.log`).
- Validation passed: 213 consumer rule suites; the full fixture suite including all 213 native routing definitions; the full authoring, metadata, severity, scope-composition and package-boundary suite (final exit 0); repository-wide Prettier; `shellcheck -x`; `shfmt -d`; and `git diff --check`. Final isolated mutations, nonblocking and opt-out checks passed (`.scratch/tmp_rovo_ticket18_optout_green.log`).
- Fresh evidence: `.scratch/tmp_rovo_ticket18_rules.log`, `.scratch/tmp_rovo_ticket18_fixtures.log`, `.scratch/tmp_rovo_ticket18_authoring_final.log`, `.scratch/tmp_rovo_ticket18_authoring_final.status` and `.scratch/tmp_rovo_ticket18_format.log`.
- Independent review found no rule or acceptance defects. Its proposed snapshot blocker was rejected after checking the harness: 31 snapshots exactly cover the 31 invalid cases, and all 9 valid cases execute successfully.
- Delivery: this ticket update is included in the same Conventional Commit as the rule and regressions; the commit's file history is the delivery reference.
