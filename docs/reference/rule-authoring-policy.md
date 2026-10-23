# Rule-authoring policy

This reference specifies the authoring contract for Forge Prelint rules. It is
repository-only documentation, not a consumer rule tier or an ast-grep extension.
The [glossary](../../GLOSSARY.md) defines the domain terms.

## Rollout status

Ticket 01 establishes this contract and demonstrates it on six rule files in
three families. Only metadata changes in the pilot: IDs, languages, matchers,
utilities, fixes, messages, notes, native scope, and current severity are preserved.
Existing unmigrated rules remain compatible during the expand–migrate–enforce
rollout; this document does not claim that the whole repository already conforms.

| Stage | Boundary                                                                                                                            |
| ----- | ----------------------------------------------------------------------------------------------------------------------------------- |
| 01    | Policy and metadata-only pilot; no executable policy checker.                                                                       |
| 02    | Explicit yq metadata-edit recipes and shared policy data; no scope inference, native-scope changes, or custom CLI.                  |
| 03    | Repository-only validation, with an explicit, non-growing allowance for existing unmigrated rules. Calculated severity is advisory. |
| 04–07 | Reviewed metadata migration by tier/category, including inline rationale and scope declarations.                                    |
| 08    | Reviewed materialization/normalization of scope profiles, including every coverage change.                                          |
| 09    | Reviewed severity calculation and application; enabled-rule severity becomes enforceable.                                           |
| 10    | Complete enforcement and removal of migration-only allowances.                                                                      |

Until ticket 03, compliance is established by contributor review and the existing
checks, not an unimplemented validation command. Scope changes and severity
changes are separate behavior changes, not metadata maintenance.

## Metadata schema

Fields belong under the rule document's top-level `metadata` mapping. Nested
matcher keys named `metadata` are not declarations. Existing unrelated metadata
is preserved. Required fields apply to enabled rules and `severity: off`
placeholders alike.

| Field                 | Type                                  | Requirement                                                                            |
| --------------------- | ------------------------------------- | -------------------------------------------------------------------------------------- |
| `category`            | String                                | Required; exact parent-directory category from the vocabulary below.                   |
| `precision`           | `low`, `medium`, or `high`            | Required; confidence that a match establishes the stated non-compliance.               |
| `precision-rationale` | Nonempty string                       | Required; matcher evidence, limitations, and relevant positive/negative test paths.    |
| `impact`              | `low`, `medium`, or `high`            | Required; consequence of genuine non-compliance, independently of precision.           |
| `impact-rationale`    | Nonempty string                       | Required; concrete harm, severity, and supported conditions, grounded in `references`. |
| `references`          | Nonempty sequence of URL strings      | Required; authoritative sources supporting the policy and assessment.                  |
| `scope-profile`       | Nonempty sequence of selector strings | Required; standard composition or `[unique]`, as specified below.                      |
| `scope-rationale`     | Nonempty string                       | Required for `[unique]`; optional for standard selections.                             |
| `owasp`               | Nonempty string                       | Optional; edition-specific OWASP classification.                                       |
| `cwe`                 | Nonempty string                       | Optional; CWE identifier and classification.                                           |
| `tags`                | Sequence of distinct strings          | Optional; module classification only.                                                  |

A nonempty string contains non-whitespace text. Rationale is durable metadata,
not a parallel assessment tree or a review-comment-only artifact. Test paths are
repository-relative and identify existing evidence; they are not HTTP references.
A limitation without an existing test must be identified as an assessment gap,
not represented as tested behavior. Disabled placeholders without executable
tests state that limitation rather than inventing test paths.

### Category vocabulary

Rules have the layout `rules/<tier>/<category>/<rule-id>.yml`. The filename stem
matches the stable rule ID. Tiers are `recommended`, `strict`, `atlassian`, and
`ecosol`; they are not scope profiles. Unexpected layouts and unknown categories
require an explicit policy change rather than a guessed classification.

The category vocabulary is:

- `api-usage`
- `architecture`
- `cost`
- `devtools`
- `forge-ahead`
- `forge-scripts`
- `frontend-ui`
- `git-hooks`
- `imports`
- `manifest`
- `package-json`
- `package-scripts`
- `performance`
- `runtime-boundaries`
- `secrets`
- `security`
- `triggers`
- `typescript`

