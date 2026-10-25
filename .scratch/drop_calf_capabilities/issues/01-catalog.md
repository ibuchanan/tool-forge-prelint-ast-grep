# 01: Check catalog conventions and enable capability tags

**What to build:** A Forge app with a locally malformed catalog receives actionable convention findings, and rule authors can map checks to Drop Calf capabilities without breaking the existing module-tag contract. Deliver the first usable `capability:catalog` mapping in the same slice as the vocabulary expansion.

**Blocked by:** None (can start immediately).

**Status:** completed (2026-10-25). Tickets 02–20 are now unblocked and independent; choosing the next one is ambiguous.

**Capability:** catalog

**Coverage today:** No consumer rule targets catalog-info.yaml. Existing authoring rules validate rule definitions, not app catalogs. The policy, supplemental value checker, and recipe preconditions currently accept module tags only.

**Source convention:** Catalog initialization seeds a Backstage Component, normalized metadata.name, project title, spec.type forge-app, experimental lifecycle, a user owner reference, and forge-ranch annotations for package-name, license and copyright-date. Catalog update preserves owner content. Validation checks Backstage structure, Component kind, user owner and optional copyright date; downstream consumers impose their own annotation requirements.

- [x] Extend documented tag semantics and the glossary to permit module and capability relevance. Introduce the exact 20-name vocabulary in the backlog index; accept distinct mixed module/capability tags, preserve ordering/content on unrelated edits, and reject misspellings, unknown capabilities, malformed values, duplicates and non-string entries. Update both authoring value checks and every metadata recipe precondition that currently rejects capability tags.
- [x] Add catalog findings for an existing catalog's non-Component kind and missing/invalid spec.owner user reference, accepting both user:id and user:namespace/id forms supported by Drop Calf. Do not require only the initially seeded default namespace.
- [x] Check an explicitly declared copyright-date for the supported year/year-range shape; do not claim regex proves chronological ordering or Backstage schema validity. Optional absent annotations are not globally required by this first slice; consumers add their own checks later.
- [x] Tag all new catalog checks `capability:catalog`, cite the pinned catalog implementation and authoritative Backstage guidance, and prove the generated catalog passes. Do not freeze lifecycle, title, or copyright year at seed values.
- [x] Add focused matcher and filename-routing evidence plus tag/recipe acceptance and rejection tests, including preservation of existing module tags. Keep existing module-only rules and consumer snapshots working.

**Boundary:** Scan existing catalog-info.yaml documents only; no missing-file detection, remote user lookup, cross-file identity comparison, or claim of full schema validation. The shared definition of done in the backlog index applies.

## Completion record — 2026-10-25

### Agreed seams and test-first evidence

The user approved ticket 01 and its public seams: authoring checks/metadata recipes,
ast-grep catalog diagnostics, and real-file routing/generated catalog acceptance.

- A mixed module/catalog/test tag fixture failed the value checker before the
  policy expansion, then passed with the shared exact 20-name vocabulary.
- The four-recipe mixed-tag preservation test failed the old shared precondition,
  then passed after updating it. Regressions cover unknown/misspelled/optional
  names, malformed and non-string entries, module preservation, and stable order.
  Duplicate tags fail authoring checks; explicit normalization retains its
  existing first-seen deduplication behavior rather than silently changing other recipes.
- Each catalog test was added before its rule. The initial runs failed with
  `Rule not found` (missing feature, not a matcher assertion failure); the first
  kind run also supplied unsupported regex-style filter anchors. Subsequent exact
  ID runs passed after the minimal matching rule was introduced. Expanded examples
  now cover block/flow YAML, quoted keys/scalars, wrong types/nesting/lookalikes,
  namespace variants, and owner-managed title/lifecycle/year values.
- The shared routing fixture failed with `Unknown routing case: catalog` before
  adding filename handling, then passed for each rule through all four tiers.

### Delivered behavior and limits

- Added three ecosol/devtools rules: `require-catalog-component-kind`,
  `require-catalog-user-owner`, and `require-catalog-copyright-date`.
- All three use `capability:catalog`, high precision/low impact → info, authoritative
  Backstage references and the pinned Drop Calf catalog implementation. They have
  fresh assessments and unique-scope rationale; no automatic fixes are included.
- Catalog kind and owner are direct root/spec checks. Owners accept `user:id` and
  `user:namespace/id`, with the pinned case-insensitive reference syntax.
- Copyright annotations are optional; declared literal values require string-year
  or string-range shape. A bare single year is a number and is rejected; a bare
  range is a string. Reverse ranges deliberately remain native-validation work.
- Scope is existing `catalog-info.yaml` only, not `.yml` or unrelated YAML, with
  standard generated/dependency/spec exclusions and test-local inclusion. Caller
  app-root scoping remains necessary; tags never route files or prove installation.
- Aliases, tags, block/escape-encoded scalar spellings, full Backstage schema,
  remote/cross-file identity, missing files and chronological ordering remain
  outside these literal checks. Existing consumer snapshots are unchanged.

### Verification

All final checks passed:

- Focused catalog suite: 62 examples (12 kind, 27 owner, 23 date) and snapshots.
- Focused four-tier filename routing for each new rule, plus generated catalog
  acceptance in the standard fixture suite.
- `bun run test`: 204 consumer rule suites, fixture/security/page-title checks,
  all 204 definitions routed through four tiers, six authoring suites, metadata
  recipe/value/orchestration, scope/severity/gates, and actual packed-package boundary.
- `bun run check`: pre-push test command completed successfully (485.75 seconds).
- `bun run format:check`, `shellcheck -x` and `shfmt -d` on all four changed shell
  files, and `git diff --check`.
- Independent read-only review found no blockers.

Evidence is retained in `.scratch/tmp_rovo_ticket01_full_tests.log`,
`.scratch/tmp_rovo_ticket01_check.log`, `.scratch/tmp_rovo_ticket01_format.log`,
focused red/green logs, and generated `.scratch/tmp_rovo_*` routing/package artifacts.

Tickets 02–20 are now independently eligible. Numeric order is not a dependency
order; ask the user which capability to take next. No unrelated backlog changes
are included in this implementation commit.
