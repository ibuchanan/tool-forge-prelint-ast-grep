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

## Migration progress

- Atlassian package JSON: verified red/green; generated/specification packages
  excluded, test-local packages retained.
