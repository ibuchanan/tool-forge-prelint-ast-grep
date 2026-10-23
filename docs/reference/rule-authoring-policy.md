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
not part of this policy. Ticket 09 applies the explicitly reviewed differences
and enforces enabled-rule agreement with this matrix. Changes affecting a gate,
including demotions, require explicit review. The [severity reference](rule-severity.md)
describes the report, recipe, approved rollout and actual consumer exit behavior.

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

The token family's `error` versus candidate `warning` discrepancy was retained
through the metadata-only stages. Ticket 09 explicitly approves and applies that
demotion. Pilot notes and messages remain unchanged; documenting their precision
limits is not a license to silently strengthen the detection claim.

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

## Ticket 04 strict-security migration

As of 2026-10-23, all 63 definitions in `rules/strict/security/` satisfy the
metadata contract without legacy allowances. Five pilot definitions already
conformed; 58 definitions were migrated. Their 504 frozen diagnostics were
removed, leaving 1,214 diagnostics across 142 unchanged legacy definitions in
other batches. The authoring orchestration regression requires zero findings
and zero allowance entries for this category.

Every definition has its own existing positive/negative test evidence. New
rationales also cite the corresponding unchanged match snapshot. References
were selected explicitly from existing sources and authoritative Forge, Node,
MDN, OWASP, RFC and CWE documentation using the category/reference yq recipes;
URL validation is offline, not a claim of current network reachability. Existing
OWASP 2021 mappings remain edition-specific. New mappings identify logging
(CWE-532), broader environment disclosure (CWE-200), fail-open authorization
(CWE-636), input-selected impersonation (CWE-639), and the package TLS bypass
(CWE-295). These classify potential weaknesses, not proven exploitation.
No module tags were added: these policies are cross-cutting, not specific to
one exact Forge module.

### Companion and scope review

- Equivalent language companions retain the same precision, impact and
  classifications. Test and snapshot paths are language-specific.
- The JavaScript dynamic-evaluation matcher omits TypeScript/TSX
  `required_parameter`/`optional_parameter` node branches; all three retain
  conservative visible-shadowing exclusions. This parser distinction does not
  change their policy ratings.
- Raw-HTML JS/TSX companions add the JSX `dangerouslySetInnerHTML` attribute
  branch. Sanitized and literal rendering still match; low precision records
  the broad review heuristic, not a sanitizer or DOM type analysis.
- The package TLS check parses JSON script strings, not imported source clients.
  Its shell-text regex can match inert assignment text, an untested contextual
  distinction supporting medium rather than the source companions' high
  precision. Both retain high impact; the package rule remains `error`.
- The token pilot's source versus resolver references and remediation rationale
  remain intentionally different. Its test exclusions remain `.test.ts`/`.spec.ts`
  versus `.test.tsx`/`.spec.tsx`; a suffix does not establish runtime identity.
- All 63 definitions retain reviewed `[unique]` migration scope. Most source
  families exclude node_modules, dist, build, test/spec filename suffixes and
  `__tests__`, but not the complete shared baseline/test sets. The three
  TypeScript-only global/module/cache rules exclude frontend paths rather than
  selecting standard backend directories. They have no JS/TSX companions.
  The package TLS rule only excludes node_modules. Inline scope rationale
  records these exact deviations; ticket 08 owns normalization and routing
  changes, not this migration.

### Advisory severity differences

The matrix produces the following differences; **none is applied**. All other
strict-security definitions already agree with their candidate severity.

| Definitions                                                  | Precision | Impact | Current | Candidate |
| ------------------------------------------------------------ | --------- | ------ | ------- | --------- |
| Atlassian-token pilot (2)                                    | medium    | high   | error   | warning   |
| Environment disclosure (3)                                   | medium    | high   | error   | warning   |
| Sensitive-data logging (3)                                   | medium    | high   | error   | warning   |
| JWT `none` (3)                                               | medium    | high   | error   | warning   |
| Package-script TLS bypass (1)                                | medium    | high   | error   | warning   |
| Global mutation and module-scope `let`/`var` conventions (2) | high      | high   | warning | error     |

