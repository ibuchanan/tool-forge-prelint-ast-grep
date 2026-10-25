# 03: Map OSS licensing checks and validate catalog license input

**What to build:** Forge sample maintainers can find existing Apache licensing guidance by capability and receive a local finding when the catalog license supplied to the pinned OSS templates is unsupported.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** completed (2026-10-25).

**Capability:** oss

**Coverage today:** Reuse `require-package-license-apache-2-0`. There are no consumer catalog-license rules or checks for the generated OSS document suite.

**Source convention:** OSS seeds LICENSE, README, contribution, conduct, SECURITY and OWNER documents. Authoritative pinned legal/ownership assets are refreshed using catalog metadata, while owner README prose is preserved according to the capability's update behavior. The pinned OSS template supports Apache-2.0. Node derives the package license from the same catalog annotation; OSS does not independently own package reconciliation.

- [x] Tag `require-package-license-apache-2-0` with `capability:oss`; add `capability:node` only with the documented package-license derivation relationship, without changing the existing policy or severity.
- [x] Add a narrowly scoped catalog finding for absent, empty or unsupported forge-ranch/license input to the selected Apache OSS convention; tag it `capability:catalog` and `capability:oss`, explaining the producer/consumer mapping.
- [x] Accept the current generated catalog and package; reject a changed license annotation and package license independently. Unrelated nested license keys must not satisfy either check.
- [x] Separate the catalog-dependent OSS convention from generic Backstage acceptance. Do not require byte-identical README text, a fixed year/owner, or erase owner-authored prose.
- [x] Document file existence, legal-document equivalence and catalog/package/OWNER agreement as cross-file or plain-text gaps left to Drop Calf/native tools. Run metadata, rule and real-file routing checks for the new catalog scope.

**Boundary:** No missing LICENSE or SECURITY finding can arise from a file that was never scanned. Do not add unsupported document parsers solely to carry a tag. The shared definition of done applies.

## Implementation record — 2026-10-25

### Selection, agreed seams and test-first evidence

Ticket 01 is complete; tickets 02 and 21 are already complete. Ticket 03 is
therefore the lowest-numbered dependency-ready ticket. The user approved these
public test seams: capability-tag discovery, ast-grep catalog/package diagnostics,
and real-file routing/generated-fixture acceptance.

- Capability discovery failed first because the existing package license rule
  lacked the OSS tag, then passed after adding `capability:oss` and
  `capability:node`. Final discovery also finds the new catalog rule through OSS;
  other Node conventions may be mapped independently by subsequent tickets.
- Added the generated-catalog mutation test before the new catalog rule. Changing
  only its license to MIT failed with the expected catalog rule ID missing. After
  implementation, the generated inputs pass and catalog/package mutations each
  produce exactly their own licensing finding.
- Nested-package characterization exposed a real existing false negative:
  `metadata.license: Apache-2.0` satisfied the old pair-text regex with no valid
  root license. Those tests failed before explicit direct key/value constraints
  were introduced, then passed. The correction preserves the existing policy,
  diagnostic, tier, scope, medium/medium ratings and warning severity; this is
  deliberately not described as a metadata-only change.
- Focused tests cover 36 catalog examples and 12 package examples. They exercise
  plain/quoted keys and values, block/flow mappings, absent/empty/wrong-type input,
  exact-value boundaries and wrong nesting/lookalikes. The new catalog scope
  passes the existing four-tier real-file routing seam.

### Source mapping, assessments and limits

Reviewed external Drop Calf revision
`be86d05309a32f7eef8988205208c17ca94e7a4c`:

- [OSS](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/src/capabilities/oss.ts)
  reads `metadata.annotations.forge-ranch/license` and rejects anything other
  than Apache-2.0 before writing assets. Its update refreshes authoritative OSS
  assets but preserves README edits/deletion; validation explicitly leaves document
  acceptance to manual inspection.
- [Catalog](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/src/capabilities/catalog.ts)
  produces the annotation. Generic Backstage annotations are optional: this rule
  expresses the selected pinned OSS consumer requirement, not generic catalog
  schema validity. Hence `capability:catalog` plus `capability:oss` on the new rule.
- [Node](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/src/capabilities/node.ts)
  calls [updatePackageLicense](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/src/capabilities/package-metadata.ts),
  deriving the package field from that annotation. This materially connects both
  Node and OSS to the reused package policy; OSS does not own package reconciliation.

The new `require-catalog-license-apache-2-0` is ecosol/devtools, with high
precision/low impact → info: an unsupported literal input stops a recoverable
local template workflow, not proof of a legal or runtime failure. Its reviewed
unique scope is existing `catalog-info.yaml` only, including test-local catalogs,
with the shared dependency/generated/spec exclusions. Callers must select intended
app roots; tags and filenames do not prove installation or applicability. Exclude
this rule when deliberately using a different licensing/template convention;
licensing changes require owner approval, so no automatic fix is provided.

No fixed title, owner, year, lifecycle or README text is enforced. Missing LICENSE,
SECURITY, README or OWNER files cannot be detected from absent scan inputs.
Legal-document equivalence and catalog/package/OWNER agreement remain cross-file
or plain-text responsibilities of Drop Calf reconciliation and manual review.
No fake document parser or generic legal-approval claim was added. YAML aliases,
tags, block/escape-encoded scalars, duplicate keys and complete schema validity
require native parsing/validation; the package rule likewise checks literal keys
and values, not decoded escape equivalence.

### Verification

Focused matcher/snapshot, discovery, authoring and new-rule routing checks pass.
Repository formatting, changed-shell ShellCheck/shfmt, `git diff --check` and an
independent read-only review also pass. Existing package snapshot entries compare
identically after parsing; new entries cover the corrected false negatives.
Full `bun run test` completed with exit status 0: all 205 consumer rule suites,
205 definitions routed through four shipped tiers, generated licensing mutations,
fixture/security/page-title checks, six authoring suites, metadata recipes/values,
scope composition, severity/consumer gates and the actual packed-package boundary.
`bun run format:check` also passed, as did an explicit format check of this tracked
scratch ticket. Evidence is retained under `.scratch/tmp_rovo_ticket03_*`.

This ticket update is included with the implementation in the Conventional Commit
`feat(oss): Validate catalog licensing inputs`.

Ticket 04 (gitignore) is next under the same dependency-ready/lowest-number rule.
No deployment, release, secrets resolution or remote publication was executed.
