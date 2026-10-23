# Rule-authoring self-evaluation reference

Ticket 03 implements repository-only checks for the
[rule-authoring policy](rule-authoring-policy.md). The native tool seams were
approved before test-first implementation. These checks establish structural
invariants, not assessment approval.

## Entry points

| Command                                                                                          | Scope                                                                                                    |
| ------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| `bun run test:authoring`                                                                         | Native diagnostic tests, value/status regressions, recipe preservation tests, and repository enforcement |
| `bash scripts/check-authoring.sh`                                                                | All shipped `rules/*/*/*.yml`, read-only                                                                 |
| `bash scripts/check-authoring.sh rules/<tier>/<category>/<id>.yml`                               | Explicit selected documents, read-only                                                                   |
| `ast-grep test --config authoring/sgconfig.yml --test-dir authoring/tests --skip-snapshot-tests` | Native authoring matcher cases only                                                                      |

`npm test` composes consumer tests, real-file fixtures, and `test:authoring`.
The existing Lefthook pre-push command and any CI running `npm test` therefore
include enforcement; this repository has no separate hosted CI configuration.
`npm run check` retains its existing Lefthook delegation. Authoring tooling
requires Bash, Mike Farah yq v4 (tested with v4.54.1), jq, shasum, and the existing
ast-grep CLI (tested with 0.51.0). No dependencies were added.

| Exit status | Meaning                                                                        |
| ----------- | ------------------------------------------------------------------------------ |
| `0`         | No unallowlisted violations; any `REVIEW:` lines remain unresolved comparisons |
| `1`         | Unallowlisted authoring violation                                              |
| `2`         | Tool, parser, unsafe YAML, or scanner failure; never migratable debt           |

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
- Nonempty, distinct references and optional distinct module tags.
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
Other positive patterns produce visible `REVIEW:` output even for allowlisted
legacy files. Unique scope is explicitly reviewed, not machine-proven.
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
shape; exact Forge module identity remains review work.

## Migration allowances

`authoring/legacy-allowances.tsv` freezes existing unmigrated findings at ticket
03's baseline: 1,718 diagnostic allowances across 200 unchanged legacy files.
Each row contains a repository-relative path, SHA-256 of exact
source bytes, and explicitly enumerated diagnostic IDs (space-delimited).
There is no regeneration command or wildcard exemption. The six migrated pilot
files have no allowances.

An unchanged legacy source may retain only its enumerated debt. A new rule, a
changed legacy source, or a new diagnostic is enforced immediately. Migration
therefore removes obsolete rows after resolving a file's debt; incidental source
edits also invalidate the hash. Do not grow or refresh allowances to hide new
violations. Ticket 10 removes the table. Review warnings and input/tool failures
are never allowlisted. The summary reports the frozen diagnostic count, not
policy approval.

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

Actual package-archive verification excludes `authoring/`, `scripts/`, tests,
scratch records, documentation, and vendor content from the distributed artifact.
Only the original consumer rules/configurations and package metadata remain.
