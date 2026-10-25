# Drop Calf forge-app convention tickets

Proposed local backlog: one ticket for each of the **20 required** forge-app capabilities. Optional `aidev` and `evals` are intentionally excluded. No tracker issues or production rule changes are made by this backlog.

## Baseline and evidence

- Drop Calf checkout reviewed: `be86d05309a32f7eef8988205208c17ca94e7a4c`.
- [Profile and capability selection](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/src/composition/profiles.ts).
- [Capability reference](https://github.com/ibuchanan/ranch-rig-drop-calf/blob/be86d05309a32f7eef8988205208c17ca94e7a4c/README.md#capability-reference).
- Each ticket names its source capability; its implementation and tests at this revision are the source of truth, not this repository's older vendored snapshot. Capability implementations use the exact capability name except `node` uses nodeBaseline, `biome` uses biomeToolchain, `test` uses vitestTesting, and `size-limit` uses bundleSize.
- Existing coverage includes the current uncommitted lint namespace changes. Preserve those changes; do not treat their missing capability tags as missing matchers.

## Tag contract and sequencing

Ticket 01 expands the existing metadata tag vocabulary and delivers the first catalog check. The current authoring value checker and metadata recipes accept only `module:*`; changing rule tags alone would fail them. Every other ticket depends on 01, then can proceed independently. Drop Calf's runtime capability order is **not** an implementation dependency graph for these tickets.

Use distinct strings in the existing `metadata.tags` array: `capability:<exact Drop Calf capability name>`, such as `capability:catalog` and `capability:test` (not `capability:vitest`). Tags describe convention ownership/relevance, not routing, severity, dependencies, app detection, or evidence that a capability is installed. Preserve existing module tags. Multiple capability tags are allowed only when the rule materially checks both conventions; explain that relationship. Do not tag every manifest or security rule merely because Drop Calf validates manifests.

The initial capability vocabulary is exactly the 20 required names below. Optional capabilities need a separately reviewed vocabulary expansion. Shared artifacts do not imply shared ownership: package license derives through `node` from a catalog annotation consumed by `oss`; lint aggregate composition belongs to `lint`, while individual tasks belong to their supplying capabilities.

## Shared definition of done

Each ticket is a narrow end-to-end slice: reviewed mapping, necessary rule changes only, metadata, diagnostics, regression evidence, and documented limits.

- First reuse existing rule IDs; if current behavior already covers the agreed convention, add tags only. Do not manufacture another rule to make a ticket look substantial.
- Keep Drop Calf-enforced package policy distinct from seeded/owner-managed defaults. A retained owner customization is not automatically noncompliance. New seed-only recommendations are advisory with an explicit rationale and suppression guidance.
- Preserve IDs, tiers, scope, precision/impact and severity for metadata-only edits. New matchers or behavioral changes need fresh ratings, authoritative references, and review under the existing severity matrix. Keep team conventions in ecosol unless a broader policy is independently justified.
- Rules inspect a single parsed file. They cannot report a file that does not exist, compare catalog/package/manifest values across files, resolve inheritance, perform semver algebra, execute shell safely, prove tool installation, or replace the consuming tool's validation.
- Scope Forge-app package checks at the caller's app directories; tags are not cross-file app detection. New filenames need reviewed native globs and unique scope rationale where appropriate, without inventing categories.
- Add compliant and minimally mutated examples, wrong nesting/lookalikes, and real-file routing evidence for new scopes. Metadata-only slices preserve consumer snapshots. Run focused rule tests, authoring/metadata checks and the existing fixture/package-boundary suites as appropriate. Do not execute deployment, secrets resolution, cleanup, release, hooks, or commits to test static rules.
- A source convention unsupported by a built-in parser gets an explicit coverage-gap disposition; do not disguise plain text as YAML/JSON or add an inert rule solely to carry a tag.

## Tickets

| #                                   | Capability       | Expected work                                                      |
| ----------------------------------- | ---------------- | ------------------------------------------------------------------ |
| [01](issues/01-catalog.md)          | catalog          | Tag vocabulary expansion + new catalog checks                      |
| [02](issues/02-package-metadata.md) | package-metadata | Reuse/tag existing type/private checks                             |
| [03](issues/03-oss.md)              | oss              | Reuse license rule + catalog license input                         |
| [04](issues/04-gitignore.md)        | gitignore        | Bounded parser feasibility and explicit coverage disposition       |
| [05](issues/05-node.md)             | node             | Correct stale Node-type convention; tag existing coverage          |
| [06](issues/06-forge-manifest.md)   | forge-manifest   | Bounded runtime declaration check; explicit cross-file gap         |
| [07](issues/07-changelog.md)        | changelog        | New changelog command convention check                             |
| [08](issues/08-release.md)          | release          | New explicit release entrypoint check                              |
| [09](issues/09-secrets.md)          | secrets          | Reuse wrapper checks; resolve generated lint contradiction         |
| [10](issues/10-prelint.md)          | prelint          | Tag current lint/config/glob checks; specs exclusion gap           |
| [11](issues/11-biome.md)            | biome            | Tag current scripts and config coverage; preserve owner config     |
| [12](issues/12-lint.md)             | lint             | Tag aggregates; validate same-file task selection                  |
| [13](issues/13-test.md)             | test             | Reuse/tag Vitest script and globals coverage                       |
| [14](issues/14-typescript.md)       | typescript       | Tag compiler rules; add typecheck delegate and fix variant scope   |
| [15](issues/15-forge-ahead.md)      | forge-ahead      | Tag existing dependency checks; address placement gaps             |
| [16](issues/16-size-limit.md)       | size-limit       | Reuse/tag size checks; correct outdated hook prose                 |
| [17](issues/17-clean-build.md)      | clean-build      | New dist-only clean command check                                  |
| [18](issues/18-todo.md)             | todo             | Advisory seeded-script check without freezing owner implementation |
| [19](issues/19-docs.md)             | docs             | New docs lint script check, not prose quality enforcement          |
| [20](issues/20-git-hooks.md)        | git-hooks        | Reuse hooks; add pre-push delegation check                         |

All tickets use the local ready-for-agent template, but this is a proposed breakdown for review. Review granularity, genuine blocking edges, and any merge/split requests before implementation. File-artifact names in ticket prose identify user-visible inputs, not prescribed implementation locations.

## Draft validation

Read-only review confirmed 20 issue files for the exact 20 required capabilities, with no optional capability tickets or duplicates. Every ticket has the local template fields and acceptance checklist. The dependency graph has one unblocked foundation ticket and 19 direct dependents, with no cycles or artificial ordering between capability slices. Existing-rule references and known conflicts were checked against the current working tree; source conventions were read from the pinned external Drop Calf checkout. Unsupported parser, cross-file and runtime claims are explicitly excluded. This validates the ticket drafts, not implementations that have not yet been written.