For example, a rule under `rules/recommended/security/` has category `security`
even when its scope selects manifests. OWASP and CWE classifications do not
replace this directory category.

### References and classifications

References are absolute, parseable HTTP(S) URLs with a hostname, no surrounding
whitespace, and no exact duplicate strings. Meaningful fragments and queries are
retained. Different URLs are not automatically considered equivalent. Network
access is not required for validation; syntactic validity does not establish
source authority, reachability, or relevance. Those remain review judgments.

Useful explanatory prose and inline links remain in `note`; structured references
do not replace the note. Extraction from existing prose must not invent sources
or include trailing prose punctuation. Ambiguous extraction requires review.

OWASP classifications include their edition because category numbers change
between editions. CWE classifications identify the applicable weakness. Neither
classification alone proves exploitability or determines precision or severity.

The initial tag vocabulary is `module:<exact Forge module identifier>`. The
identifier must be supported by an authoritative Forge reference in `references`.
A module tag describes relevance; it does not route files, select a parser, or
assert that the rule applies exclusively to that module. Uncertain classifications
are omitted. `target:*` and parser-language tags are not part of this vocabulary;
frontend/backend selection belongs to `scope-profile`. New tag namespaces require
a documented vocabulary change.

## Rating rubric

Precision concerns the stated policy in `message` and `note`, not merely whether
the matcher recognizes its own syntactic pattern. The evidence comprises the
matcher, utilities, message, note, scope, authoritative sources, and existing
positive/negative tests. A false positive is a compliant match; a false negative
is an undetected violation. Missing coverage does not alone establish low
precision, but limits must be recorded.

| Precision | Anchor                                                                                                                                                |
| --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `high`    | The matched structure directly establishes the stated violation within the intended scope. Compliant matches are exceptional and narrowly understood. |
| `medium`  | A concrete signal exists, but a meaningful contextual distinction remains unresolved before the match can be called a violation.                      |
| `low`     | A broad heuristic routinely needs human assessment; ordinary compliant examples can match.                                                            |

High precision does not require proving exploitability, contacting a service, or
establishing that a credential is live. Conversely, identifying a secret-like name
is not proof of credential exposure. Ratings must not redefine the policy merely
to make a matcher appear precise.

Impact is one consequence-based rating, not separate security, reliability,
cost, and developer-experience scores. The rationale identifies what is harmed,
how seriously, and under what supported conditions. Mandatory conventions are
not automatically high impact. Current severity and hypothetical worst cases
are not evidence of impact.

| Impact   | Anchor                                                                                                                                                                                      |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `low`    | Local maintainability, consistency, or development friction, with limited consequences and straightforward recovery.                                                                        |
| `medium` | Material but bounded functionality, delivery, operational-cost, or reliability problems.                                                                                                    |
| `high`   | Credential compromise, unauthorized access, sensitive-data exposure/loss, substantial application failure, or substantial resource consumption, supported by a concrete causal explanation. |

Low precision and high impact can coexist: a secret-name heuristic frequently
matches harmless strings, while actual credential exposure has serious
consequences. A package publication safeguard can have medium impact without
assuming that every accidental publication exposes sensitive data.

AI may propose ratings and rationale; a maintainer reviews the evidence and
judgment. Prose, tag names, rule prefixes, and model confidence must not
automatically determine blocking behavior. Rationale cannot manufacture evidence
absent from the matcher, tests, and sources.

### Severity matrix

For enabled rules, the reviewed precision and impact determine the candidate
severity exactly:

| Precision / Impact | Low  | Medium  | High    |
| ------------------ | ---- | ------- | ------- |
| Low                | hint | info    | warning |
| Medium             | info | warning | warning |
| High               | info | warning | error   |

`off` is an explicit disabled state, not an impact rating or a matrix result.
Calculation preserves `off` rather than activating the rule. Missing or invalid
ratings are errors, not grounds for guessing. Unexplained severity overrides are
not part of this policy. Candidate differences remain advisory until ticket 09;
changes affecting a gate, including demotions, require explicit review.

## Scope profiles

