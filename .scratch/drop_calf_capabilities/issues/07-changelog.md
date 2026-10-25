# 07: Check the idempotent changelog command convention

**What to build:** A Forge app receives an actionable finding when its changelog entrypoint is absent or uses the old prepend workflow instead of regenerating the unreleased changelog through the owner's git-cliff policy.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** completed (2026-10-25).

**Capability:** changelog

**Coverage today:** No consumer rule checks the changelog command. `no-stale-placeholder` can reject a placeholder but does not establish the git-cliff convention.

**Source convention:** Drop Calf maintains a changelog script invoking git cliff with the cliff.toml config, unreleased selection and output to CHANGELOG.md. It seeds git-cliff and initial policy/output documents; policy and changelog are owner-managed after init. Regeneration uses output rather than prepend to avoid duplicate headings/entries.

- [x] Add a root scripts.changelog check for the configured git-cliff regenerate workflow; accept supported output-option spellings and harmless flag ordering, while rejecting missing commands, inert echo/lookalike commands and prepend-only variants.
- [x] Accept the exact pinned generated command. Do not require byte-identical output, a fixed release version, pinned commit categories or an immutable policy file.
- [x] Tag the convention rule `capability:changelog`, preserving generic placeholder rules without assigning them ownership of every capability they can encounter.
- [x] Give the matcher an accurate command-text limitation, references to Drop Calf and git-cliff, and reviewed precision/impact. A missing preferred script is not proof release history is invalid.
- [x] Add positive/negative matcher tests and existing package filename routing checks; record TOML policy acceptance, git history and output equivalence as native-tool coverage, not AST claims.

**Boundary:** No git-cliff execution, file regeneration or Git history mutation is necessary for static-rule tests. The shared definition of done applies.

## Implementation record — 2026-10-25

Selected as the lowest-numbered unfinished dependency-ready ticket: its sole
prerequisite, ticket 01, and tickets 02–06 are complete. The user approved the
existing public seams: ast-grep matcher examples/diagnostics, native package-file
routing and capability discovery. No private implementation seam was introduced.

### Delivered behavior and assessment

- Added ecosol/package-scripts `require-changelog-script`, tagged only
  `capability:changelog`. Generic placeholder rules and their snapshots are
  unchanged; the existing shipped rule directory includes the new check.
- Checks only direct root `scripts.changelog` string values. Accepts the exact
  pinned generated command and supported long/short config/output spellings,
  equals/attached values, default output path, harmless option order, offline mode
  and literal owner-selected release tags. Rejects missing entrypoints/options,
  wrong paths/nesting/types, echo/lookalikes, prepend, shell comments/chaining and
  inert help/init options. No fixed version, commit categories or policy contents.
- Medium precision reflects the bounded command-text check: equivalent wrappers,
  quoting, environment-dependent behavior, escaped JSON and unsupported option
  forms need review/suppression. Low impact reflects bounded workflow repair,
  not proof of invalid release history or production failure. Matrix severity is
  informational. No automatic fix or new dependency was added.
- Reviewed Drop Calf revision `be86d05309a32f7eef8988205208c17ca94e7a4c`, its
  `src/capabilities/changelog.ts` and capability tests; consulted the authoritative
  git-cliff argument/examples references through Context7. Maintained package
  command/tool pin are distinct from owner-managed policy/output files.
- Added package routing to the existing four-tier matrix, generated-package
  acceptance plus missing/legacy mutations, and capability-report discovery.
  Updated only the older zero-findings repo-init fixture's stale prepend command;
  the separately generated Drop Calf fixture is unchanged.
- `docs/reference/capability-coverage.md` records recognized forms, suppression
  guidance and native-tool gaps: TOML/Tera policy acceptance, history/selection,
  successful regeneration, output equivalence/idempotence, tool installation,
  missing files, duplicate options and cross-file relationships. Static checks
  never run git-cliff or regenerate changelogs.

### Red–green evidence

- **RED:** Initial tracer failed with `Rule not found`; minimal rule plus a new
  diagnostic baseline passed the pinned command/missing-entrypoint examples.
  Evidence: `.scratch/tmp_rovo_ticket07_initial_red.log` and
  `.scratch/tmp_rovo_ticket07_tracer_green.log`.
- **RED:** Reordered equals-style output/config command was incorrectly flagged;
  bounded independent option matching made supported variants pass. Evidence:
  `.scratch/tmp_rovo_ticket07_options_red.log` and
  `.scratch/tmp_rovo_ticket07_options_green.log`.
- **RED:** Malformed `--output==CHANGELOG.md` initially slipped through; requiring
  one assignment delimiter made it produce a finding. Evidence:
  `.scratch/tmp_rovo_ticket07_malformed_red.log` and
  `.scratch/tmp_rovo_ticket07_malformed_green.log`.
- **RED:** Focused routing reported `No scope cases selected`; registering the
  definition passed package filenames, nested/test paths, shared exclusions,
  lookalike filenames and all four tiers. Evidence:
  `.scratch/tmp_rovo_ticket07_routing_red.log` and
  `.scratch/tmp_rovo_ticket07_routing_green.log`.
- **RED:** The old compliant fixture's prepend command produced the new finding;
  changing it to the maintained command restores zero findings. Evidence:
  `.scratch/tmp_rovo_ticket07_legacy_fixture_red.log` and the full regression log.
- **RED:** Capability report returned `changelog not-mapped`; adding the tag made
  the exact row `changelog implemented require-changelog-script` pass. Evidence:
  `.scratch/tmp_rovo_ticket07_discovery_red.log` and
  `.scratch/tmp_rovo_ticket07_discovery_green.log`.

### Verification

- Focused suite: 9 valid and 31 invalid examples pass, with 31 new diagnostic
  snapshots and no changed existing consumer snapshots. Evidence:
  `.scratch/tmp_rovo_ticket07_final_focused.log`.
- Focused four-tier package routing and capability-report tests passed.
- New rule authoring checks, ShellCheck and shfmt on both changed shell scripts,
  repository-wide `bun run format:check`, and `git diff --check` passed.
- Full `bun run test`: passed (exit 0), including all 207 consumer suites,
  generated-package/security/page-title fixtures, 207-definition routing across
  four shipped tiers, six authoring suites, values/recipes/orchestration,
  capability discovery, scope composition, severity/gates and actual packed
  package boundary. Evidence: `.scratch/tmp_rovo_ticket07_full_tests.log`.

The implementation, reference, tests and this record form one logical change,
committed as `feat(changelog): Check regeneration entrypoint`. No changelog
regeneration, deployment, secrets resolution, dependency installation or release
was run. Git writes are limited to the user's explicitly requested commit.

Temporary evidence is retained under `.scratch/tmp_rovo_*` per repository guidance.
Ticket 08 is the next lowest-numbered unfinished dependency-ready ticket.
