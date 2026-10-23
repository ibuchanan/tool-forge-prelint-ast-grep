# Native scope routing

Ticket 08 normalizes native scope under the [authoring policy](rule-authoring-policy.md).
The user approved the public scanner/status seams and coverage choices on
2026-10-23 before implementation.

## Coverage decisions

- Every rule uses the baseline from `authoring/policy.yml`: dependencies, dist,
  coverage and root/nested specs are excluded. The baseline is the relevant
  union of the vendored Drop Calf Prelint command, Biome and Vitest templates,
  not its whole gitignore.
- Existing positive narrowing is preserved. Existing rules including tests keep
  doing so; partial test exclusions become the complete shared set, including
  test helpers and configuration directories. Test inclusion never overrides
  the baseline or adds positive paths.
- Build is not a baseline exclusion. Removing the old source-family build
  exclusion intentionally adds findings there. Vendors and fixtures are not
  blanket-excluded.
- Standard package, manifest, frontend and unrestricted selections are explicit.
  Both runtimes mean unrestricted positive scope, including unconventional
  layouts, not a union limited to recognized runtime directories.
- Custom configuration filenames, resolver-only rules, exact frontend
  entrypoints, server entrypoint layouts and negative frontend boundaries keep
  exclusive `unique` profiles with inline intent. These exceptions preserve
  positive narrowing, not legacy incomplete exclusions. Paths do not prove
  runtime or app identity.

## Routing evidence

`bash scripts/check-scope-fixtures.sh` exercises the shipped recommended, strict,
Atlassian and Ecosol configurations. An optional rule path or category path
selects a slice. `rule-tests/fixtures/scope-routing.tsv` records independently
reviewed positive boundaries and test policy, not inferred glob equivalence.
Existing invalid matcher examples provide known-positive payloads. Expected
paths are explicit in the fixture coordinator and never calculated from native
`files` or `ignores`.

The matrix covers root/nested source and configuration targets, dependencies,
dist/coverage/specs, build, vendors, fixtures, test/spec suffixes, all shared test
directories plus helpers/configuration, conventional runtime roots, root entrypoints
and unconventional layouts. Native filename restrictions remain in force.
TS/MTS/CTS, TSX, JS/JSX/MJS/CJS, JSON/JSONC and both manifest YAML extensions are
exercised where each rule's parser and native scope support them. Scanner ignore
files are disabled so Git exclusions cannot disguise incorrect rule routing.

Each category is tested red against the original scope and green after explicit
yq previews/edits. Source copies, previews and routing differences remain under
`.scratch/tmp_rovo_*` for review. Only scope fields and inline scope rationale
change; parsed IDs, matchers, utilities, fixes, messages, notes, ratings and
severities are preserved. Scope changes do not implement ticket 09's severity
matrix or ticket 10's compatibility removal.

## Completed category slices

All 206 definitions were migrated in 27 category-sized red/green slices:

| Tier        | Categories                                                                                                         | Definitions |
| ----------- | ------------------------------------------------------------------------------------------------------------------ | ----------- |
| Atlassian   | package-json                                                                                                       | 1           |
| Ecosol      | devtools, forge-ahead, forge-scripts, git-hooks, package-json, package-scripts, secrets, typescript                | 56          |
| Recommended | architecture, cost, devtools, frontend-ui, manifest, package-json, package-scripts, security, triggers, typescript | 54          |
| Strict      | api-usage, frontend-ui, imports, package-json, performance, runtime-boundaries, security, triggers                 | 95          |

159 definitions now use standard profiles; 47 keep justified unique boundaries.
The final shared lists are deduplicated and canonically ordered. All original
positive path membership is retained. The migration allowance file was already
empty after ticket 07 and remains empty.

## Effective coverage changes

| Original native scope                                                        | Approved change                                                                                                               |
| ---------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Dependency-only package, manifest, config, frontend and unrestricted lists   | Exclude dist, coverage and root/nested specs; keep tests eligible within the original positive selection.                     |
| Source lists excluding node_modules/dist plus only `*.test.*` and `*.spec.*` | Add coverage/specs and complete test-directory exclusions, including helpers/configuration; retain the existing test opt-out. |
| Source lists also excluding build                                            | Remove build exclusion, deliberately adding build findings; add coverage/specs and complete test-directory exclusions.        |
| Negative frontend boundary                                                   | Retain that exact boundary and root/shared/unconventional server layouts; apply baseline and complete test exclusions.        |
| Custom config names and runtime/entrypoint selections                        | Retain exact filenames/directories/extensions. Apply baseline and keep the original include/exclude test decision.            |
| Already-normalized pilot default                                             | No native membership change; retain explicit full default and verify routing.                                                 |

No vendor or fixture exclusion is added. Singular `spec` directories remain
eligible unless another native boundary excludes them; plural `specs` are in the
baseline even when tests are included.

## Verification

- All 27 categories failed their new routing assertions before edits and passed
  after reviewed yq previews/application. Per-file application idempotency was
  checked; normal metadata recipes and their rejection/idempotency tests pass.
- All 206 parsed definitions match the saved originals after removing only
  `files`, `ignores`, `metadata.scope-profile` and `metadata.scope-rationale`.
  Existing consumer snapshots, dependencies, shipped configs and severity
  judgments are unchanged.
- All 206 consumer tests pass. Integrated authoring tests and checks pass with
  zero frozen findings; unsupported positive relationships still report REVIEW
  rather than being asserted mechanically compliant.
- Security fixture assertions now include the approved build findings in 63
  source definitions. The full fixture run passed: 206 definitions across all
  four shipped tiers, plus scaffold, Biome and security fixtures.
- Composition regression fixtures scan explicit conventional intersections,
  runtime/artifact unions, additive tests, parser boundaries and reviewed native
  narrowing through all four configs. Narrowing beyond comparable conventional
  shapes is explicitly expected to produce a REVIEW diagnostic.
- Repository Prettier, changed-shell ShellCheck/shfmt and `git diff --check` pass.
  The exhaustive fixture run is recorded in the local ticket completion entry.
