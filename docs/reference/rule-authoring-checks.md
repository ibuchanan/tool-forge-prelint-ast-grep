# Rule-authoring self-evaluation reference

Repository-only checks enforce the [rule-authoring policy](rule-authoring-policy.md)
for every current and new definition, including language companions and disabled
placeholders. There is no migration ledger or suppression path. The public tool
seams were approved before test-first implementation. These checks establish
structural invariants, not assessment approval.

## Entry points

| Command                                                                                          | Scope                                                                                                    |
| ------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| `bun run test:authoring`                                                                         | Native diagnostic tests, value/status regressions, recipe preservation tests, and repository enforcement |
| `bash scripts/check-authoring.sh`                                                                | All shipped `rules/*/*/*.yml`, read-only                                                                 |
| `bash scripts/check-authoring.sh rules/<tier>/<category>/<id>.yml`                               | Explicit selected documents, read-only                                                                   |
| `ast-grep test --config authoring/sgconfig.yml --test-dir authoring/tests --skip-snapshot-tests` | Native authoring matcher cases only                                                                      |
| `bash scripts/check-package.sh`                                                                  | Actual archive membership and loading of all four packed consumer configurations                         |

`npm test` composes consumer tests, real-file fixtures, and `test:authoring`.
The existing Lefthook pre-push command and any CI running `npm test` therefore
include enforcement; this repository has no separate hosted CI configuration.
`npm run check` retains its existing Lefthook delegation. Authoring tooling
requires Bash, Mike Farah yq v4 (tested with v4.54.1), jq, and the existing
ast-grep CLI (tested with 0.51.0). Preservation tests use shasum; the archive check
also uses Bun and tar. No dependencies were added.

| Checker exit status | Meaning                                                                   |
| ------------------- | ------------------------------------------------------------------------- |
| `0`                 | No detected violations; any `REVIEW:` lines remain unresolved comparisons |
| `1`                 | Authoring violation; every finding is enforced                            |
| `2`                 | Tool, parser, unsafe YAML, or scanner failure; never a policy exception   |

## Native diagnostics

`authoring/sgconfig.yml` loads only `authoring/rules`, `authoring/utils`, and
`authoring/tests`. None are included in consumer configurations. Documents with
`severity: off` are inputs to these checks, not exempt definitions.

| Diagnostic                       | Declaration-level check                                                 |
| -------------------------------- | ----------------------------------------------------------------------- |
| `require-authoring-metadata`     | Direct top-level metadata mapping                                       |
| `require-authoring-fields`       | Direct category, impact, references, and scope-profile fields           |
| `require-authoring-precision`    | Explicit supported precision rating                                     |
| `require-authoring-field-shapes` | Supported impact rating and nonempty references/scope-profile sequences |
| `require-authoring-rationales`   | Nonempty inline precision/impact rationale scalars                      |
| `require-authoring-native-scope` | Explicit top-level ignores sequence, including `[]`                     |

Shared mapping-boundary utilities exclude matcher keys, nested examples, and
block-scalar prose. Block and flow collections and literal single/double-quoted
keys are covered. Supplemental yq checks validate parsed scalar types and values;
native structural checks alone do not establish string-element validity.

## Value and set checks

`authoring/checks/values.yq` reuses `authoring/policy.yml`. Findings cover:

- Known tier/category layout and filename/ID/category agreement.
- Supported precision/impact ratings and nonempty inline rationale strings.
- Supported native severity and agreement with the shared precision/impact matrix;
  `off` is preserved, not activated. Stale enabled severity is a `severity` finding.
- Optional nonempty string OWASP/CWE classifications.
- Nonempty, distinct references and optional distinct module/capability tags.
- Explicit, distinct, nonempty string native globs; ignores may be empty and
  optional files may not be empty.
- Distinct known selectors; standard profiles require a runtime/artifact;
  `[]` and `[tests]` are invalid. `unique` is exclusive and requires a nonempty
  inline scope rationale. Presentation order is not semantic.
- Standard ignores equal the shared baseline plus test exclusions, except that
  `tests` omits test exclusions. Unique ignores remain explicit and reviewed.