`metadata.scope-profile` is a required array of composable selectors. Standard
profiles govern both positive `files` scope and negative `ignores` scope.
`ignore-profile` and a generic `profile` field are not alternative spellings.
The native ast-grep fields remain the only executable scope consumed by users;
ast-grep does not interpret this metadata.

| Kind         | Selector       | Positive scope contribution                                                                                                             |
| ------------ | -------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| Runtime      | `frontend`     | Conventional `**/frontend/**` paths when selected without `backend`.                                                                    |
| Runtime      | `backend`      | Conventional `**/backend/**`, `**/resolvers/**`, `**/external/**`, and `**/import-lifecycle/**` paths when selected without `frontend`. |
| Artifact     | `package-json` | `**/package.json`.                                                                                                                      |
| Artifact     | `manifest`     | `**/manifest.yml` and `**/manifest.yaml`.                                                                                               |
| Modifier     | `tests`        | No extra positive paths; omits the shared test exclusions.                                                                              |
| Escape hatch | `unique`       | Rule-owned native scope, with required `scope-rationale`. Exclusive.                                                                    |

### Composition

- Selectors within a kind are a union; kinds intersect. Artifact selectors do not
  cause parser-language switching.
- Selecting both `frontend` and `backend` means **no runtime-path restriction**,
  not just the union of recognized directories. It covers unconventional layouts
  without claiming to classify their runtime.
- An omitted runtime or artifact kind imposes no restriction of that kind. At
  least one runtime or artifact selector is required for a standard selection;
  `[]` and `[tests]` are invalid.
- `tests` is additive. Without it, the shared test exclusions apply. With it,
  tests are not excluded within the selected scope; tests elsewhere are not
  pulled into that scope. The full default is explicitly written as
  `[frontend, backend, tests]`; absence of the metadata field is invalid for
  migrated/new rules, not shorthand for that default.
- `[unique]` is exclusive. Duplicate selectors, unknown selectors, and `unique`
  combined with any other selector are invalid.
- Canonical selector order is `frontend`, `backend`, `package-json`, `manifest`,
  `tests`; `unique` appears alone. Comparison is set-based, not order-dependent.

| Selection                         | Scope envelope before parser language and rule-specific narrowing        |
| --------------------------------- | ------------------------------------------------------------------------ |
| `[frontend, backend, tests]`      | All paths, including tests, subject to the baseline.                     |
| `[frontend, backend]`             | All paths except tests, subject to the baseline.                         |
| `[frontend, tests]`               | Conventional frontend paths, including tests there.                      |
| `[backend]`                       | Conventional backend paths, excluding tests.                             |
| `[package-json, tests]`           | Package files anywhere, including test fixtures.                         |
| `[manifest]`                      | Both manifest filenames, excluding test paths.                           |
| `[frontend, package-json, tests]` | Package files within conventional frontend paths, including tests there. |
| `[package-json, manifest, tests]` | Either artifact, including tests; parser language still applies.         |
| `[unique]`                        | Explicit custom native scope.                                            |

A standard profile defines an envelope, not permission to broaden an existing
rule. Explicit native `files` may further narrow it, for example to a particular
subject or extension. Runtime and artifact restrictions intersect with that
narrowing; concatenating include lists would create an OR and is incorrect.
Materialization must reject combinations it cannot safely represent or validate
and require `[unique]`, rather than guessing at arbitrary glob intersection.
No second per-rule include list is introduced as parallel metadata.

Frontend/backend are path conventions, not manifest-driven runtime discovery.
A lone runtime selector does not reliably cover root `src/index.ts`, shared
utilities, or Custom UI under `static/custom-ui`. Nonstandard single-runtime
scope uses `[unique]`; both runtimes remove runtime narrowing. A frontend
extension or absence of a frontend directory does not establish backend identity.

### Shared exclusion sets

The canonical baseline, in write order, is:

```yaml
- "**/node_modules/**"
- "**/dist/**"
- "**/coverage/**"
- "**/specs/**"
```

