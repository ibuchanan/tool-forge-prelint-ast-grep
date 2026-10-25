# 15: Map Forge Ahead checks and make dependency placement truthful

**What to build:** Maintainers can discover the existing Forge Ahead dependency conventions through `capability:forge-ahead`, and an unrelated metadata key or development-only entry no longer masquerades as the runtime dependency described by a rule.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** complete (2026-10-25)

**Capability:** forge-ahead

**Coverage today:** Reuse `use-forge-ahead-api-types`, `use-forge-ahead-errors` and `use-forge-ahead-logging`. Their current descendant key searches do not reliably establish production dependency placement. `no-verbose-hot-path-logging` expresses additional runtime logging advice; dependency seeding alone does not make it a generated convention.

**Source convention:** Drop Calf seeds three production dependencies: @forge-ahead/atlassian-api-types, @forge-ahead/errors and @forge-ahead/logging. References are owner-managed and freshness skips GitHub references. No source import, logger use, redaction setting or error-handling behavior is generated or validated by this capability.

- [x] Add `capability:forge-ahead` to the three existing dependency rules; do not create duplicates or tag all generic logging/security rules.
- [x] Correct the root dependency placement checks to match their existing claims: an entry in unrelated metadata, scripts or devDependencies must not satisfy a rule that explicitly asks for a production dependency. Accept the generated entries and supported owner-selected dependency references without version pinning.
- [x] Retain the API-types rule's current @forge/api applicability gate unless a separately reviewed convention decision intentionally broadens it; an unconditional seed does not by itself justify flagging frontend-only apps. Explain partial seed coverage rather than claiming full parity.
- [x] Keep seed-only dependency suggestions advisory and document that owner removal can be intentional. Installing a preferred package does not prove runtime helper adoption, correctness or redaction.
- [x] Add focused nested-key/section regression cases for intentional matcher corrections; metadata-only mappings preserve snapshots. Record source-usage and version compatibility as build/test/native-tool concerns.

**Boundary:** Do not require importing every seeded package or force exact GitHub hashes. The shared definition of done applies.

## Completion update — 2026-10-25

Selected by dependency order: ticket 01 and tickets 02–14 are complete; this was
the lowest-numbered ready ticket. Used the approved public seams: capability-report
TSV, existing rule valid/invalid cases and native real-file scans.

- Tagged only the three existing dependency rules with `capability:forge-ahead`.
  Kept generic runtime logging/security advice separate; no duplicate rule IDs.
- Corrected helper placement to direct keys in root `dependencies`. Development,
  optional/peer sections, root lookalikes, nested configuration and scripts do
  not satisfy production placement.
- Retained the API-types applicability gate, now checking the direct production
  `@forge/api` key rather than nested keys or unrelated values. Frontend/event-only
  apps without that declaration remain unreported; unconditional seeding is not
  claimed as full static parity.
- Reviewed the pinned source at `be86d05309a32f7eef8988205208c17ca94e7a4c`.
  Generated GitHub references and owner registry/local/alias/workspace/tarball
  references remain accepted without version pinning or installation.
- Updated advisory messages, notes, source references and rating rationales.
  Informational severity, medium precision, low impact, native routes and scope
  profiles are unchanged. Intentional owner removal/equivalent helpers may warrant
  suppression rather than restoration. Dependency declarations do not prove
  reference validity, compatibility, source usage, error handling or redaction.
- Expanded native fixture mutations and capability-report assertions; updated
  snapshots only for the three deliberately corrected rules. Stored generated
  fixtures, package dependencies, shipped configuration and unrelated snapshots
  remain unchanged. Coverage limits are in `docs/reference/capability-coverage.md`.

### Red → green evidence

- Mapping: `tmp_rovo_ticket15_mapping_red.log` reports `forge-ahead not-mapped`;
  `tmp_rovo_ticket15_mapping_green.log` reports exactly the three dependency IDs.
- Errors: `tmp_rovo_ticket15_errors_red.log` reports a missing expected finding
  for development-only placement; `tmp_rovo_ticket15_errors_green.log` passes.
- Logging: `tmp_rovo_ticket15_logging_red.log` reports the same missing finding;
  `tmp_rovo_ticket15_logging_gate_green.log` passes after production matching.
- API applicability: `tmp_rovo_ticket15_api_gate_red.log` reports an unexpected
  finding for nested `config.dependencies.@forge/api`; the logging/gate green
  log passes after the direct root applicability correction.
- API helper: `tmp_rovo_ticket15_api_placement_red.log` reports no finding for a
  development-only helper; `tmp_rovo_ticket15_placement_green.log` passes all
  three tracers after the helper placement correction.
- `tmp_rovo_ticket15_boundaries_green.log` passes further section/lookalike and
  owner-reference controls; updated snapshots pass the full consumer suite.

### Validation

- `ast-grep test --test-dir rule-tests`: **211 passed; 0 failed**.
- Focused Forge Ahead suites: **3 passed; 0 failed**, covering 60 valid/invalid
  cases in total, including direct production placement and retained applicability.
- `sh scripts/check-fixtures.sh`: passed, including generated declarations,
  API-app/owner variants, 12 isolated missing/misplacement mutations, advisory
  metadata, a nonblocking error-only gate and **211 definitions across four tiers**.
- `bash scripts/test-authoring.sh`: authoring matchers, values, metadata,
  capability discovery, scope composition, severity/report/consumer gates,
  authoring checks and package boundary passed.
- `bun run format:check`, `shellcheck -x` on both changed shell scripts, `shfmt -d`
  and `git diff --check`: passed. The initial ShellCheck call without `-x`
  reported only the existing sourced-file lookup warning; resolving sources passes.
- Read-only independent acceptance review found no blockers. No dependency install,
  generated app task, Forge operation or remote write was performed.

Logs are under `.scratch/tmp_rovo_ticket15_*`. Fixture validation initially exceeded
the tool wait but completed successfully with exit status 0; the final authoring
rerun captures its exit status in `tmp_rovo_ticket15_authoring_final.status`.
The commit refers to local ticket 15 rather than inventing a Jira key.