High precision for a convention violation does not prove tenant leakage or
code injection. Medium input/name-based signals do not establish missing
validation, source trust, receiver identity or exploitable flows. Low precision
for name-only secrets and raw-HTML sinks permits ordinary compliant matches.
Impact rationale states the concrete conditions for harm; missing tests remain
explicit assessment gaps rather than tested behavior. Ticket 09 must review
all gate changes, including demotions.

### Verification

The user approved native authoring output/status, metadata-document contracts
and existing consumer behavior as test seams. Red-green slices demonstrated
unallowlisted missing metadata on copied definitions, then zero findings after
migration. The retained regression first failed with legacy findings, then
failed on stale allowance rows, then passed after this batch's removal.

All 63 parsed documents with metadata removed match their pre-migration versions.
IDs, parsers, matchers, utilities, constraints, fixes, messages, notes, native
files/ignores and severities are unchanged. Existing consumer tests, snapshots,
real-file fixtures, tier configurations, dependencies and lockfile are unchanged.
All 206 consumer rule tests, tooling/security routing fixtures, native authoring,
value, orchestration and recipe suites pass. Review judgments and untested gaps
are distinct from these structural and behavioral checks.

## Ticket 05 remaining strict migration

As of 2026-10-23, the remaining 32 strict definitions satisfy the metadata
contract without allowances: API usage (9), frontend UI (4), imports (11),
package JSON (1), performance (1), runtime boundaries (5), and triggers (1).
Removing their 271 frozen diagnostics leaves 943 diagnostics across 110
unchanged legacy definitions in other tiers. The orchestration regression
requires zero findings and zero allowance rows for this batch, including
future non-security strict definitions.

### Assessment and companion review

Every definition cites its existing positive/negative test and match snapshot.
Category and reference edits use the explicit yq recipes; references are selected
from the existing Forge sources plus OWASP 2025 injection guidance and CWE-89
for dynamic SQL. Reference validation is offline, not fresh reachability evidence.
Only the three SQL rules receive security classifications: `A05:2025` and
`CWE-89`. No exact module tags are warranted for these cross-cutting policies.

- SQL TS/TSX/JS matchers and scopes are identical after removing ID and parser
  declarations. Their ratings, references and classifications agree. Imported
  aliases are recognized, but controlled identifiers can be legitimate and
  shadowing, trust and dataflow remain unresolved; precision is medium, not
  proof of exploitable injection. Generic type arguments appear only in the
  TS/TSX test examples; JS has an equivalent non-generic example.
- Six import/runtime-boundary TS/TSX pairs have equivalent matchers and scope;
  metadata differs only in actual evidence paths. The two storage-import
  definitions are same-language structural variants, not language companions;
  their patterns may overlap. Existing tests demonstrate mixed and sole imports
  separately, not disjointness.
- Name-based API requests cannot prove imported client identity or authorization
  context. A route variable may already be validated. Existing notes about
  native-fetch availability and absolute-URL egress bypass remain unchanged, but
  neither stronger claim is established by these matchers/tests. Metadata records
  conditional integration failures rather than asserting platform bypasses.
- Frontend paths alone do not distinguish UI Kit from Custom UI. Local `Table`
  components, legitimate DOM rendering, aliased/delegated reconciler registration,
  erased type imports, pure modules and unresolved paths require context. The
  fixed component export list can lag documented releases. These limitations
  prevent treating every matching name or path as a proven runtime failure.
- Missing storage limits do not establish unlimited scans or large read volume.
  HTTP-client dependencies may have legitimate uses and the matcher also sees
  string values. Unfiltered triggers may deliberately process every event, as
  their preserved note permits; their broad recommendation has low precision.
  Inline rationales distinguish tested examples from these untested gaps.

### Reviewed legacy scope

All 32 definitions deliberately retain `[unique]`, not inferred standard scope:

- Most frontend, import and boundary rules ignore only node_modules. Tests and
  generated files remain in scope; dist, coverage and specs exclusions are missing.
