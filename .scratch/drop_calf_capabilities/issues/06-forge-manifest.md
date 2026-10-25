# 06: Check the local Forge runtime declaration and map manifest validation

**What to build:** An existing Forge manifest with no usable numeric Node runtime declaration receives a focused diagnostic, and the existing Forge-lint entrypoint is discoverable as part of the manifest capability without pretending to verify cross-file wiring.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** completed (2026-10-25).

**Capability:** forge-manifest

**Coverage today:** `lint-with-forge` already checks the namespaced lint task. Other manifest rules cover egress, scopes, function costs and triggers, but these are not all conventions established by this capability and must not receive its tag wholesale. No current rule checks the runtime declaration shape.

**Source convention:** Drop Calf updates an existing manifest's app.runtime.name from a numeric .nvmrc pin, preserving app identity and other settings. Numeric pins may include v and minor/patch components; the resulting runtime is nodejs followed by the major and .x. Validation runs authenticated Forge lint; initialization does not create a manifest or module wiring.

- [x] Add a check for an existing manifest's missing or malformed app.runtime.name, accepting the numeric Node runtime declaration shape rather than hard-coding the current Node 24 seed. Explain that syntactic shape does not establish platform support or agreement with .nvmrc.
- [x] Scope and test manifest YAML structures, including flow/block forms and wrong nesting as supported; do not match unrelated runtime/name fields. New rules carry `capability:forge-manifest` and authoritative runtime references.
- [x] Add `capability:forge-manifest` to `lint-with-forge` alongside its task-provider tag from ticket 10. Merge the distinct tag entries rather than replacing either; neither ticket depends on the other's matcher changes.
- [x] Verify a generated numeric declaration passes and missing/malformed declaration examples fail. Do not impose particular module names, scopes, handlers, memory settings or app identifiers not selected by Drop Calf.
- [x] Record .nvmrc agreement, export existence, credentials, missing-file detection and actual Forge lint success as consuming-tool or cross-file coverage gaps. Run static fixtures only; do not authenticate, deploy or install an app.

**Boundary:** Consult current Forge manifest guidance before implementing the rule. The check is for local convention shape, not a claim that any numeric runtime is supported. The shared definition of done applies.

## Implementation record — 2026-10-25

Selected as the lowest-numbered unfinished dependency-ready ticket. Its only
prerequisite, ticket 01, and tickets 02–05 were complete. The user approved the
existing seams: public ast-grep examples/diagnostics, real-file manifest routing,
and capability-report discovery. No additional internal seams were introduced.

### Implementation and assessments

- Added ecosol `require-numeric-forge-runtime`, categorized as `manifest`, with
  `capability:forge-manifest`, the standard `[manifest, tests]` scope and shared
  exclusions. Both native YAML filenames are included; only the ecosol shipped
  configuration adds the new rule directory. Other tiers remain unchanged.
- The direct root `app.runtime.name` must have literal `nodejs<major>.x` shape
  with a positive major and no leading zero. Block/flow mappings and ordinary
  plain/single-/double-quoted scalars are accepted. Wrong nesting and unrelated
  runtime/name fields cannot satisfy the declaration. No specific Node major,
  app ID, module, scope, handler, architecture or memory setting is imposed.
- High precision concerns the literal single-file convention, not platform
  support. Low impact reflects bounded convention/configuration repair rather
  than inferred deployment or security failure; the matrix yields `info`.
- Consulted current `forge-app-manifest-guide` and runtime search results through
  Forge Knowledge before implementation. Reviewed Drop Calf revision
  `be86d05309a32f7eef8988205208c17ca94e7a4c`, especially
  `src/capabilities/forge-manifest.ts` and its capability tests. Numeric pins such
  as `v22.12.0` become `nodejs22.x`; update preserves other manifest settings and
  does not create a missing manifest. Drop Calf updates `manifest.yml`; static
  coverage additionally retains this repository's `manifest.yaml` convention.
