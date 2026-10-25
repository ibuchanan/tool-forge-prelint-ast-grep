# 10: Map current Prelint tasks and complete scan exclusion coverage

**What to build:** The current namespaced Prelint workflow is discoverable by capability and checked without duplicating the already-updated lint rules or allowing scans to traverse dependencies and specifications accidentally.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** completed (2026-10-25).

**Capability:** prelint

**Coverage today:** The current working tree already updates `lint-with-prelint`, `lint-with-forge`, `require-valid-prelint-config` and `require-prelint-node-modules-glob` for lint:check names. Companion config/glob rules retain legacy-name validation. Do not recreate this work or revert it to the vendored generator. There is no equivalent explicit specs exclusion check.

**Source convention:** The capability maintains lint:check:prelint as an ast-grep scan excluding specs and node_modules with a shipped ecosol config under the installed Prelint dependency. It also supplies lint:check:forge. Dependency keys can differ across supported installations; the scan aggregate belongs to lint, not prelint.

- [x] Add `capability:prelint` to the four existing rule definitions. Keep `capability:forge-manifest` on the Forge task if ticket 06 has already appended it, and otherwise permit that later additive mapping.
- [x] Preserve the already-tested current task names, accepted shipped-tier config paths, package aliases and legacy config/glob validation. Do not hard-code the installation folder to one dependency name or require current dependency versions.
- [x] Add a bounded check for the specifications exclusion on the existing Prelint scan task, or extend the existing glob rule without duplicating diagnostics. Distinguish missing specs exclusion from missing dependency exclusion and use an actionable message.
- [x] Verify the exact generated command passes and missing config, wrong config, missing node_modules exclusion and missing specs exclusion mutations fail the relevant rule. Avoid imposing scan flags on unrelated scripts.
- [x] Keep config existence, actual installed tools, scan execution and project-wide coverage out of the matcher claims; preserve metadata and scope checks and update only intentionally affected snapshots.

**Boundary:** Ticket 09 resolves the independent direct Forge lint versus Fence Rider preference. This ticket must not silently change that policy. The shared definition of done applies.

## Implementation update — 2026-10-25

Selected in dependency order: ticket 01 and tickets 02–09 are complete, making
10 the lowest-numbered ready ticket. The user approved the ticket's matcher,
capability-discovery and native fixture/routing seams.

### Source and implementation

Reviewed the external Drop Calf checkout at
`be86d05309a32f7eef8988205208c17ca94e7a4c`, including
`src/capabilities/prelint.ts` and `tests/capabilities/forge-prelint.test.ts`.
The capability maintains the two `lint:check:prelint`/`lint:check:forge` tasks;
lint owns their aggregate. Tests copy the two exact pinned command literals
into a temporary generated-package copy, never execute them.

Added `capability:prelint` to the three previously untagged existing rules;
`lint-with-forge` already has both Prelint and manifest tags from ticket 06 and
is unchanged. All four existing IDs, tiers, matchers, routing, ratings, severities
and consumer snapshots remain unchanged. Dependency aliases, all four shipped
config tiers and legacy config/glob validation retain their existing coverage.
No dependency version or installation folder is required.

Added the single ecosol `require-prelint-specs-glob` rule: medium precision,
low impact, informational severity, `[package-json, tests]` scope. It reports
missing literal specs exclusion independently from the existing dependency
exclusion rule. It checks only direct root Prelint task strings, accepts current
and legacy task names and bounded single-quoted directory negations, and rejects
single-star, positive, lookalike and suffix-contaminated flags. Missing tasks and
non-string values remain the presence rule's concern; unrelated task names and
nested lookalikes do not acquire this command requirement.

The coverage reference documents suppression for equivalent owner workflows and
excludes shell interpretation, actual effective scan scope, config existence,
installed tools, execution and project-wide coverage. The zero-findings fixture
gains only the specs flag. The stored generated Drop Calf fixture, Forge task,
Fence Rider rules, tier configs, dependencies and generator remain unchanged.

### Red → green evidence

1. The public capability-report assertion failed with only `lint-with-forge`
   mapped, then passed after the three additive metadata tags. The final report
   exposes all five rules including the new exclusion check.
   Evidence: `.scratch/tmp_rovo_ticket10_mapping_red.log`,
   `.scratch/tmp_rovo_ticket10_mapping_green.log` and
   `.scratch/tmp_rovo_ticket10_mapping_complete.log`.
2. The native generated-package mutation removing only `!specs/**` initially
   escaped with zero findings. The new advisory makes it produce exactly
   `require-prelint-specs-glob`, without a dependency-exclusion finding.
   Evidence: `.scratch/tmp_rovo_ticket10_specs_red.log` and
   `.scratch/tmp_rovo_ticket10_specs_green.log`.
3. Added valid alternatives, unrelated/nested tasks and malformed globs to the
   native rule tests. Two additional token-boundary cases exposed false acceptance
   of `--extra--globs` and a suffix after the quoted pattern; tightened only the
   new rule's boundaries. All 12 valid and 9 invalid specs examples now pass.
   Evidence: `.scratch/tmp_rovo_ticket10_tokens_red.log` and
   `.scratch/tmp_rovo_ticket10_focused_green.log`. Ast-grep returns status 4 for
   that expected matcher-test failure; the visible missing-match diagnostics are
   the red evidence, not an unrelated runtime failure.
4. Static fixture mutations distinguish missing config, wrong config, missing
   dependency exclusion and missing specs exclusion. Generated tasks, dependency
   aliases, valid legacy config/globs and unrelated scripts behave as intended;
   direct Forge lint retains ticket 09's exception. The new scope case exercises
   package filename restrictions, nested app paths, ignored directories and
   all four shipped tiers through the existing native routing seam.

### Validation

- Focused native tests and snapshots: all 5 Prelint suites passed (65 examples).
  Only the new specs snapshot is added; all existing snapshots are preserved.
- New rule native scope routing across all four shipped tiers passed.
- Explicit authoring checks, `shellcheck -x`, `shfmt -d`, `git diff --check` and
  repository-wide `bun run format:check` passed.
- Full `bun run test`: exit 0; all 210 consumer rule suites, 210-definition routing
  across four shipped tiers, generated/security/page-title fixtures, 6 authoring
  suites, metadata/value/orchestration checks, capability coverage, scope
  composition, severity matrix/gates, repository-wide authoring enforcement and
  package-boundary checks passed. Full evidence:
  `.scratch/tmp_rovo_ticket10_full_test.log` (`FULL_TEST_EXIT=0`).
- Independent read-only review found no concrete correctness or acceptance gap.
  Tests use public report/scanner outputs and literal expected rule IDs rather
  than private implementations; extra full-matrix scans are accepted for native
  routing confidence. No credential resolution, Forge task, helper, release,
  installation, deployment or remote operation is executed as test evidence.

The final Git commit is the user's explicitly requested delivery action, not
execution of a package command under test. Ticket 11 is the next ready ticket
by the same dependency-order and lowest-number tie-break.
