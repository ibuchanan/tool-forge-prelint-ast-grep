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

## Prelint: task, configuration and exclusion text

Five ecosol rules map to `capability:prelint`:

| Rule                                | Coverage                                                                                                                                    |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `lint-with-prelint`                 | Direct root `scripts.lint:check:prelint` string presence; no command execution.                                                             |
| `lint-with-forge`                   | Recognizable root `lint:check:forge` command text; retains the separate `capability:forge-manifest` mapping.                                |
| `require-valid-prelint-config`      | A literal `--config` reference to a shipped recommended, strict, atlassian or ecosol sgconfig filename; dependency aliases remain accepted. |
| `require-prelint-node-modules-glob` | Existing bounded single-quoted dependency exclusion convention.                                                                             |
| `require-prelint-specs-glob`        | Independent advisory for a missing single-quoted specifications exclusion in a direct root Prelint task.                                    |

The reviewed source is the
[Prelint capability at `be86d05309a32f7eef8988205208c17ca94e7a4c`](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/src/capabilities/prelint.ts).
It maintains `lint:check:prelint` as `ast-grep scan --globs '!specs/**' --globs '!node_modules/**' --config ./node_modules/@forge-ahead/prelint/sgconfig.ecosol.yml`
and `lint:check:forge` as `forge lint`. The lint capability owns orchestration;
Prelint tags do not establish inclusion in an aggregate or app identity.

The new specs check accepts `!specs`, `!specs/` and `!specs/**`, optionally
prefixed with `**/`, as standalone single-quoted `--globs` arguments. Positive
globs, single-star patterns, directory lookalikes and flag/argument suffixes do
not satisfy it. Config and both exclusion checks retain legacy `lint:prelint`
validation; only the current name satisfies task presence. Unrelated task names
are not required to carry these flags. The specs advisory is informational, with
medium precision and low impact: effective equivalent workflows require review and
possible suppression, not an inference that all excluded files are being scanned.

Command text does not prove config existence or contents, tool installation,
current dependency versions, shell evaluation, successful scanning or project-wide
coverage. Ignore files, source-only scans, external helpers, alternative quoting,
escaped JSON spellings and later overriding flags are not resolved. Scope remains
existing `package.json` files in caller-selected app directories, excluding
node_modules, dist, coverage and specs. Missing files cannot be diagnosed.

Static tests apply the two pinned task literals to a temporary copy of the older
generated fixture and mutate config, exclusion, alias and task names. The stored
generated fixture is unchanged; the legacy zero-findings fixture gains only the
specs exclusion. No package task, Forge lint, secret resolution or deployment is
executed, and the separate Fence Rider policy from the secrets slice is unchanged.

## Biome: maintained tasks and owner-managed configuration

Six existing rules map to `capability:biome`; this mapping changes no matcher,
ID, native scope, tier, precision/impact rating, severity or consumer snapshot.

| Rule                                   | Coverage                                                        |
| -------------------------------------- | --------------------------------------------------------------- |
| `lint-and-format-with-biome`           | Named Biome tasks and npm/Bun `format:check` delegation.        |
| `no-write-flags-in-readonly-script`    | Shared guard against write-back flags in read-only check tasks. |
| `require-biome-files-exclude-dist`     | Reviewed default exclusion spellings in `files.includes`.       |
| `require-biome-formatter-indent-style` | Reviewed `space` indentation default.                           |
| `require-biome-vcs-default-branch`     | Reviewed `main` comparison baseline default.                    |
| `require-biome-vcs-use-ignore-file`    | Reviewed VCS ignore integration default.                        |

The reviewed source is the
[Biome capability at `be86d05309a32f7eef8988205208c17ca94e7a4c`](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/src/capabilities/biome.ts).
It maintains `format`, `format:check`, `lint:check:biome`, `lint:check:format` and
`lint:fix`. The shared read-only guard materially checks Biome's formatting/lint
task convention without claiming exclusive ownership: it also checks other tools
and aggregate gates. The lint capability owns orchestration; this slice does not
change its mapping.