- Added both distinct tags to `lint-with-forge`: `capability:prelint` supplies
  the existing task and `capability:forge-manifest` consumes native lint validation.
  No matcher, rating, severity, routing or existing lint snapshot changed. Ticket
  10 can retain these tags while mapping its other provider rules independently.
- Recorded `.nvmrc` agreement, module/resource wiring, export existence,
  credentials, missing-file detection and actual authenticated Forge lint
  success as cross-file/consuming-tool gaps in
  `docs/reference/capability-coverage.md`. YAML alias/merge/tag/escape and block
  scalar resolution, duplicate keys and multi-document schema validity remain
  native-tool concerns. Numeric future/retired runtimes may pass syntactically.

### Red–green evidence and boundary discovery

- **RED:** The initial tracer test found no loaded rule. ast-grep itself returned
  success with `Configuration not found! require-numeric-forge-runtime`, so an
  explicit guard confirmed the missing coverage rather than accepting its exit
  code. Evidence: `.scratch/tmp_rovo_ticket06_initial_red.log`.
- **GREEN:** Adding the bounded runtime matcher and development/ecosol directory
  entries passed the valid numeric declaration and malformed `sandbox` tracer.
  Evidence: `.scratch/tmp_rovo_ticket06_shape_green.log`. Subsequent structure
  cases required no extra matcher branches; final coverage is 8 valid and 34
  invalid examples with snapshots only for the new rule.
- **RED:** Capability discovery listed only `require-numeric-forge-runtime`, not
  the existing lint entrypoint. Evidence:
  `.scratch/tmp_rovo_ticket06_discovery_red.log`.
- **GREEN:** Additive tags exposed exactly
  `lint-with-forge,require-numeric-forge-runtime` in the public manifest TSV row.
  Evidence: `.scratch/tmp_rovo_ticket06_discovery_green.log`.
- **RED:** Focused native routing initially failed with `No scope cases selected`.
  Registering the new definition passed both YAML filenames, app/nested/test
  paths, baseline exclusions, unrelated filenames and all four shipped tiers.
  Evidence: `.scratch/tmp_rovo_ticket06_routing_red.log` and
  `.scratch/tmp_rovo_ticket06_routing_green.log`.
- **Boundary discovery:** A real zero-byte manifest returned no findings despite
  a misleading passing `invalid: ""` snippet case. Removed that snippet and its
  stale snapshot. Retained native empty/whitespace/comment checks and explicitly
  documented that native ast-grep skips zero-byte files. Zero diagnostics on a
  skipped file are not compliance. The original failure is retained in
  `.scratch/tmp_rovo_ticket06_fixtures.log`.

### Verification

- Focused runtime and unchanged lint suites: passed, including all 42 runtime
  examples and the existing lint snapshots.
- Native routing: passed for the new rule across all four shipped tiers.
- Authoring check for both changed rule definitions: passed.
- Capability discovery: passed; both runtime shape and Forge lint are listed.
- Changed shell scripts: `shellcheck -x` and `shfmt -d` passed.
- Repository-wide `bun run format:check`: passed.
- Full `bun run test`: passed, all 206 consumer suites, real-file fixture and
  security regressions, 206-definition routing across four shipped tiers, six
  authoring suites, metadata recipes, capability discovery, scope composition,
  severity enforcement and the actual package boundary. Evidence:
  `.scratch/tmp_rovo_ticket06_full_tests.log`.
- Final focused snapshot verification: passed after removing the stale empty
  case; 34 invalid examples have exactly 34 snapshot entries. Existing consumer
  snapshots are unchanged.

The implementation, reference, regression tests and this ticket record are one
logical change, committed with `feat(manifest): Check numeric Forge runtime declarations`.
Ticket 07 is now the lowest-numbered unfinished dependency-ready ticket.

No dependencies, parser plugins, generated app changes, secret resolution,
authentication, Forge lint execution, deployment or installation were introduced.
Temporary evidence remains under `.scratch/tmp_rovo_*` per repository guidance.
