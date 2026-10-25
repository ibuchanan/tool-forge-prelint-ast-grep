# 13: Map existing Vitest conventions to the test capability

**What to build:** A Forge app's existing one-shot, watch, coverage and explicit-import test conventions are discoverable together through `capability:test` without duplicating checks or confusing the capability name with the test runner.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** completed (2026-10-25).

**Capability:** test

**Coverage today:** Reuse `require-vitest-run-script`, `require-vitest-coverage-script`, `use-explicit-vitest-watch` and `require-vitest-globals-false`. These already represent the selected Forge testing convention. Use the exact tag capability:test, not capability:vitest.

**Source convention:** The forge-app profile uses Vitest, unlike profiles that use Bun's runner. Maintained scripts run once, watch explicitly, and run once with coverage; current generated commands add passWithNoTests. Vitest and its matching V8 coverage provider are seeded, and globals false/V8 coverage/exclusions are owner-managed configuration. No sample test or coverage threshold is promised.

- [x] Add `capability:test` to the four existing rule definitions, preserving IDs, tiers, native scope, ratings, severity and any existing tags. Prefer this metadata-only slice over additional rules for already-covered behavior.
- [x] Retain accepted one-shot and coverage commands without forcing the optional passWithNoTests flag or its ordering. Keep watch flags out of the default noninteractive test script and allow the explicit watch entrypoint.
- [x] Verify current generated scripts and globals configuration pass, and existing watch/coverage/global misuse examples still produce the same findings and snapshots.
- [x] Describe provider version alignment and actual coverage initialization as native-tool/dependency evidence, not something the script matcher proves. Do not hard-code current Vitest versions, require sample tests, or invent coverage percentages.
- [x] Preserve owner-managed configuration: seed V8 provider and exclusion choices may be documented as defaults, not silently promoted to mandatory policy. Verify authoring checks and capability-tag discovery.

**Boundary:** The tag maps the convention, not successful test execution, test quality, or presence of tests. No model evaluations are included. The shared definition of done applies.

## Implementation update — 2026-10-25

Selected by dependency order: blocker 01 and tickets 02–12 are complete, making
13 the lowest-numbered unfinished ready ticket. The user approved the existing
capability-report, matcher/snapshot and native fixture/routing seams.

### Source and implementation

Reviewed Drop Calf at `be86d05309a32f7eef8988205208c17ca94e7a4c`, including
`src/capabilities/vitest.ts`, `tests/capabilities/vitest.test.ts` and the Vitest
seed template. Forge-app selects `vitestTesting()` with capability name `test`.

Added exactly `capability:test` to the four existing rules. No matcher, ID, tier,
native scope, message, note, precision/impact rating, severity or consumer snapshot
changed. A parsed baseline/current comparison excluding only `metadata.tags`
confirmed all remaining definition fields are identical. The default test rule
remains warning severity; the other three remain informational.

The capability reference documents maintained command literals, optional
`--passWithNoTests`, owner-managed provider/exclusion choices, suppression for
equivalent owner workflows, bounded command/config matching and native validation
responsibilities. No dependencies, versions, generated fixtures, sample tests,
coverage thresholds or additional rules were introduced. Seeded V8 and exclusions
are not promoted to mandatory settings. Provider alignment, discovery and coverage
initialization remain native-tool/dependency evidence, not static matcher claims.

### Red → green evidence

1. Added a literal public capability-report assertion for the four existing IDs.
   It failed with `test\tnot-mapped` (exit 1), then passed (exit 0) after the four
   additive tags. Evidence: `.scratch/tmp_rovo_ticket13_mapping_red.log` and
   `.scratch/tmp_rovo_ticket13_mapping_green.log`.
2. Existing matcher/snapshot suites passed before and after the metadata change:
   four suites, 36 valid/invalid cases, with no snapshot updates. Evidence:
   `.scratch/tmp_rovo_ticket13_focused.log`.
3. Added native static fixture characterization to `scripts/check-fixtures.sh`:
   seven package variants cover generated scripts, no optional flag, reordered
   coverage/no-tests flags, a watch-mode default, implicit watch, missing coverage
   and disabled coverage. Four config variants cover the generated config,
   owner-selected Istanbul/exclusions, globals enabled and missing explicit globals.
   Findings assert exact existing rule IDs and capability tags. These characterize
   preserved behavior; the report assertion supplies the red → green behavior.

### Validation

All validation exited successfully:

- `ast-grep test --test-dir rule-tests`: all 210 consumer suites and unchanged
  snapshots. Evidence: `.scratch/tmp_rovo_ticket13_full_rules.log`.
- `sh scripts/check-fixtures.sh`: generated/static fixtures, security fixtures,
  210 native definitions across four shipped tiers and page-title diagnostics.
  Evidence: `.scratch/tmp_rovo_ticket13_fixtures.log`.
- `bash scripts/test-authoring.sh`: authoring/value/metadata checks, capability
  discovery, scope composition, severity matrix and consumer gates, plus packed
  package boundaries. Evidence: `.scratch/tmp_rovo_ticket13_full_authoring.log`.
- The three preceding commands cover the standard package test pipeline without
  invoking its nested npm runner or repeating the expensive routing matrix.
- `shellcheck -x scripts/check-fixtures.sh scripts/test-capability-coverage.sh`,
  `shfmt -d` on both scripts, `git diff --check` and repository-wide
  `bun run format:check` passed. Formatting evidence:
  `.scratch/tmp_rovo_ticket13_format.log`.
- Independent read-only review found no blocking acceptance or correctness issues.
  Tests observe report and scanner output rather than private implementation.

No generated package test/watch/coverage task, native Vitest initialization,
installation, secret resolution, deployment, release or hook is executed as static
rule evidence. The final Git commit is the user's explicitly requested delivery
action and includes this tracked local ticket update. Ticket 14 is next under
lowest-numbered dependency-ready ordering.