- Backend entrypoint selectors add `src/index.ts` but omit standard backend
  directories. Native-fetch selects only resolvers/external/import-lifecycle.
- Other API rules exclude frontend and `.test.ts`/`.test.tsx` rather than selecting
  standard backend directories. Performance/native-fetch exclusions add spec
  suffixes but still omit the full baseline and test-directory sets.
- SQL rules additionally exclude dist, build, test/spec suffixes and `__tests__`,
  but not coverage, specs or unsuffixed test/tests directories.
- Package and manifest rules include tests but lack the shared baseline beyond
  node_modules. The reconciler rule selects only `**/frontend/index.tsx`.

Each rule records its specific exception. Ticket 08 owns normalization and
routing changes; a unique declaration does not validate runtime identity.

### Advisory severity differences

No current severity changes. Ticket 09 must review these 24 matrix differences:

| Definitions                                                   | Precision | Impact | Current | Candidate |
| ------------------------------------------------------------- | --------- | ------ | ------- | --------- |
| API URL, port, HTTP, native-fetch and authorization rules (5) | medium    | medium | error   | warning   |
| Route-template rule (1)                                       | medium    | high   | error   | warning   |
| Deprecated Table (1)                                          | medium    | medium | error   | warning   |
| Native HTML and missing reconciler registration (2)           | medium    | high   | error   | warning   |
| Legacy storage-import variants (2)                            | high      | medium | error   | warning   |
| Frontend API/KVS and backend Bridge imports (5)               | medium    | high   | error   | warning   |
| Fixed UI Kit export allowlist (2)                             | medium    | medium | error   | warning   |
| Runtime-boundary path imports (5)                             | medium    | high   | error   | warning   |
| Trigger-filter recommendation (1)                             | low       | medium | warning | info      |

The other eight definitions agree with the matrix. High conditional impact
requires genuine unsupported runtime code, absent UI registration or untrusted
SQL/path text, not merely a suspicious syntax match.

### Verification

The user approved authoring output/exit status, metadata-document contracts and
unchanged consumer behavior as the public test seams. The retained regression
failed first on 271 frozen findings, then on stale allowance rows. Seven category
slices failed on copied, unallowlisted definitions before their metadata edits
and passed afterward; the regression passes after allowance removal.

All 32 parsed documents excluding metadata equal their pre-migration versions.
Original non-metadata presentation is retained as well. IDs, parsers, matchers,
utilities, fixes, messages, notes, files/ignores and severities remain unchanged.
Consumer test files, snapshots, configurations, dependencies and lockfile are
unchanged. All 206 consumer tests, real-file tooling/security fixtures, native
self-checks, value/orchestration/recipe suites, formatting and shell checks pass.
No companion subsystem, scope inference or parallel assessment store is added.

## Ticket 06 recommended migration

As of 2026-10-23, all 54 recommended definitions satisfy the metadata contract
without migration allowances. The existing private-package pilot is unchanged;
53 migrated definitions retire 452 frozen diagnostics. Remaining migration debt
is 491 diagnostics across 57 ecosol/atlassian definitions. The orchestration
regression requires zero findings and zero allowance rows for recommended rules,
including future additions.

### Assessment and companion review

Each migrated definition cites its existing positive/negative test and match
snapshot. Categories and explicitly selected references use ticket 02's yq
recipes with previews. URL validation is offline, not current reachability
verification. No assessment store, scope inference or companion subsystem is added.

- The static-invoke TS/TSX pair has identical parsed native policy after removing
  IDs/parsers. Three cost TS/TSX pairs (fields, product loops and pagination)
  share matchers and judgments but retain language-specific test exclusions.
  In particular, TS pagination excludes `.test.ts` and `.test.tsx`, not `.spec.ts`.
  The LLM TS/TSX/JS definitions have identical parsed native policy after removing
  IDs/parsers; all companion judgments agree, with individual evidence paths.