Configuration and EditorConfig are seeded, then owner-managed. Drop Calf update
lets Biome migrate an existing root config rather than restoring template values;
native validation loads the config and references, not source quality. The four
config checks are informational team-default advice, not immutable Drop Calf or
Biome requirements. Intentional tabs, another real default branch, inherited
settings or equivalent source-only/exclusion policies warrant review and
suppression of the corresponding rule, not overwriting owner configuration.
No new rule freezes a schema version, dependency pin, recommended preset,
overrides, vendor/specs exclusion or EditorConfig contents.

Both `biome.json` and `biome.jsonc` use the existing native filename routes.
Static fixtures verify the generated task family, npm/Bun delegation, separate
write-back commands, both config routes, schema-version independence and isolated
mutations. Command text does not prove shell behavior, tool installation or task
success. Effective inherited configuration, schema validity and tool acceptance
remain Biome responsibilities; missing files cannot be reported. No formatter,
linter, migration or generated package task is executed by these checks.

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

## Release: explicit package entrypoints

Two informational ecosol rules are tagged `capability:release` and inspect only
existing `package.json` files selected by the caller for Forge apps:

| Rule                           | Recognized convention                                                                                                                                                      |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `require-release-script`       | Direct root `scripts.release` string invoking `bash scripts/release.sh`; ordinary spacing and an optional `./` path prefix are accepted. No helper arguments are accepted. |
| `require-release-check-script` | Direct root `scripts.release:check` string with a recognizable command start, excluding empty, echo/printf, no-op/exit, comment-only and placeholder starts.               |

The reviewed source is the
[Drop Calf release capability at `be86d05309a32f7eef8988205208c17ca94e7a4c`](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/src/capabilities/release.ts).
It maintains `release` and the Bash helper, seeds `release:check` with
`npm run test && npm run typecheck` for Forge apps, and supplies that check only
when missing on update. Owner-defined validation commands and extensions are
accepted without requiring the seeded text, fixed task names, `pack:check`, a
version, a tool pin or changelog policy. Git-cliff command ownership remains with
the changelog capability; generic lifecycle and placeholder rules are not tagged
as release rules.

The entrypoint matchers are bounded text checks, not shell interpreters. Quoted
helper paths, wrappers, environment assignments and chaining in `release` need
review and possible suppression. Logging-first validation commands also need
review, even when later commands perform checks. A command-like string can pass
without existing, succeeding or actually validating anything; arbitrary shell
syntax, escaped JSON spellings, aliases and disguised no-ops are not resolved.
Suppression of an equivalent owner workflow does not establish release safety.

| Artifact or result                    | Coverage boundary                                                                                                                                          |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Existing package entrypoints          | Direct root strings and recognizable text only; unrelated nesting, wrong types, inert echoes and helper lookalikes do not satisfy the convention.          |
| Helper presence and contents          | No missing-helper detection or shell inspection. Branch guards, clean-worktree guards, argument handling and atomic-push semantics are outside this slice. |
| Owner-check preservation              | Native Drop Calf update behavior; the matcher accepts owner commands but does not observe or prove an update cycle.                                        |
| Validation execution                  | No task existence, checks execution, pass/fail, prerequisites or tool installation is inferred.                                                            |
| Versioning, Git state and publication | No version changes, commits, tags, worktree cleanliness, remote access or atomic publication is inferred from local script text.                           |

Tests scan static package strings and mutations only. The stored generated
Drop Calf fixture predates release wiring and remains unchanged; the fixture
check applies the two exact package commands from the pinned capability to a
temporary copy. The legacy zero-findings fixture includes those declarations but
intentionally has no release helper, demonstrating that script presence does not
prove helper existence. No release workflow, helper, check command, git-cliff or
remote publication is executed during verification.

## Secrets: lifecycle command text and native validation

