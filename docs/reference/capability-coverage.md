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
