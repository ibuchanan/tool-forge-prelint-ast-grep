# 02: Map existing package metadata checks to Drop Calf

**What to build:** Authors can discover the existing checks for a private ESM Forge app through `capability:package-metadata`, without introducing duplicate package rules or freezing release identity.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** completed (2026-10-25).

**Capability:** package-metadata

**Coverage today:** `require-package-type-module` and `require-package-private-true` already enforce the two forge-app package policies. `no-package-main`, `no-package-types` and `no-package-exports` express additional Forge packaging advice, not policies contributed by this capability; do not assign them this tag automatically.

**Source convention:** The capability enforces type module and private true; seeds version 0.1.0; and updates name, optional description and author from catalog input while preserving release version. Its native validation checks metadata types/formats rather than equality with catalog values.

- [x] Add `capability:package-metadata` to the existing type and privacy checks, preserving rule IDs, matcher behavior, scope, tiers, ratings, severity and existing tags. This slice is metadata-only for these already-covered policies.
- [x] Demonstrate the current generated package passes and explicit CommonJS/missing type or false/missing private still produces the existing expected findings.
- [x] Record structural name/version/description/author validation as consuming-tool coverage unless a concrete high-signal local gap is demonstrated; do not add a partial semver parser or require author presence when native validation permits omission.
- [x] Record cross-file catalog identity reconciliation as out of scope. Never require version 0.1.0, a particular package name, a fixed description or a particular staff ID.
- [x] Verify capability-tag discovery returns both existing rules, authoring checks accept the metadata, and consumer snapshots remain unchanged.

**Boundary:** The capability applies to Forge-app packages, not every workspace root or published library. The shared definition of done applies.

## Implementation record — 2026-10-25

### Selection, agreed seams and test-first evidence

Ticket 01 is complete. Tickets 02–20 have no other blockers, so the user's
lowest-numbered-ready tie-break selects ticket 02; completed ticket 21 is skipped.
The user approved capability-tag discovery, existing ast-grep diagnostics and
generated-package acceptance as the public test seams.

- Added the discovery assertion to the existing metadata suite first. It failed
  with an empty result while expecting exactly `require-package-private-true`
  and `require-package-type-module`.
- Added only `metadata.tags: [capability:package-metadata]` to each existing rule.
  The same discovery test then passed. It also guards against accidentally
  attributing `no-package-main`, `no-package-types` or `no-package-exports` to
  this capability.
- Characterization coverage reuses existing matcher/snapshot tests and extends
  the standard real-file fixture suite. The generated package passes; CommonJS,
  missing type, false private and missing private each produce exactly their
  existing policy finding. A custom name, prerelease version, owner description
  and absent author remain accepted. These are regression tests for existing
  behavior, not additional red-green implementation claims.

### Delivered mapping and boundaries

- `require-package-type-module` remains ecosol/package-json;
  `require-package-private-true` remains recommended/package-json. Both retain
  their warning severity, IDs, diagnostics, scope, precision and impact. Neither
  had existing tags to replace. After removing the added tags, both parsed rule
  documents compare identically with HEAD; no consumer snapshots changed.
- Source reviewed at Drop Calf revision
  `be86d05309a32f7eef8988205208c17ca94e7a4c`:
  [package metadata](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/src/capabilities/package-metadata.ts)
  and [forge-app profile](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/src/composition/profiles.ts).
  The profile selects `packageMetadata({ enforcePrivate: true })`, enforcing
  type module and private true. The existing generated fixture has those same
  policy fields; its unrelated older script wiring was not refreshed here.
- Structural name/version/description validation stays with Drop Calf's explicit
  npm-package-json-lint rules. Native author validation accepts absence, a string,
  or an object with a string name. No new high-signal local gap was demonstrated;
  no partial semver parser, author-presence requirement or frozen identity was added.
- Catalog/package name, description and author reconciliation is cross-file and
  remains Drop Calf update's responsibility. Release version is owner-managed;
  neither `0.1.0` nor a particular package name, description or staff ID is required.
- Tags enable discovery only: callers still scope scans to non-published Forge-app
  package directories, not arbitrary workspace roots or published libraries.
  Existing private-rule nested-pair false negatives remain documented in its
  precision rationale; this metadata-only ticket does not change that matcher.

### Verification

All final checks passed:

- Discovery red then green: `.scratch/tmp_rovo_ticket02_discovery_{red,green}.log`.
- Both focused matcher/snapshot suites before and after tagging (nine existing
  examples), plus authoring checks on both changed definitions.
- All 204 consumer suites and the generated package's six scan variants.
- `bun run format:check`, `shellcheck -x`, `shfmt -d` on both changed scripts,
  `git diff --check`, parsed-document preservation comparison and unchanged snapshots.
- Independent read-only review: no blockers.

Full `bun run test` completed with exit status 0: all 204 consumer suites,
204 definitions routed across four shipped tiers, fixture/security/page-title
checks, six authoring suites, values/orchestration/metadata recipes,
scope composition, severity enforcement/consumer gates and the actual packed-package
boundary. Results are retained in `.scratch/tmp_rovo_ticket02_full_tests.log`.

This ticket update is included with its implementation in the Conventional Commit
`feat(metadata): Map package policies to Drop Calf`. No deployment, release, secret
resolution, remote publication or generated app command was executed. Ticket 03
(OSS) is the next dependency-ready ticket under the user's lowest-number tie-break.
