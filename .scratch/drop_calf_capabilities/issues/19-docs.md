# 19: Check the maintained documentation lint entrypoint

**What to build:** An existing Forge app package receives an actionable diagnostic when its docs lint entrypoint omits Markdown linting or spelling checks, and the rule is discoverable as `capability:docs` without attempting to judge prose quality with AST matching.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** completed

**Capability:** docs

**Coverage today:** There is no consumer rule for lint:docs or the Markdown/CSpell toolchain. Generic lint composition does not cover this script; it is outside the generated lint:check namespace.

**Source convention:** Drop Calf maintains lint:docs combining markdownlint-cli2 and cspell lint across quoted Markdown globs. It seeds both tools, Markdown/spelling configs, development guidance, Diátaxis folders and spec starters. Documents and config are owner-managed after init. Native validation loads configs/references without linting content and distinguishes both configs absent from a partially missing pair.

- [x] Add a root scripts.lint:docs check for the two read-only documentation tools with quoted Markdown glob arguments and fail-fast sequencing, accepting the generated command and narrowly supported equivalents. Reject missing/non-string/inert/nested and one-tool-only scripts.
- [x] Tag the rule `capability:docs` and ground diagnostics in the maintained command rather than assuming every document is spelled or formatted correctly because it exists.
- [x] Do not rename it to lint:check:docs or require inclusion in the default lint aggregate: that would change the upstream convention, not check it. Explicitly record the current aggregate coverage gap for a separate upstream decision.
- [x] Preserve owner dictionaries, Markdown rule choices, starter documents and prose. Do not impose byte-identical document templates or content-quality checks beyond the selected tools.
- [x] Add generated and mutated package fixtures and test quoted-glob/lookalike boundaries. JSONC configs are parsable in principle, but presence of the companion file and resolution of references are cross-file/native-tool responsibilities; do not add a fake pair-existence AST rule.
- [x] Run focused rule/authoring/routing checks without executing owner documentation commands or resolving external configuration.

**Boundary:** The ticket covers a usable single-file entrypoint, not missing-document detection, spelling correctness or Diátaxis content classification. The shared definition of done applies.

## Completion update — 2026-10-25

- Selected by dependency order: 01 was complete; 19 was the lowest-numbered ready ticket. Reviewed the capability and tests at `be86d05309a32f7eef8988205208c17ca94e7a4c` in the external Drop Calf checkout, not the older vendored source.
- Added `lint-with-docs`, an ecosol informational rule with reviewed medium precision/low impact and `capability:docs`. It checks a direct root `scripts.lint:docs` string for the maintained `markdownlint-cli2 "**/*.md" && cspell lint "**/*.md"` command; bounded equivalents permit ordinary spacing, independently single/double-quoted globs and optional `./` prefixes.
- Missing/non-string/nested/inert/one-tool-only scripts, unquoted or lookalike globs/tools, non-fail-fast separators, fix/help flags, trailing comments and error masking receive one actionable finding. Equivalent owner wrappers can be reviewed and suppressed with `--off=lint-with-docs`; this is command-text convention coverage, not proof of installed tools, execution, effective read-only behavior or prose quality.
- Preserved owner configs, dictionaries, Markdown choices, starter documents and the generated Drop Calf snapshot. Added no companion-file existence, cross-file reference resolution or document-content rule. Updated only the legacy zero-findings fixture with the maintained declaration.
- Documented the upstream aggregate coverage gap: `lint:docs` remains outside `lint:check:*`; no rename or aggregate inclusion was imposed. Native config/reference validation, partial/absent companion pairs and actual Markdown/spelling validation remain native-tool/owner responsibilities.
- TDD red → green: the generated-package mutation removing `lint:docs` first lacked the expected finding (`.scratch/tmp_rovo_ticket19_missing_red.log`) and then passed after the rule was added. A separate quoted-glob/spacing equivalence test failed (`.scratch/tmp_rovo_ticket19_quoting_red.log`) before the narrowly supported syntax was added and passed afterward (`.scratch/tmp_rovo_ticket19_quoting_green.log`). The legacy fixture independently exposed its expected new declaration finding (`.scratch/tmp_rovo_ticket19_legacy_red.log`) before correction.
- Retained 3 valid and 40 invalid snippet examples with 40 invalid-case snapshots; 12 generated-package variants assert finding count, info severity and capability metadata. Added native package routing across all tiers and capability-report discovery. Tests only scan package text: no owner documentation command, external configuration resolution or content lint execution occurred.
- Validation passed: 214 consumer rule suites; the full fixture suite including all 214 routing definitions across four tiers; full authoring/metadata/severity/scope-composition/package-boundary checks; repository-wide Prettier; `shellcheck -x`; `shfmt -d`; `bash -n`; and `git diff --check`. Focused snippet/package/routing/authoring checks also passed.
- Evidence: `.scratch/tmp_rovo_ticket19_rules.log`, `.scratch/tmp_rovo_ticket19_fixtures.log`, `.scratch/tmp_rovo_ticket19_authoring.log`, `.scratch/tmp_rovo_ticket19_format.log`, `.scratch/tmp_rovo_ticket19_capability.log`, `.scratch/tmp_rovo_ticket19_routing.log` and `.scratch/tmp_rovo_ticket19_focused_final.log`. Independent review found no blocking rule or acceptance defects; actual harness counts above supersede its informal case count.
- Delivery: this ticket update is included in the same Conventional Commit as the implementation and regressions; the commit's file history is the delivery reference.
