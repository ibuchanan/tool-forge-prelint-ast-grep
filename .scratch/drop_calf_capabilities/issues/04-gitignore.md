# 04: Establish honest static coverage for managed gitignore conventions

**What to build:** Maintainers get a verified answer about which Drop Calf ignore conventions Forge Prelint can actually check, with a working native rule only if a supported parser can represent the artifact reliably. An unsupported capability remains an explicit coverage gap, not a fabricated green check.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** completed (2026-10-25); unsupported native-parser coverage disposition.

**Capability:** gitignore

**Coverage today:** No existing rule checks Git ignore files. Biome exclusions are a different capability and must not be mislabeled `capability:gitignore`.

**Source convention:** Drop Calf seeds a gitignore.io topics block and a drop-calf additional-ignores block. Markers use Created by / End of source comments. Additional ignores include scratch, session, temporary and tool cache paths. Update replaces only existing owned blocks, preserves outside bytes and deliberately does not restore absent blocks. Git acceptance does not prove desired paths are ignored.

- [x] Run a bounded feasibility test using the repository's installed ast-grep languages and routing support on real ignore-file content, including comments, negation, wildcard and slash syntax. Do not treat the file as YAML/JSON or introduce a new parser/plugin merely for this ticket.
- [x] If supported, deliver one useful rule for malformed owned marker pairing in an existing block, tagged `capability:gitignore`, with passing generated content and failing missing-end/nested-marker examples. Do not require whole-file template equality or a mandatory block that update intentionally does not restore. **Conditional branch evaluated: unsupported; no rule added.**
- [x] If unsupported, publish a tested coverage-gap disposition instead of a non-executable rule: record the parser limitation, the owned-marker and preserve-outside-block conventions, and that Drop Calf update is the existing owner of reconciliation. This is an accepted completion path for the ticket.
- [x] Keep effective ignore evaluation, negation ordering, tracked-file status and missing-file detection outside ast-grep claims. Do not introduce a separate repository auditor or silently widen the scope into an ignore engine.
- [x] Make capability coverage reporting distinguish implemented checks from this explicit unsupported/gap result; never add an inert placeholder just to expose a tag.

**Boundary:** This is the only intentionally feasibility-led slice; it must end with either runnable evidence or an explicit limitation. The shared definition of done applies.

## Implementation record — 2026-10-25

### Selection and agreed public seams

Ticket 01 and lower-numbered tickets 02–03 are complete. Ticket 04 was therefore
the lowest-numbered dependency-ready ticket. The user approved these public test
boundaries before tests were written:

- Installed ast-grep parser support and real `.gitignore` file routing, including
  comments, negation, wildcards, slashes and malformed owned markers.
- Capability discovery/reporting, distinguishing implemented mappings from this
  explicit unsupported disposition without a placeholder rule.

The user also approved a durable reference document for the unsupported result.

### Red–green evidence

1. Added the public coverage-report regression first. It failed with exit 127
   because `scripts/report-capability-coverage.sh` did not exist. Added the small
   read-only report and explicit `capability-coverage-gaps: [gitignore]` policy;
   the unsupported row then passed, while existing package metadata mappings
   remained discoverable.
2. Added installed-CLI feasibility probes and a TypeScript positive control.
   `gitignore`, `ignore` and `text` are unsupported languages in ast-grep 0.51.0.
   Native routing produces `[]` for generated ignore content, missing-end and
   nested-marker variants even with explicit paths, hidden/VCS overrides and an
   inclusion glob. The positive control produces matches. An initial routing
   harness failure exposed ast-grep's no-match exit 1; the harness now accepts
   only success/no-match exits and separately asserts empty-array output.
3. Added an isolated report regression for disabled rules and conflicting
   gitignore tags. It failed first because a disabled placeholder was accepted.
   Changed report conflict detection to reject any rule claiming an explicitly
   unsupported capability, including `off`, before emitting TSV. Both `off` and
   active conflicts now fail with the intended error and no partial report.

Evidence is retained under `.scratch/tmp_rovo_ticket04_*` and
`.scratch/tmp_rovo_gitignore.*`. The checks run in the standard authoring suite.
No consumer matcher, tag, severity, scope, snapshot, tier or package dependency
was changed.

### Disposition and ownership limits

The durable [capability coverage reference](../../../docs/reference/capability-coverage.md)
records parser/routing evidence and reviewed Drop Calf revision
`be86d05309a32f7eef8988205208c17ca94e7a4c`, with links to its Gitignore capability,
template and ownership tests. Bash/Markdown do not model Git ignore syntax;
YAML/JSON coercion and parser plugins were not introduced.

Drop Calf owns marker pairing and reconciliation: update replaces only existing
owned blocks, respects their recorded topics, preserves outside bytes and line
endings, and intentionally does not restore missing blocks or files. No native
ast-grep check is claimed. Effective ignore evaluation, ordering, tracked paths,
missing files and full policy correctness remain outside coverage. Biome settings
are not relabeled as gitignore checks.

`bash scripts/report-capability-coverage.sh` reports every recognized capability:
active tagged checks are `implemented` (not complete compliance), unmapped
conventions are `not-mapped`, and gitignore is explicitly `unsupported`. A
conflicting tag, including an inert disabled placeholder, fails the report.
The report reads rule metadata; it is not a new repository auditor or ignore
engine. Future native parser/routing support triggers a reassessment failure.

### Verification and commit

- `bash scripts/test-capability-coverage.sh`: all five reporting/feasibility
  groups passed, including disabled-rule and no-partial-report assertions.
- Full `bun run test`: exit 0; all 205 consumer suites and six authoring suites
  passed, along with generated/mutated fixture checks, security/page-title
  checks, four-tier scope routing, metadata recipes, severity/consumer gates,
  scope composition and the actual packed-package boundary.
- `bun run format:check`, changed-shell ShellCheck/shfmt, `git diff --check`, and
  independent read-only review passed. The tracked scratch ticket is explicitly
  formatted and checked separately.

This ticket update is included with the implementation in the Conventional Commit
`feat(coverage): Record unsupported gitignore checks`.

Ticket 05 (node) is next under dependency-ready/lowest-number ordering. No push,
remote publication, deployment, release or secrets resolution was performed.
