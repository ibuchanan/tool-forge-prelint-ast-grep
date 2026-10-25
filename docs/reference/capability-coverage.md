# Capability coverage

Capability tags describe convention ownership or material relevance. They do not
route files, detect installed capabilities, or prove full capability compliance.
The vocabulary and explicit coverage gaps are recorded in
[`authoring/policy.yml`](../../authoring/policy.yml).

## Coverage report

`bash scripts/report-capability-coverage.sh` emits read-only TSV with one row per
recognized capability, in policy order:

| Column       | Meaning                                                                                |
| ------------ | -------------------------------------------------------------------------------------- |
| `capability` | Exact Drop Calf capability name.                                                       |
| `status`     | `implemented`, `not-mapped`, or `unsupported`, as defined below.                       |
| `rule-ids`   | Sorted, comma-separated active rule IDs carrying that capability tag; empty when none. |

- **implemented:** At least one active rule is tagged for the capability. This is
  a mapping, not a claim that every convention is checked. Disabled rules are not
  implemented coverage. For example, the Node package-license mapping alone does
  not establish a checked Node runtime or type-dependency baseline.
- **not-mapped:** No active rule has this tag and no unsupported disposition is
  recorded. Existing untagged checks may apply; this is not a parser diagnosis.
- **unsupported:** A reviewed parser/scope limitation is explicitly recorded.
  No rule, even disabled, may claim that capability; conflicting tags fail the report
  without publishing partial TSV. An empty rule list is not a passing scan.

The report does not scan an app, audit a repository, or replace native tools.
[`scripts/test-capability-coverage.sh`](../../scripts/test-capability-coverage.sh)
checks reporting, installed parser support, and real-file routing as part of the
standard authoring suite.

## Gitignore: unsupported

**Disposition:** No native Git ignore parser or consumer rule. No placeholder or
`capability:gitignore` tag is added. Biome exclusions and Git-ignore integration
settings are separate conventions, not Git ignore-file validation.

### Installed parser and routing evidence

The bounded feasibility assessment used ast-grep **0.51.0**, the repository's
installed CLI, on the generated
[`fixtures/drop-calf-forge-app/.gitignore`](../../fixtures/drop-calf-forge-app/.gitignore).
It included managed comments plus owner examples of negation (`!keep/`), wildcards
(`**/*.tmp`), anchored slashes (`/root-only/`) and escaped leading `#`/`!`.

- The installed CLI's `completions fish` language description lists built-in
  languages, with no Git ignore or generic text language.
- Explicit `run --lang gitignore`, `--lang ignore`, and `--lang text` probes reject
  the language as unsupported, even with real file bytes supplied on stdin.
- A native catch-all `run --pattern '$A'` produces no matches for the existing
  `.gitignore`, a missing-end example, or nested owned markers. Explicit input,
  hidden/VCS-ignore overrides and an inclusion glob do not supply a grammar.
  A TypeScript positive control matches with the same ignore overrides.
- Bash represents ignore entries as commands; Markdown represents marker comments
  as headings and ignore entries as prose. Neither models Git ignore syntax.
  Those grammars are not used as substitute validators. YAML/JSON coercion and
  new parser plugins are excluded.

Zero diagnostics therefore establish **no coverage**, not marker validity or
compliance. The retained feasibility checks intentionally require reassessment if
native language/routing support changes. They do not evaluate ignore patterns.

### Managed-block ownership

The reviewed source is Drop Calf revision
`be86d05309a32f7eef8988205208c17ca94e7a4c`:

- [Gitignore capability](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/src/capabilities/gitignore.ts)
- [Additional-ignore template](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/templates/gitignore/.gitignore)
- [Ownership and malformed-marker tests](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/tests/capabilities/gitignore.test.ts)

Initialization seeds two owned blocks: selected gitignore.io topics and
`drop-calf additional ignores`. The additional defaults include scratch, session,
temporary and tool-cache paths; their literal contents remain Drop Calf's policy.
Opening `# Created by <source>` and closing `# End of <source>` markers must pair
in order with the same source. Drop Calf rejects unmatched ends, missing ends and
nested owned markers; other creators' comments are owner content.

Drop Calf update replaces only existing owned blocks, uses their recorded topics,
and preserves bytes outside them, including owner patterns and line endings.
It does not restore removed blocks or a missing `.gitignore`. Explicit
initialization/copy can seed absent blocks. Reconciliation and marker errors stay
with Drop Calf, not a second Forge Prelint auditor. Its native validation is a
no-op: Git accepting a file does not establish the intended ignore policy.

