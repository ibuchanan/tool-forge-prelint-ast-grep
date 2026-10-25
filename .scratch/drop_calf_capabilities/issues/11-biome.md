# 11: Tag existing Biome script and configuration conventions

**What to build:** Maintainers can discover the already-covered Biome conventions by `capability:biome`, with no duplicate rules or unnecessary changes to owner-managed configuration.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** completed

**Capability:** biome

**Coverage today:** Reuse `lint-and-format-with-biome`, `require-biome-files-exclude-dist`, `require-biome-formatter-indent-style`, `require-biome-vcs-default-branch` and `require-biome-vcs-use-ignore-file`. The current working tree already aligns the script rule with lint:check:biome and lint:check:format. The shared `no-write-flags-in-readonly-script` guard also applies to Biome check tasks.

**Source convention:** Biome package scripts are maintained. Configuration and EditorConfig are seeded then owner-managed; update lets Biome migrate an existing root config rather than restoring template policy. Current seed uses hard exclusions for dist/specs/vendor, Git ignore integration/main, space indentation, recommended linting, and explicit overrides; these are not all immutable application requirements.

- [x] Add `capability:biome` to the five existing Biome rules. Add that tag to the shared read-only guard only with a documented relationship to its formatting/lint task convention; preserve any capability:lint tag added by ticket 12.
- [x] Retain the current npm/Bun format-check delegation support, separate write-back commands and new task names. Do not reproduce the already-landed-in-working-tree script matcher changes.
- [x] Keep configuration checks explicitly described as reviewed team-default advice rather than claiming Drop Calf update enforces every seed value. Preserve owner customization/suppression guidance and do not create rules for every template setting.
- [x] Prove the generated script family and both supported Biome JSON/JSONC file routes pass the existing intended checks; existing mutated fixture cases keep their diagnostics. New seed changes should not force an exact schema-version pin.
- [x] This slice should remain metadata-only for matcher behavior: retain IDs, native scope, tiers, ratings/severity and consumer snapshots; run tag/authoring and focused rule tests. Record any newly discovered behavioral gap as a scoped follow-up, not speculative expansion.

**Boundary:** Effective inherited Biome configuration and tool acceptance stay with Biome. The shared definition of done applies.

## Implementation update — 2026-10-25

Selected in dependency order: blocker 01 and tickets 02–10 are complete, so
11 is the lowest-numbered unfinished ready ticket. The user approved the
capability-discovery, existing rule-test and native fixture/routing seams.

### Source and implementation

Reviewed the external Drop Calf checkout at
`be86d05309a32f7eef8988205208c17ca94e7a4c`, including
`src/capabilities/biome.ts`, `tests/capabilities/biome.test.ts` and the Biome
seed template. The capability maintains five package tasks; configuration and
EditorConfig remain owner-managed after init, with Biome migration on update.

Added `capability:biome` to the five existing Biome rules and the shared
`no-write-flags-in-readonly-script` guard. An inline relationship comment and
the capability coverage reference explain the guard's material relevance to
Biome's read-only formatting/lint tasks without claiming exclusive ownership.
Ticket 12 has not yet added a `capability:lint` tag; no existing tags were removed.

All six IDs, matcher bodies, native scopes, tiers, precision/impact ratings,
severities, valid/invalid examples and consumer snapshots remain unchanged.
The four config notes now describe suppressible reviewed team-default advice,
not immutable settings restored by Drop Calf. The branch note no longer claims
all repositories must use `main`. Intentional tabs, other default branches,
inherited settings and equivalent exclusions remain owner decisions.

The coverage reference records the native-tool boundary. No schema-version pin,
dependency change, new configuration rule, template rewrite or generator change
is introduced. Stored generated fixtures and all shipped tier configs are
unchanged. Known effective-configuration and bounded command-text limitations
remain documented; no new behavioral gap requiring expansion was identified.

### Red → green evidence

1. Added the public capability-report assertion for the five existing Biome IDs.
   It failed with `biome\tnot-mapped`, then passed after additive metadata tags.
   Evidence: `.scratch/tmp_rovo_ticket11_mapping_red.log` (exit 1) and
   `.scratch/tmp_rovo_ticket11_mapping_green.log`.
2. Extended that assertion to include the shared read-only guard. It failed with
   the guard absent, then passed after tagging the guard and documenting its
   relationship. Evidence: `.scratch/tmp_rovo_ticket11_guard_red.log` (exit 1)
   and `.scratch/tmp_rovo_ticket11_guard_green.log`.
3. Added native static fixture characterization for the five exact pinned package
   tasks, npm/Bun format-check delegation, separate write-back commands, a missing
   formatting delegate and write-back mutations in both read-only Biome tasks.
   Isolated mutations retain the existing intended rule IDs and capability tags.
4. Both `biome.json` and genuinely commented `biome.jsonc` routes pass defaults,
   a changed schema URL and unrelated owner options. Independent dist, indentation,
   branch and ignore mutations each report exactly the existing informational
   config advisory. Existing invalid JSON/JSONC fixtures retain their diagnostics.
   These are characterization checks, not new matcher behaviors; the report seam
   supplies the red → green changes for this metadata-only implementation.

### Validation

- Focused native rule tests and unchanged snapshots: all 6 suites passed
  (36 valid/invalid examples). Evidence:
  `.scratch/tmp_rovo_ticket11_focused_green.log`.
- Explicit authoring checks for all six changed definitions, `shellcheck -x`,
  `shfmt -d`, `git diff --check` and repository-wide `bun run format:check` passed.
  Evidence for formatting: `.scratch/tmp_rovo_ticket11_format.log`.
- Parsed baseline/current definition comparison, excluding only tags and notes,
  confirmed all other rule fields are byte-equivalent in normalized JSON.
  `git diff` confirms no consumer snapshot, rule example, generated fixture or
  shipped tier config changes.
- `sh scripts/check-fixtures.sh` passed, including static Biome task/config cases,
  security fixtures, all 210 native definitions across four shipped tiers and
  page-title diagnostics. Evidence: `.scratch/tmp_rovo_ticket11_fixtures_green.log`.
- `bun run test` passed with exit 0: all 210 consumer suites and snapshots,
  generated/static fixtures, native scope routing, page-title diagnostics, metadata
  recipes/value checks, capability discovery, scope composition, severity matrices,
  consumer gates, authoring enforcement and packed-package boundary checks.
  Evidence: `.scratch/tmp_rovo_ticket11_full_tests.log` (`FULL_TEST_EXIT=0`).
- The repository has no `lint` package script; that exploratory invocation was not
  a validation gate. Explicit ShellCheck/shfmt commands above are the shell gates.
- Independent read-only correctness review found no acceptance gaps. Tests assert
  public report/scanner results with literal expected IDs, not private helpers.
  Full native routing matrices retain the existing integration-suite runtime cost.

No generated task, Biome formatter/linter/migration, secret resolution, deployment,
installation, release, hook or commit is executed as static-rule test evidence.
The final Git commit is the user's explicitly requested delivery action.