The reviewed source is the
[Drop Calf secrets capability at `be86d05309a32f7eef8988205208c17ca94e7a4c`](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/src/capabilities/secrets.ts).
It maintains six root package scripts. Twelve existing ecosol rules are tagged
`capability:secrets`: six `use-forge-*` naming checks, four lifecycle wrapper
preferences (deploy, install/upgrade, uninstall and variables), and the two
Fence Rider execution-safety checks. IDs, tiers and severities are preserved.
The naming checks remain informational, medium precision and low impact;
wrapper preferences are advisory, not Forge platform requirements.

| Script                | Maintained command                                                                              |
| --------------------- | ----------------------------------------------------------------------------------------------- |
| `forge:register`      | `forge register`                                                                                |
| `forge:deploy`        | `cmd=$(fence-rider deploy -- --non-interactive) && sh -c "$cmd" sh`                             |
| `forge:install`       | `cmd=$(fence-rider install -- --confirm-scopes --non-interactive) && sh -c "$cmd" sh`           |
| `forge:uninstall`     | `cmd=$(fence-rider uninstall) && sh -c "$cmd" sh`                                               |
| `forge:upgrade`       | `cmd=$(fence-rider install -- --upgrade --confirm-scopes --non-interactive) && sh -c "$cmd" sh` |
| `forge:variables:set` | `fence-rider variables`                                                                         |

The naming checks require a direct root `scripts` string containing recognizable
command-role text. Wrong names, missing scripts, wrong types, unrelated nesting
and command lookalikes do not satisfy that convention. Install and upgrade are
separated by a bounded `--upgrade` token; options may appear in either order.
Direct Forge lifecycle commands still satisfy naming, but trigger the separate
wrapper preference. The legacy variable-upload helper is accepted for naming
and remains subject to the variable wrapper preference. These are text checks,
not shell parsers: quoted/inert mentions, additional commands, JSON escape
spellings, arbitrary helpers and effective CLI options require native validation
or review and possible suppression. Callers select Forge-app packages; no app
identity, installation, flag validity, consent, target or execution is inferred.

`use-fence-rider-for-forge-lint` exempts only the root `lint:check:forge` value
`forge lint` with ordinary whitespace. That reviewed exception reflects Drop
Calf's maintained direct validation task; flags, wrappers, chaining and other
script names retain the preference. The rule's advisory severity and ratings
are unchanged. Presence of the lint task and Prelint configuration remain
separate policies. The lint and tunnel preferences are not tagged as required
secrets coverage; no tunnel task or SecretSpec values are required by this subset.

`require-fence-rider-script-execution` detects bare generator-only commands;
`no-unguarded-fence-rider-evaluation` detects direct eval/shell substitutions,
simple shell pipes and the literal root `cmd=$(fence-rider ...); sh -c "$cmd"`
form (including eval/bash/zsh variants). Guarded `&&` capture remains accepted.
Other variable names, conditionals, escaped or compound shell forms, redirection,
pipefail mentions and external helpers retain the documented limits of those
rules. Neither matching command text nor a zero-findings scan proves failure
propagation for arbitrary shell programs.

| Artifact or result                    | Coverage boundary                                                                                                                     |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `secretspec.toml` syntax and schema   | Native TOML parsing and structural validation by Drop Calf/SecretSpec; no YAML surrogate matching.                                    |
| Profile/scope membership              | Native validation checks declared default-profile members, scopes and supported declaration shapes without resolving values.          |
| Owner declarations and tool reference | Owner-managed; no required real values, dependency pin or missing-file detection.                                                     |
| Encryption and credential isolation   | Not proved by script text; no values are resolved, credentials read or uploads inspected.                                             |
| Effective command behavior            | Forge/Fence Rider execution, prerequisite environment, forwarded options, exit status and remote success remain native-tool concerns. |

The stored generated fixture predates forwarded flags and is unchanged. The
static fixture check applies the six pinned command literals to a temporary
package copy, verifies the convention subset, and mutates missing/wrong-role,
wrong-type, nested/lookalike commands, missing execution, unguarded evaluation
and direct lifecycle commands. Tests never execute the package scripts, resolve
SecretSpec, read real credentials or contact Forge.
