# 19: Check the maintained documentation lint entrypoint

**What to build:** An existing Forge app package receives an actionable diagnostic when its docs lint entrypoint omits Markdown linting or spelling checks, and the rule is discoverable as `capability:docs` without attempting to judge prose quality with AST matching.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** docs

**Coverage today:** There is no consumer rule for lint:docs or the Markdown/CSpell toolchain. Generic lint composition does not cover this script; it is outside the generated lint:check namespace.

**Source convention:** Drop Calf maintains lint:docs combining markdownlint-cli2 and cspell lint across quoted Markdown globs. It seeds both tools, Markdown/spelling configs, development guidance, Diátaxis folders and spec starters. Documents and config are owner-managed after init. Native validation loads configs/references without linting content and distinguishes both configs absent from a partially missing pair.

- [ ] Add a root scripts.lint:docs check for the two read-only documentation tools with quoted Markdown glob arguments and fail-fast sequencing, accepting the generated command and narrowly supported equivalents. Reject missing/non-string/inert/nested and one-tool-only scripts.
- [ ] Tag the rule `capability:docs` and ground diagnostics in the maintained command rather than assuming every document is spelled or formatted correctly because it exists.
- [ ] Do not rename it to lint:check:docs or require inclusion in the default lint aggregate: that would change the upstream convention, not check it. Explicitly record the current aggregate coverage gap for a separate upstream decision.
- [ ] Preserve owner dictionaries, Markdown rule choices, starter documents and prose. Do not impose byte-identical document templates or content-quality checks beyond the selected tools.
- [ ] Add generated and mutated package fixtures and test quoted-glob/lookalike boundaries. JSONC configs are parsable in principle, but presence of the companion file and resolution of references are cross-file/native-tool responsibilities; do not add a fake pair-existence AST rule.
- [ ] Run focused rule/authoring/routing checks without executing owner documentation commands or resolving external configuration.

**Boundary:** The ticket covers a usable single-file entrypoint, not missing-document detection, spelling correctness or Diátaxis content classification. The shared definition of done applies.
