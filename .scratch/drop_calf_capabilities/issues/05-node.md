# 05: Align Node checks with the current forge-app baseline

**What to build:** A current Drop Calf Forge app passes Node convention checks, and genuine package engines drift is reported without falsely freezing refreshed Node type dependencies at a seed literal.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** done (2026-10-25)

**Capability:** node

**Coverage today:** `use-node-24` requires the literal devDependency value 24 and omits engines. Its note says types are pinned to the runtime major. Current forge-app calls nodeBaseline without an explicit major, so existing types are kept fresh; the strict literal check is stale. `require-package-license-apache-2-0` covers the license derived through Node and is mapped in ticket 03.

**Source convention:** Seed .nvmrc at Node 24, the public npm registry configuration, and @types/node; remove engines on forge-app updates. Explicit-major semver constraints are a separate option used by other profiles, not this forge-app policy.

- [x] Reuse and tag `use-node-24` with `capability:node`; correct its diagnostic, rationale and matcher so it does not claim current forge-app requires an exact @types/node 24 string. Preserve the ID unless a separately justified compatibility decision is approved.
- [x] Keep a high-signal root package engines-absence check. Treat seeded type declaration presence separately from exact pin policy; do not add hard-coded current tool versions or attempt semver subset algebra in regex.
- [x] Add regression examples for the current seed, a refreshed valid types declaration, engines present, and misleading nested fields. Record whether missing owner-removed types is advisory seed guidance or intentionally unchecked.
- [x] Explicitly document numeric .nvmrc/public-registry conventions as separate artifact coverage gaps unless a supported native parser is demonstrated. Do not equate a JSON dependency declaration with runtime selection.
- [x] Record runtime agreement with the manifest and catalog-derived package licensing as cross-file reconciliation owned by Drop Calf, not something this rule proves. Run focused tests, metadata checks and fixture regression.

**Boundary:** No host fnm changes or Node downloads are needed to validate a static rule. Coordinate package-license tagging through ticket 03 without duplicating its edit. The shared definition of done applies.

## Completion record — 2026-10-25

Selected as the lowest-numbered unfinished dependency-ready ticket. Ticket 01,
its only prerequisite, and tickets 02–04 were already done. The user explicitly
approved the existing public seams: ast-grep rule examples, capability-report
output, generated-package mutations and native four-tier routing.

### Implementation and reviewed judgments

- Preserved `use-node-24`, its native JSON filename routing, high precision, low
  impact and informational severity. It now reports only direct root `engines`
  fields, regardless of their value, and carries `capability:node`.
- Removed the stale exact `@types/node` requirement. Seeded, refreshed and older
  declarations, alternate placement, and owner-removed declarations are
  intentionally unchecked, not evidence of runtime selection. Nested `engines`
  lookalikes do not trigger a root-package policy finding.
- Reviewed Drop Calf revision `be86d05309a32f7eef8988205208c17ca94e7a4c`, especially
  `src/capabilities/node.ts`, `src/composition/profiles.ts` and
  `tests/capabilities/node.test.ts`. Forge-app removes `engines` without selecting
  an explicit type major; library options are not this profile's policy.
- Updated diagnostic, references and rationales: npm compatibility metadata does
  not establish a blanket Forge deployment failure. No autofix was added.
- Added a Node coverage-report contract listing exactly the engines check and
  existing catalog-derived package-license check. Did not duplicate ticket 03's
  license change or modify routing via capability tags.
- Recorded numeric `.nvmrc`, public-registry `.npmrc`, missing-file and effective
  environment gaps in `docs/reference/capability-coverage.md`. No unsupported
  parser was invented. Runtime/manifest agreement and catalog/package derivation
  remain Drop Calf reconciliation, not cross-file proofs from this JSON check.
  Escaped key spellings remain a documented false-negative limitation.

### TDD evidence

- **RED:** With the old matcher, accepting refreshed `^26.1.0` types and
  owner-removed declarations failed the public `use-node-24` examples (exit 1).
  Evidence: `.scratch/tmp_rovo_ticket05_types_red.log`.
- **GREEN:** Removing only the type-literal branch passed those examples while
  preserving the engines finding. Evidence:
  `.scratch/tmp_rovo_ticket05_types_green.log`.
- **Boundary regression:** Added root `engines` objects/null/non-Node declarations,
  nested engines and nested type lookalikes; all 14 cases pass. Existing direct
  root matching needed no extra logic. Snapshots were regenerated without stale
  missing-types diagnostics.
- **RED:** Node capability-report assertion failed before tagging: output listed
  only `require-package-license-apache-2-0`. Evidence:
  `.scratch/tmp_rovo_ticket05_discovery_red.log`.
- **GREEN:** Adding the tag makes the public TSV expose exactly both active Node
  checks. Evidence: `.scratch/tmp_rovo_ticket05_discovery_green.log`.
- Retained generated real-file fixture mutations for unchanged/refreshed/removed
  types, nested engines and root engines. Only root engines produces one
  informational finding with the Node capability metadata.

### Validation

- Focused `use-node-24` tests and regenerated snapshots: passed, 14 examples.
- Focused authoring metadata check: passed.
- Focused native routing: passed across all four shipped tiers.
- Both generated and repo-init package baselines: zero Node findings.
- `bun run test`: passed, all 205 consumer rule suites, fixture/security checks,
  205-definition four-tier routing, six authoring suites, metadata/capability
  discovery, scope composition, severity checks and package boundary.
- `bun run check`: passed through the repository's pre-push hook.
- Changed shell scripts: `shellcheck -x` and `shfmt -d` passed.
- Full verification evidence: `.scratch/tmp_rovo_ticket05_full_tests.log` and
  `.scratch/tmp_rovo_ticket05_checks.log`.

No dependencies, parser plugins, host version-manager changes, Node downloads,
Forge manifest changes, or generated app fixture edits were needed.
