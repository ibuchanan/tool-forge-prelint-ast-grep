# 21: Review redundant Forge page headers without claiming proven duplication

**What to build:** A Forge UI author receives an actionable, non-blocking review finding on a likely redundant page-level heading, prompting comparison with the title already rendered by the host. Focus exclusively on the duplicate-header problem described in the Loom; improve the existing rule rather than creating a competing detector.

**Blocked by:** None (can start immediately). This UI story is independent of the capability-tag foundation and the 20 Drop Calf convention tickets.

**Status:** completed (2026-10-25). Ticket 01 is now the sole unblocked ready-for-agent capability ticket; tickets 02–20 remain blocked by 01.

**Source:** [Improving the Configure Flow UI Text](https://www.loom.com/share/48e7407274314add961a7ddd10fec942).

- At approximately **0:00**, the speaker says an extra header is duplicated from what already exists in the manifest and is unnecessary.
- At approximately **0:36**, the speaker identifies another duplicate header/text on the status view.
- These observations establish the UX problem, not the exact JSX, component import, module type or heading text. Obtain a minimal source example before claiming the matcher reproduces the particular screen. The remaining feedback about documentation, Prefix, preview text and configuration-flow explanations is out of scope.

**Coverage today:** `review-duplicate-page-title` already flags TSX Heading elements with literal xlarge or xxlarge sizes under the frontend scope. It does not inspect the manifest, compare heading text, resolve the module or establish the component's import identity. Its message currently states duplication as fact despite low precision and low impact. Reuse this stable ID and its regression coverage.

## Acceptance criteria

- [x] Retain one recommended frontend review rule under the existing ID. Keep the finding advisory and non-blocking, consistent with reviewed low precision/low impact, rather than promoting a heuristic into a deployment gate.
- [x] Change the diagnostic to express uncertainty and a concrete review action, for example: “This page-level heading may repeat the host-rendered title; compare it with the module title.” The note explains when removal is appropriate and when a distinct section heading should remain. Do not recommend shrinking text merely to silence the rule.
- [x] Cover the existing page-level Heading pattern robustly across supported literal attribute spellings, including attribute order, single/double quotes and equivalent literal expression values. Include focused positive examples for the existing xlarge/xxlarge cases; identify any additional candidate, such as an explicit h1, through source/API evidence before broadening the matcher.
- [x] Reduce obvious same-file false positives where the AST can establish an unrelated local component named Heading. Document any unresolved import-alias, wrapper or component-identity gaps rather than pretending the spelling alone proves a Forge UI Kit component. Avoid a cross-file resolver or a general UI analyzer.
- [x] Preserve legitimate smaller section headings and ordinary body text. Include a distinct large section-heading case in the tests or documented limitations: if it still matches, the diagnostic must remain a review prompt, not an assertion that duplication was confirmed. A single rendered heading can duplicate host chrome; do not require two Heading nodes in the source file.
- [x] Add targeted matcher tests and snapshots, plus real-file routing evidence for intended frontend TSX and excluded generated/dependency/spec paths. Keep this slice bounded to the existing UI Kit-oriented source coverage; document unsupported Custom UI/native HTML/JSX locations rather than silently promising universal detection.
- [x] Keep the rule's metadata, precision/impact rationales and authoritative Forge page-module/heading references aligned with what the matcher actually knows. Host-title behavior varies by module and configuration; do not state that every Forge surface always displays a title. Do not add a Drop Calf capability tag solely because this is a Forge UI rule; optional verified module tags need no capability-vocabulary dependency.
- [x] Run the focused rule tests and relevant authoring, severity and routing checks. Demonstrate that the finding points at the candidate heading, survives the chosen equivalent syntax variants and supplies review guidance without removing UI automatically.

**Boundary:** ast-grep evaluates one source file. It cannot compare JSX text with a title in another manifest, resolve translated/dynamic labels, identify the active module, inspect rendered host chrome or prove visual duplication. No automatic heading deletion or unsafe fix is included. Cross-file title equality and browser-level confirmation remain manual/native-tool checks; unknown title relationships must remain unknown.

**Out of scope:** Copywriting, admin explanations, configuration gating, documentation expansion, Prefix semantics, preview behavior, generic duplicate-text detection, Markdown headers, HTTP headers and capability-convention implementation.

## Completion record — 2026-10-25

### Agreed seams and TDD evidence

The user selected 21 and approved the proposed public seams: ast-grep diagnostic/snapshot output, real-file frontend routing, and authoring/severity checks.

Six vertical slices each failed before their minimal rule edit and passed afterward:

1. A real-file scan expected an uncertain, actionable message, a candidate-heading range and advisory hint; the old definitive message failed. The revised message and note passed, including a zero-finding error-only gate.
2. A single-quoted xlarge attribute was missed; accepting either literal quote style made it pass.
3. A braced string-literal size was missed; bounded braced-literal support made it pass.
4. A direct local function named Heading produced a false positive; an enclosing-scope declaration exclusion removed it.
5. A lexical Heading component inside its enclosing function produced a false positive; direct lexical declaration support removed it.
6. A direct local class named Heading produced a false positive; direct class declaration support removed it.

The final matcher suite has 26 examples (15 no-finding, 11 review candidates), including attribute order/whitespace, both sizes and quote styles, braced literals, lookalike properties/values, computed sizes, smaller sections, imported Heading and sibling-scope isolation. A distinct large section intentionally remains a review candidate. Original snapshots remain unchanged; new cases add their expected candidate ranges.

### Implementation and boundaries

- Reused `review-duplicate-page-title` in recommended/frontend-ui; ID, Tsx parser, hint severity, low/low ratings, native files/ignores and scope profile are unchanged. No capability tags or automatic fixes were added.
- Updated the diagnostic, note and rationale to distinguish candidate review from proven duplication. Useful sections must remain; shrinking text is not a remedy.
- Added `scripts/check-page-title-fixtures.sh` to the standard fixture suite. It checks the exact diagnostic and TSX candidate range, excludes JSX and Custom UI outside frontend, and verifies the error-only gate remains empty. The existing routing matrix covers generated/dependency/spec exclusions through all four shipped tiers.
- Verified the Heading API and Jira full-page layout guidance through Forge knowledge tools; cited Heading, Jira full-page modules, admin-page and WAI heading references. No h1-only policy expansion.
- No minimal source sample from the Loom screen was available, so this does **not** claim to reproduce that screen. Manifest comparison, host chrome, aliases, wrappers, parameters and full symbol resolution remain unsupported/documented. Dynamic sizes and unsupported source routes are not inferred.

### Verification

All commands passed:

- `ast-grep test --test-dir rule-tests --filter review-duplicate-page-title` — all 26 examples and snapshots.
- `bash scripts/check-page-title-fixtures.sh` — advisory message, candidate range, supported/unsupported routes and nonblocking gate.
- `bash scripts/check-scope-fixtures.sh rules/recommended/frontend-ui/review-duplicate-page-title.yml` — four-tier focused routing.
- `ast-grep test --test-dir rule-tests` — 201 rule tests, zero failures.
- `bun run test:fixtures` — scaffold, Biome, security, all 201 definitions across four shipped tiers, and page-title diagnostics.
- `bun run test:authoring` — six authoring suites; value/orchestration, recipe preservation/rejection, scope composition, severity/gates, repository checks and actual packed consumer boundary.
- `bun run format:check`, ShellCheck and shfmt for both changed shell files, and `git diff --check`.
- Parsed metadata comparison confirmed unchanged identity, ratings, severity and native scope; the severity report remains low/low → hint, unchanged/nonblocking.
- Independent read-only review found no blockers.

Full-suite evidence: `.scratch/tmp_rovo_ticket21_full_tests.log`; formatting evidence: `.scratch/tmp_rovo_ticket21_format.log`. Real scan/routing/package evidence is retained under `.scratch/tmp_rovo_*`.

The pre-existing backlog README changes are deliberately excluded from this work's commit. Ticket 01 is the next unblocked implementation ticket.