- A five-action resolver threshold does not prove unrelated domains. Multiple
  invokes may represent separate contracts; `useAction` can legitimately invoke
  an action mutation. Frequent schedules may meet freshness requirements. These
  remain low-precision recommendations, not established waste or runtime errors.
- API/storage loop matchers do not resolve imports, bounds, batching feasibility
  or deferred execution. Field/pagination token checks cannot follow options
  variables or endpoint defaults. Joined JQL lists are not counted. Memory and
  timeout declarations are not observed consumption, and larger allocations or
  longer deadlines can be necessary. These limitations are not new test coverage.
- LLM tests explicitly include a bounded three-iteration loop. Import aliases and
  deferred-function exclusions are tested; application-wide quotas, retries and
  lexical shadowing remain assessment gaps. Low precision coexists with high
  impact for genuinely uncontrolled repeated inference, not for every loop.
  These three definitions receive `LLM10:2025` and `CWE-400` classifications.
- CSP and wildcard egress have path-aware block/flow tests, including inline
  anchors, and exclude styles, hashes, unrelated keys and host-specific wildcards
  as appropriate. Supported reviewed exceptions remain possible; aliases/merges
  are not expanded. Both receive `A02:2025`, not a claim of actual exploitation.
- Admin scopes, remotes and enabled impersonation/system-token forwarding are
  supported capabilities, not proof of missing review or privilege escalation.
  High impact describes actual misuse with weak authorization/data handling.
  Their mere presence is a low-precision review signal. No exact module tags are
  warranted for these cross-cutting policies.
- The classic-scope rule's native comment records a conflict with public guidance
  preferring classic scopes. The permissions reference supplies context, not
  authoritative support for a blanket granular-scope preference. That authority
  gap is explicit in metadata; no unsupported endorsement or behavior fix is made.
- Lifecycle names identify different package-manager events, not execution on
  every install. Download-and-execute detection is command text, not shell parsing
  or provenance verification; quoted examples can match. Only the latter gains
  `A03:2025; A08:2025` and `CWE-494`. Legitimate lifecycle hooks still need review.
- Package library fields do not establish deployable identity. Size-limit checks
  do not prove bundle bloat or exclude equivalent orchestration. TypeScript exact
  settings do not resolve effective defaults, alternate valid layouts, semver or
  installed Forge bundler versions. The inherited-config backoff is retained;
  the factory-override rule, unlike sibling setting checks, does not back off.
  Historical Node 18 and pinned-parser assertions remain native text, not facts
  newly established by this metadata migration.
- Frontend paths do not distinguish UI Kit from Custom UI. StrictMode aliases or
  delegated wrappers are unresolved; its matcher accepts nested wrappers despite
  the message's top-level wording. Heading size alone cannot establish duplicate
  module titles. Trigger `ignoreSelf` checks presence, not the boolean value or
  whether handlers write subscribed entities; genuine unguarded write cycles can
  consume substantial resources. Untested distinctions remain assessment gaps.

### Reviewed legacy scope

All 54 deliberately retain reviewed `[unique]` scope; ticket 08 owns changes:

- Manifest/package selections exclude only node_modules, leaving test-local
  artifacts and dist/coverage/specs included rather than the shared baseline.
- The twelve tsconfig rules select only `**/tsconfig.json`, an artifact without a
  standard selector, and exclude only node_modules. The compiler-version rule
  instead selects package.json.
- Frontend rules select `**/frontend/**` but exclude only node_modules. The
  resolver-size rule selects only resolvers, not every standard backend directory;
  the queue-key convention has no positive runtime narrowing.
- Most cost source rules have unrestricted positive scope and partial test suffix
  exclusions, not complete baseline/test sets. LLM rules additionally exclude
  dist/build and `__tests__`, but not coverage/specs or test/tests directories.

Inline scope rationale describes these exact deviations, not parser identity or
an inferred standard profile. The original private-package pilot is untouched.

### Advisory severity differences

No severity changes are applied. Ticket 09 owns these 27 differences; the other
27 definitions already agree with the candidate matrix:

| Definitions                                                             | Precision | Impact | Current | Candidate |
| ----------------------------------------------------------------------- | --------- | ------ | ------- | --------- |
| Resolver-size and duplicate-title heuristics (2)                        | low       | low    | warning | hint      |
| Static queue key (1)                                                    | high      | medium | hint    | warning   |
| Multiple invokes, useAction invoke, memory and timeout reviews (4)      | low       | medium | warning | info      |
| Browser size preset, StrictMode, library package fields and rootDir (6) | medium    | low    | warning | info      |
| Classic scopes (1)                                                      | low       | medium | hint    | info      |
| Admin scopes, remotes, privileged capabilities and lifecycle hooks (4)  | low       | high   | hint    | warning   |
| Size-check command (1)                                                  | medium    | low    | hint    | info      |
| Jira ignoreSelf review (1)                                              | low       | high   | info    | warning   |
| JSX settings (2)                                                        | medium    | high   | error   | warning   |
| Source-map setting (1)                                                  | medium    | low    | error   | info      |
| ES2022 lib/target and Node module resolution (3)                        | medium    | medium | error   | warning   |
| skipLibCheck advice (1)                                                 | low       | low    | info    | hint      |

### Verification

The user confirmed authoring output/exit status, metadata-document contracts and
unchanged consumer behavior as public test seams. The retained regression failed
on 452 frozen findings, then on stale allowance rows, then passed after removal.
Ten category baselines failed on copied, unallowlisted pre-migration definitions;
each category passed with zero frozen findings after complete metadata edits.

All 54 parsed documents excluding metadata equal their pre-migration versions.
Native YAML presentation is retained; IDs, parsers, matchers, utilities, fixes,
messages, notes, files/ignores and severities remain unchanged. Consumer tests,
snapshots, tier configurations, dependencies and lockfile are unchanged. All 206
consumer tests, real-file tooling/security fixtures and integrated authoring,
value, orchestration and recipe suites pass. Formatting, ShellCheck and the
changed shell file's shfmt check pass. Whole-script shfmt also reports existing
redirection-spacing differences in the untouched security-fixture script; those
are outside this metadata-only commit.

## Ticket 07 Ecosol and Atlassian migration

As of 2026-10-23, all 57 definitions in this batch satisfy the metadata contract:
Ecosol devtools (5), Forge Ahead (4), Forge scripts (6), Git hooks (7), package
JSON (2), package scripts (15), secrets (8), TypeScript (9), and Atlassian package
JSON (1). Their 491 frozen diagnostics and 57 allowance rows are retired. The
allowance file is now empty; its compatibility machinery remains until ticket 10.
The orchestration regression requires zero findings and zero allowance rows for
both tiers, including future definitions.

### Assessment and evidence review

Every definition cites its actual positive/negative test and match snapshot.
Categories and explicitly selected reference URLs use ticket 02's yq recipes
with previews. Existing notes and source links remain intact. Reference checks
are offline shape validation, not current reachability or authority verification.
The sample-app credo link is preserved as organization-policy context, not a
legal approval or an externally verified mandate.

- No language companions were discovered in these tiers. Similar naming, hook
  and configuration rules have different predicates; they are not assumed to be
  equivalent from their IDs. Each assessment records those differences.
- Biome's explicit settings can differ from effective inherited/override settings.
  A real branch other than main is legitimate; missing a particular exclusion
  spelling does not prove generated files are processed. Vitest defaults globals
  to false: requiring an explicit declaration is a team convention, not proof
  that ambient globals are enabled. These policies have low impact.
- Forge Ahead dependency checks do not establish helper use, production placement
  or deployable identity. Tests for errors/logging deliberately flag express-only
  packages too. Equivalent error handling, types or redaction can exist without
  the preferred package. Direct console calls violate the stated team convention,
  but a tested startup literal is not sensitive or verbose logging. None of these
  checks establishes substantial resource consumption or credential disclosure.