Exact set comparisons normalize order and compare encoded serialized values:
yq scalar `==` can interpret wildcard text, so it is not literal glob equality.
No native globs, reviewed ratings, profiles, or source bytes are rewritten.

## Supported positive-scope comparisons

The comparison handles only exact sets constructed from shared policy constants:

- Unrestricted positive scope: omitted files or exactly `["**/*"]`.
- One runtime: frontend or the complete backend path set.
- Artifact union: package-json, manifest, or both.
- Runtime/artifact intersection: each runtime root followed by `/` and each
  artifact suffix, for example `**/frontend/**/package.json`.
- Both runtimes: no runtime restriction, with any selected artifact union.

Within-kind selectors union; different kinds intersect. `tests` adds no positive
paths. A different known conventional set is `positive-scope`, a violation.
Other positive patterns produce visible `REVIEW:` output for every definition.
Unique scope is explicitly reviewed, not machine-proven.
Unsupported narrowing must retain maintainer review and routing fixtures; it is
not converted to `unique`, silently accepted as equivalent, or auto-repaired.

## Input and screening limits

`document.yq` rejects malformed YAML, multiple/empty documents, non-mapping
roots, duplicate keys, non-string mapping keys, anchors, aliases, merge keys,
and nonstandard tags with status 2. Quoted keys with escape-encoded spellings
are outside native matching support and may produce declaration diagnostics;
use literal spellings. Symlink safety and arbitrary YAML representation
preservation are not claimed; the checks do not edit files.

The reference screen requires explicit HTTP(S) strings, host text, and no
whitespace, using the shared conservative pattern. Queries and fragments are
preserved. It does not establish complete URL validity, authority, relevance,
reachability, or authenticity. Tags require `module:<namespace>:<identifier>`
shape or `capability:<name>` from the exact 20-name vocabulary in
`authoring/policy.yml`. Mixed entries are allowed; duplicates, unknown capabilities,
malformed values and non-strings are rejected. Exact Forge module identity and
capability relevance remain review work; tags do not route files or prove installation.

## Enforcement and exceptions

Every detected violation is an error. The migration ledger, source-hash lookup
and compatibility-only tests have been removed; recreating the old ledger cannot
suppress findings. A retained integration regression demonstrates default discovery
of a new malformed disabled rule, rejection despite a former exact ledger entry,
explicit repair and a successful recheck without activating it. Enabled rules are
enforced through the same path.

The only custom scope mechanism is exclusive `[unique]` with nonempty inline
`scope-rationale` and maintainer-reviewed routing evidence. It does not bypass
metadata, native-glob shape or severity checks. A visible `REVIEW:` comparison
remains unvalidated even at status 0; it requires review and real-file fixtures,
not a blanket suppression. No arbitrary glob-equivalence claim is made.

## Repairs and remaining review

Diagnostics point to the explicit [yq recipes](../how-to/backfill-rule-metadata.md)
for category/reference/ordering edits. Preview the selected transformation before
applying it; never overwrite approved scope or judgments merely to silence a
finding. Integration tests demonstrate a missing category finding, explicit
`category.yq` repair, a clean recheck, and byte-preserving read-only scans.

Companion equivalence, evidence adequacy, rationale truth, classification
relevance, exact module identities, arbitrary scope, and ratings require
maintainer review. Ticket 09 enforces the reviewed matrix for enabled rules;
its [severity reference](rule-severity.md) documents the non-mutating report,
explicit edit recipe, approved gate changes and exit-status regressions.
Disabled definitions stay disabled. Native-scope decisions are recorded by ticket 08.

`scripts/check-package.sh` uses `bun pm pack --ignore-scripts`, compares the
complete tar membership against discovered rule files, four tier configs,
package.json, LICENSE and README.md, then loads each extracted config against an
empty input directory with ast-grep. Configs permit only consumer rule directories
and optional language globs, never repository-only test/utility directories.
Unexpected archive entries, missing files, invalid configs and scanner failures
fail validation. The actual archive excludes authoring tooling, tests, scratch
records, other documentation and vendor content; no lifecycle scripts run and
nothing is published. Evidence remains under `.scratch/tmp_rovo_package.*`.