Effective path ignoring, negation ordering, tracked-file status, missing files,
and desired policy remain outside ast-grep claims. Git's native behavior is
described in the [gitignore reference](https://git-scm.com/docs/gitignore).
No ignore engine, cross-file check, or mandatory-template equality is supplied.

## Node: package policy with artifact gaps

`use-node-24` retains its legacy ID but checks only the absence of a direct root
`engines` field in an existing `package.json`. It is an informational ecosol
convention for caller-selected Forge-app directories, not a runtime-version check
or a policy for library packages. Nested `engines` fields are owner data. Escaped
JSON key spellings can be missed by the key regex.

The reviewed Drop Calf revision is
`be86d05309a32f7eef8988205208c17ca94e7a4c`:

- [Node capability](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/src/capabilities/node.ts)
- [Forge-app profile](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/src/composition/profiles.ts)
- [Node ownership tests](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/tests/capabilities/node.test.ts)

The Forge-app profile uses `nodeBaseline({ engines: "remove" })` without an
explicit type major. Initialization seeds `@types/node`; update refreshes existing
declarations and does not restore owner-removed dependencies. Type presence,
dependency placement, exact versions and semver compatibility are intentionally
unchecked. A refreshed declaration or its absence does not select a Node runtime.
Other profiles can explicitly constrain a major or preserve `engines`; those
options are not this Forge-app policy.

| Artifact or relationship                      | Coverage boundary                                                                                                                                                                                                           |
| --------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `package.json` root `engines`                 | Checked by `use-node-24`; any value is a finding. npm's [engines reference](https://docs.npmjs.com/cli/v11/configuring-npm/package-json/#engines) describes compatibility metadata, not a blanket Forge deployment failure. |
| Numeric `.nvmrc` (seeded at Node 24)          | Separate artifact gap: no supported native version-file parser demonstrated. Parsing a number as JSON would not validate runtime selection. Drop Calf owns its update.                                                      |
| Public-registry `.npmrc`                      | Separate artifact gap: no supported native npm-configuration parser demonstrated. JSON/YAML coercion is not npm configuration validation. Drop Calf replaces the whole file with its registry convention.                   |
| `.nvmrc` and Forge manifest runtime agreement | Cross-file reconciliation owned by Drop Calf's Node and Forge-manifest capabilities; not proved by this JSON rule.                                                                                                          |
| Catalog-derived package licensing             | `require-package-license-apache-2-0` is independently tagged for Node and OSS. Drop Calf derives the package value from the catalog; separate literal checks do not prove equality or derivation across files.              |

Missing files, host Node selection, installation, effective registry resolution,
and runtime/deployment compatibility remain outside the check. Node remains
`implemented` in the coverage report because active package checks exist; the
artifact gaps do not mark the whole capability unsupported. No parser plugin,
file-existence auditor, semver regex, host version change or Node download is
introduced.

## Forge manifest: runtime shape and native lint entrypoint

`require-numeric-forge-runtime` checks the direct root `app.runtime.name` path in
existing `manifest.yml` and `manifest.yaml` files. It accepts literal
`nodejs<major>.x` values with a positive numeric major and no leading zero,
including plain, single-quoted and double-quoted scalars in block or flow mappings.
It reports one informational finding for a missing or malformed declaration in
nonempty files, including whitespace-only and comment-only inputs. Native scans
skip zero-byte files; zero findings there do not establish compliance. Unrelated
or nested `runtime` and `name` fields do not satisfy the path. Owner-selected app
identity, modules, scopes, handlers, memory and architecture are not checked.

This is a Drop Calf convention, not a list of supported Forge runtimes. A numeric
future or retired version can pass. Current platform values and runtime semantics
remain defined by the [Forge manifest reference](https://developer.atlassian.com/platform/forge/manifest-reference/#runtime)
and [Node.js runtime guide](https://developer.atlassian.com/platform/forge/function-reference/nodejs-runtime/).
YAML aliases, merges, tags, escape-encoded or block scalars, duplicate keys and
multi-document schema validity require native validation; this rule does not
resolve YAML values or validate the entire schema.

The reviewed source is the
[Forge-manifest capability at `be86d05309a32f7eef8988205208c17ca94e7a4c`](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/src/capabilities/forge-manifest.ts).
It converts a numeric `.nvmrc` pin, optionally prefixed by `v` and including minor
or patch components, into `nodejs<major>.x`. Update reconciles an existing
`manifest.yml`, preserving app identity and other settings; it does not create a
missing manifest. The static rule also covers the repository's standard
`manifest.yaml` routing, without claiming Drop Calf updates that alternate name.

`lint-with-forge` checks the `lint:check:forge` script's recognizable command text.
Its two tags have distinct meanings: `capability:prelint` supplies that task, while
`capability:forge-manifest` uses native Forge lint for manifest/source validation.
The mapping changes no matcher, rating or routing and does not tag unrelated
manifest/security rules.

| Artifact or relationship                            | Coverage boundary                                                                                                                              |
| --------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| Literal runtime declaration in an existing manifest | Checked locally; syntactic shape does not establish platform support.                                                                          |
| `.nvmrc` agreement                                  | Cross-file reconciliation remains owned by Drop Calf; the two declarations are not compared.                                                   |
| Handler/export and module/resource wiring           | Source and cross-file relationships remain native Forge lint responsibilities.                                                                 |
| Missing manifest or `.nvmrc`, or zero-byte manifest | No file-existence detection, and native ast-grep scans skip zero-byte files; neither absence nor skipped input is passing manifest validation. |
| Credentials and actual Forge lint success           | Consuming-tool execution prerequisites/results, not inferred from package command text or capability tags.                                     |

Tests use static YAML examples, real-file scans and capability reporting only.
No credentials are resolved and no Forge lint, deployment or installation is run.

## Changelog: regeneration entrypoint text

`require-changelog-script` checks a direct root `scripts.changelog` string in an
existing `package.json`. It reports an informational ecosol convention finding
when the bounded direct-command form is absent. Callers select Forge-app package
directories; the `capability:changelog` tag does not detect apps or install tools.
Generic placeholder rules retain their separate ownership and are not tagged.

The reviewed source is the
[Drop Calf changelog capability at `be86d05309a32f7eef8988205208c17ca94e7a4c`](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/src/capabilities/changelog.ts).
Its maintained command is `git cliff --config cliff.toml --unreleased -o CHANGELOG.md`.
Initialization seeds `cliff.toml`, `CHANGELOG.md` and git-cliff; update maintains
the package command and tool pin, not the owner-authored policy or output files.
No fixed release version, commit groups, headings or file contents are enforced.

| Command component       | Recognized literal forms                                                                                                                                             |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Invocation              | Direct `git cliff`, with ordinary space separation.                                                                                                                  |
| Policy                  | `--config cliff.toml`, `--config=cliff.toml`, `-c cliff.toml`, `-ccliff.toml`, `-c=cliff.toml`.                                                                      |
| Selection               | `--unreleased`.                                                                                                                                                      |
| Output                  | `--output CHANGELOG.md`, `--output=CHANGELOG.md`, `-o CHANGELOG.md`, `-oCHANGELOG.md`, `-o=CHANGELOG.md`, or bare `--output`/`-o` using the documented default path. |
| Other supported options | `--offline`, `--tag`/`-t` with an unquoted literal version; required options can appear in any order.                                                                |

The [git-cliff argument reference](https://git-cliff.org/docs/usage/args/) defines
native options and defaults. Echo/lookalike commands, missing required options,
wrong literal paths, prepend variants, shell comments/chaining and inert
`--help`/`--init` commands do not satisfy this rule. Unsupported equivalent forms
such as wrappers, shell quoting, environment assignments, alternate relative
path spellings, other flags and escaped JSON spellings require review and, where
appropriate, suppression of this convention check. The matcher is not a shell
parser or a complete CLI validator; duplicate options and environment-dependent
behavior remain native-tool concerns.

| Artifact or result          | Coverage boundary                                                                                                                |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Existing package entrypoint | Literal direct-command convention only; root scripts nesting and package filename routing are checked.                           |
| `cliff.toml` acceptance     | TOML syntax, Tera templates and release-policy semantics require native git-cliff validation.                                    |
| Git history                 | Repository availability, commit/tag selection and conventional-commit interpretation require native validation.                  |
| Changelog output            | Successful regeneration, equivalence and idempotence require native execution; script text does not prove valid release history. |
| Tool pin and missing files  | No installation, version compatibility, missing-package/config/output detection or cross-file comparison.                        |

Tests scan static package examples and generated-package mutations only. They do
not run git-cliff, regenerate files or mutate Git history. The older repo-init
compliance fixture's prepend script is updated to the maintained command; the
separately generated Drop Calf fixture is unchanged.