- Forge wrapper names concern discoverability, not consent, encryption or correct
  targets. Most presence branches search descendant keys rather than validating
  script implementation. Install excludes literal --upgrade; upgrade requires it.
  The variable wrapper explicitly accepts a legacy implementation. Those are
  distinct naming predicates, not configuration-resolution checks.
- Hook-name regexes cannot establish run contents, skip/filter behavior or actual
  installation. Format/typecheck support invoked lint-group delegation; the size
  rule instead requires a specific pre-push.commands run shape and can flag valid
  jobs/wrapper alternatives. Gitleaks alone receives high conditional impact:
  a real staged credential escaping the intended guard can enter history and
  require revocation. Missing a key does not establish that event or the absence
  of other secret scanning.
- Package-script checks cannot validate filesystem inputs, compiler/coverage
  providers or successful execution. The composed-check matcher accepts missing
  force despite the note's recommendation. Global ignore rules and source-only
  scans can replace an explicit node_modules flag; alternate orchestration can
  run all checks. Tool preference, naming, coverage and hook setup are not promoted
  to security impact. Real stale placeholders, missing build output and interactive
  tests in noninteractive guards can instead cause bounded delivery failures.
- The Node rule checks a literal types version and engines, not .nvmrc or manifest
  runtime. The nvm source does not establish a blanket engines deployment ban;
  metadata records that authority gap. ESM mismatch has medium conditional impact
  for tools relying on ESM, not a claim that CommonJS itself is unsupported.
  Apache-2.0 consistency is bounded release/compliance risk, not a security flaw;
  the matcher cannot compare LICENSE text or determine legal applicability.
- Typecheck options may already be inherited. Unlike outDir's explicit extends
  backoff, the typecheck flag matchers do not follow or exempt inheritance. Test
  directory existence/custom layouts and CLI overrides remain assessment gaps.
  Bracket-notation/override intent is primarily maintainability; absent-entry,
  return, optional-property and side-effect-import checking can prevent bounded
  functionality errors when relevant code exists. No specific runtime bug is
  proven by missing a flag.
- Fence Rider is a team implementation choice, not a Forge or OWASP requirement.
  Supported direct commands and maintained alternatives routinely need context;
  even an encrypted upload matches the variable migration check. No wrapper alone
  isolates credentials, redacts output or authorizes remote changes. Failure-status
  masking and generation-without-execution concern bounded workflow false success,
  not untrusted code injection. Bare generation can intentionally print reviewed
  text; pipefail mentions do not establish effective shell state. Actual shell
  behavior, input values and downstream handling remain assessment gaps.

No new OWASP/CWE mappings or exact module tags are justified for this batch's
convention signals. The existing OWASP agent-data-protection links remain useful
context without making the chosen wrapper a security requirement. Untested
limitations above remain assessment gaps, not invented coverage.

### Reviewed legacy scope

All 57 deliberately retain `[unique]`; ticket 08 owns scope/routing changes:

- Thirty-five package rules select package.json and exclude only node_modules.
  Tests and dist/coverage/specs packages remain in scope, not the shared baseline.
- Four Biome rules select biome.json/biome.jsonc; seven hook rules select only
  lefthook.yml; one Vitest rule selects vitest.config.ts. Each excludes only
  node_modules and retains test-local/generated configurations. These artifacts
  have no standard selector; alternate filenames are not silently added.
- Nine TypeScript rules select tsconfig.json (one) or tsconfig.typecheck.json
  (eight), with node_modules-only exclusions and test-local configs included.
- The console convention selects resolvers/external/import-lifecycle and
  src/index.ts, not every standard backend directory. It excludes node_modules
  and only .test.ts/.spec.ts, not the complete baseline/test-directory sets.

Inline rationales state the actual legacy deviations rather than inferring a
standard profile from an artifact name or parser.

### Advisory severity differences

No current severity changes. Ticket 09 owns these 28 differences; the other
29 definitions already agree with the candidate matrix:

| Definitions                                                  | Precision | Impact | Current | Candidate |
| ------------------------------------------------------------ | --------- | ------ | ------- | --------- |
| Biome settings and explicit Vitest globals (5)               | medium    | low    | warning | info      |
| Direct console convention (1)                                | high      | low    | warning | info      |
| Forge Ahead dependency preferences and Node types pin (4)    | medium    | low    | hint    | info      |
| Commit/push format and push-size guards (3)                  | medium    | low    | warning | info      |
| Forge lint wrapper (1)                                       | medium    | medium | info    | warning   |
| Script naming and explicit watch conventions (2)             | high      | low    | hint    | info      |
| Hook prepare, Prelint config and coverage scripts (3)        | medium    | low    | warning | info      |
| Prelint node_modules flag (1)                                | medium    | low    | hint    | info      |
| Bare Fence Rider generator review (1)                        | low       | medium | warning | info      |
| Local outDir (1)                                             | medium    | low    | error   | info      |
| Exact optional properties (1)                                | medium    | medium | hint    | warning   |
| Typecheck extends/noEmit and organization license (2)        | medium    | medium | error   | warning   |
| Implicit returns, indexed access and side-effect imports (3) | medium    | medium | info    | warning   |

### Verification

The user confirmed authoring output/exit status, metadata-document contracts and
unchanged consumer behavior as public TDD seams. The retained regression failed
on 491 frozen findings, then on stale allowance rows, then passed after removal.
Nine category slices failed on copied unallowlisted originals and passed after
metadata edits. Frozen-allowance compatibility tests now use an isolated repository
fixture instead of keeping a real rule unmigrated; exact path, source digest and
new-diagnostic rejection remain tested through the unchanged public checker.

All 57 parsed documents excluding metadata equal their pre-migration versions.
IDs, parsers, matchers, utilities, fixes, messages, notes, files/ignores and
severities remain unchanged. Consumer tests, snapshots, tier configurations,
dependencies and lockfile are unchanged. All 206 consumer tests, real-file
tooling/security fixtures, six native authoring tests and the value, orchestration
and recipe suites pass, with zero frozen findings. Repository Prettier, ShellCheck,
changed-shell shfmt and git diff --check pass. Scope normalization, severity
application and removal of the compatibility machinery remain later-ticket work.

## Ticket 08 native scope normalization

The [native scope routing reference](rule-scope-routing.md) records approved
coverage changes, permanent custom boundaries, category progress and real-file
scanner evidence. Historical legacy-scope descriptions above describe their
metadata-only stages, not permanent exceptions to the shared baseline.

## Ticket 09 severity enforcement

On 2026-10-23 the maintainer approved all 93 differences in the complete
206-definition preview: two warning-to-error promotions, 44 error demotions and
47 nonblocking changes. The [severity reference](rule-severity.md) records the
transition counts, approval basis, native report/edit/checker contracts and
actual blocking/all-severity scanner behavior. Earlier advisory tables are
historical migration-stage evidence, not unresolved severity overrides.

The shared matrix, explicit idempotent yq recipe and repository enforcement were
developed test-first at approved public seams. All nine matrix cells, disabled
preservation, malformed rating rejection, non-mutating complete reports,
stale-declaration failure/repair and real gate outcomes have retained regressions.
Only severity changes in shipped definitions; scope, ratings, matchers, fixes,
prose, snapshots, configurations and dependencies remain unchanged. The
empty allowance ledger and its compatibility machinery remain ticket 10 work.

Verification passed: all 206 consumer tests, 206-definition routing across four
shipped tiers, scaffold/Biome/security fixtures, six native authoring tests,
value/orchestration/metadata-recipe/scope-composition/severity suites, and the
repository checker with zero frozen findings. Prettier, ShellCheck, changed-shell
shfmt and `git diff --check` pass. Parsed non-severity documents equal their
pre-rollout versions; the final rule diff is 93 one-line severity replacements.

## Model references

- [ast-grep rule configuration](https://ast-grep.github.io/reference/yaml.html)
- [ast-grep lint rules](https://ast-grep.github.io/guide/project/lint-rule.html)
- [ast-grep scan CLI](https://ast-grep.github.io/reference/cli/scan.html)