This is the union of relevant exclusions in the vendored Drop Calf
[Prelint command](../../vendor/ranch-rig-drop-calf/src/prelint.ts),
[Biome template](../../vendor/ranch-rig-drop-calf/templates/biome/biome.jsonc), and
[Vitest template](../../vendor/ranch-rig-drop-calf/templates/vitest/vitest.config.ts),
not its entire `.gitignore`. The generator revision at adoption is
`3f991e138a23343ed3f5fc6c5499a0ae54aa68e1`. Nested `specs` is an intentional
generalization of its root-only Prelint exclusion. Later generator changes do
not silently change this policy. `build`, vendors, fixtures, and editor/local
configuration are not blanket-excluded.

Without the `tests` selector, append this single shared test set in write order:

```yaml
- "**/*.test.*"
- "**/*.spec.*"
- "**/__tests__/**"
- "**/test/**"
- "**/tests/**"
```

Test directories include helpers and test-local configuration, not only test
source files. Scope selection therefore requires intentional review for artifact
rules too. `tests` does not undo baseline exclusions; a package inside
`node_modules` is excluded even when tests are included.

Every migrated rule has an explicit native `ignores` sequence of strings.
Standard selections materialize exactly the appropriate shared sets, without
extra ad hoc exclusions. `[unique]` permits an explicit custom list, including
`ignores: []`, with a substantive rationale explaining intent and departures
from the baseline/test policy. A missing native `files` field retains ast-grep's
unrestricted positive scope; a present one is a nonempty string sequence.

Duplicate native globs are invalid. Exclusion membership is compared as a set;
order is canonical presentation, not scan semantics. Standard exclusions use the
orders above; custom exclusions and positive `files` lists use lexicographic
order. Ticket 01 retains pilot ordering exactly; normalization belongs to 08.

`scope-rationale` is ordinary maintainer-reviewed evidence, not self-approval.
Legacy scope rationales identify preserved differences and the normalization
review still needed; `[unique]` must not disguise accidental drift as permanent
approval. Permanent custom scope remains valid after migration when justified.
There is no separate add/remove deviation structure or assessment file tree.

### Materialization and review boundary

Consumers need no custom preprocessor. Repository-only authoring uses ast-grep
self-checks, explicit Mike Farah yq v4 edit recipes, and minimal Bash coordination
where needed. Ticket 02 supplies the [metadata recipes](../how-to/backfill-rule-metadata.md)
and a single shared policy data file, `authoring/policy.yml`. It does not introduce
a custom CLI, scope-analysis API, general glob engine, automatic prose URL
extractor, companion analyzer, or assessment-report store. Ticket 03 owns
self-evaluation and CI integration; ticket 08 owns reviewed native-scope changes.
The shared vocabulary, conventions, canonical order, and exclusion sets have one
executable data source, aligned with this specification, not competing lists.

Ticket 02 does not assign or infer scope profiles. Maintainers select scope
intent during metadata migration; existing reviewed metadata is preserved.
Legacy package rules excluding only node_modules do not satisfy the standard
`[package-json, tests]` exclusions: dist, coverage, and specs are still missing.
No automatic `[unique]` assignment or fabricated rationale substitutes for a
scope decision. Repository searches and ordinary diffs locate test/snapshot
evidence and likely companions for review, not proof of policy equivalence or
assessment coverage. Native scope remains unchanged until reviewed normalization.

Automated scope agreement checks are limited to directly comparable documented
conventional shapes and exact baseline/test-set comparisons. Unsupported positive
narrowing or glob relationships are visibly review-required, not a validated
pass. Maintainer review and real-file routing fixtures establish intended scope
where automation cannot prove it; justified custom scope uses reviewed `[unique]`.
Within-kind union, between-kind intersection, both-runtime unrestricted scope,
and the additive test modifier retain their semantics without a general glob
materialization framework. Reference shape/tag checks are conservative screens;
exact validity, source authority, module identity, rationale truth, and companion
consistency remain review responsibilities.

Changes to effective `files` or `ignores` require explicit coverage review and
real-file scanner evidence, including root/nested paths, supported languages,
unconventional layouts, generated outputs, dependencies, test filenames and
directories, and configuration artifacts. Matcher snippets cannot exercise file
routing. Removing an exclusion can broaden coverage; adding one can silently
hide findings. Neither is formatting-only maintenance.

## Language companions

Companions for equivalent policies share category, precision, impact, relevant
classifications/tags, and the same scope intent. Rationale points to each
companion's actual tests. Parser-language declarations, test paths, remediation
notes, sources, and explicitly justified native scope can differ. Extensions
alone do not justify differing ratings or inferred frontend/backend tags.
Disputed differences require review, not blind copying of metadata.

## Ticket 03 self-evaluation

Repository-only checks are implemented through native ast-grep diagnostics and
small Bash/yq supplements. The [self-evaluation reference](rule-authoring-checks.md)
records checked invariants, exact conventional scope comparisons, status codes,
frozen source-bound legacy allowances, and remaining review responsibilities.
Consumer tests and configurations are unchanged; the default test/pre-push path
also runs authoring checks. Tool/input failures cannot become migration debt,
and visible `REVIEW:` comparisons do not establish compliant scope.

## Ticket 01 pilot

| Family                         | Files                   | Precision | Impact | Current severity | Candidate severity |
| ------------------------------ | ----------------------- | --------- | ------ | ---------------- | ------------------ |
| `no-hardcoded-atlassian-token` | Base and `-tsx`         | medium    | high   | error            | warning            |
| `require-package-private-true` | Base                    | high      | medium | warning          | warning            |
| `review-hardcoded-secret`      | Base, `-js`, and `-tsx` | low       | high   | warning          | warning            |

All six files initially declare `[unique]` to preserve exact existing native
scope. The package rule's intended standard subject is `package-json`; its
legacy baseline is incomplete. The token family has extension-specific test
exclusions and lacks several baseline exclusions. The heuristic excludes `build`
and only part of the shared test set, and lacks `coverage`/`specs` exclusions.
These differences are documented inline for ticket 08, not silently normalized.

The token detector recognizes a distinctive prefix and minimum length. Its
ordinary placeholder and short-prefix tests do not establish a distinction
between a genuine credential and a realistic fabricated one. That unresolved
identity distinction supports medium precision, independently of whether a
credential is live. The name-only secret heuristic is lower precision because
ordinary labels, placeholders, and empty strings can match.

The token family's `error` versus candidate `warning` discrepancy is intentional
and remains blocking today. Ticket 09 reviews that demotion explicitly. Pilot
notes and messages remain unchanged; documenting their precision limits is not
a license to silently strengthen the detection claim.

## Verification contract

The pilot acceptance evidence is unchanged rule snapshots, passing existing
consumer tests and real-file fixtures, formatting, and a parsed comparison of
each pilot with its pre-edit version after removing `metadata`. Existing
metadata/classifications are retained. Verification also checks required field
types, directory categories, companion judgments, reference shape, and the
pilot's advisory severity differences. This verifies the pilot, not a completed
repository-wide enforcement implementation.

Future self-evaluation checks inspect top-level declarations, handle block and
flow YAML, reject duplicates and malformed values, preserve `off`, and fail with
nonzero status on scanner/configuration errors. Validation is offline and
repository-only. Authoring checks, policy data, tests, and repair tooling stay
outside shipped rule directories and shipped tier configurations; actual package
contents, not merely config intent, establish that boundary.

## Ticket 02 verification

On 2026-10-23, the explicit yq recipes were developed in red-green slices and
verified with Mike Farah yq v4.54.1. The demonstration adds only category and
reviewed existing-source references to `no-package-main` and `lint-with-forge`;
it does not complete their assessments or assign scope profiles. Parsed
non-metadata documents match HEAD, and repeat application after formatting is
idempotent. yq presentation changes to folded prose preserve its parsed text.

Recipe preservation/rejection tests, ShellCheck, shell formatting, repository
formatting, all 206 consumer rule tests, and real-file fixtures pass. Snapshots,
consumer configurations, dependency manifests, native scope, and severity remain
unchanged. An actual 213-entry package archive excludes authoring data/recipes,
scripts, tests, docs, scratch tickets, and other repository-only content. These
are opt-in authoring recipes, not ticket 03's self-evaluation or CI enforcement.

## Model references

- [ast-grep rule configuration](https://ast-grep.github.io/reference/yaml.html)
- [ast-grep lint rules](https://ast-grep.github.io/guide/project/lint-rule.html)
- [ast-grep scan CLI](https://ast-grep.github.io/reference/cli/scan.html)
