# 16: Map size-budget checks and correct workflow ownership

**What to build:** Existing size-budget and build-before-measure guidance is discoverable through `capability:size-limit`, and diagnostics accurately describe the current check aggregate rather than an obsolete hook structure.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** complete (2026-10-25)

**Capability:** size-limit

**Coverage today:** Reuse `use-size-limit`, `no-size-limit-preset-app` and `require-size-check-script`. The script rule already checks build-before-measure, but its note says the pre-push hook calls size:check directly; current Drop Calf instead routes pre-push through check.

**Source convention:** Drop Calf seeds size-limit with @size-limit/file and an initial 10 kB dist JavaScript budget. It enforces the size:check command that builds before measuring; budgets, labels and paths remain owner-managed. Only a legacy size script equal to the old generated command is removed; arbitrary owner size scripts are preserved.

- [x] Add `capability:size-limit` to the three existing rules, preserving IDs, tiers, native scope, ratings/severity and any prior tags.
- [x] Update outdated note/rationale text to describe pre-push → check → size:check, keeping package-script composition owned by lint and hook wiring owned by git-hooks. No new blocker on those tickets is needed for prose correction.
- [x] Verify the generated tools, budget and exact build-before-measure command pass current checks; retain existing diagnostics for configured tooling without the required command and the disallowed preset.
- [x] Do not freeze the initial 10 kB threshold, Forge app bundle label, dist glob or exact tool version; do not flag a retained custom size script merely because the generator removed a particular legacy command.
- [x] Keep actual byte measurement, external configuration and paired tool compatibility as explicit limitations. Do not claim that absence of a tool proves material Forge spend.
- [x] This is primarily a tag/documentation slice: consumer snapshots should remain unchanged unless a separately evidenced matcher defect is corrected. Run focused and authoring checks.

**Boundary:** Do not build, delete or measure owner output to test static rules. The shared definition of done applies.

## Implementation update — 2026-10-25

Selected by dependency order: ticket 01 and tickets 02–15 are complete; this was
the lowest-numbered ready ticket. Used the approved capability-report,
rule-test/snapshot and native real-file scan seams only.

- Added `capability:size-limit` to exactly `use-size-limit`,
  `no-size-limit-preset-app` and `require-size-check-script`. No duplicate rules
  or aggregate/hook tags were added.
- Corrected the command note and impact rationale to describe pre-push → `check`
  → `size:check`, with aggregate composition owned by lint and wiring owned by
  git-hooks. No new implementation dependency was introduced.
- Clarified budget advice without implying that missing tooling proves bundle
  bloat or material Forge spend. Notes now describe built file measurement, not
  an unconditional raw/exact-byte measurement claim.
- Reviewed pinned source at `be86d05309a32f7eef8988205208c17ca94e7a4c`.
  Generated tools, initial budget and exact build-before-measure command pass.
  Static controls accept owner budget labels, paths, thresholds, tool versions,
  retained custom `size` scripts and legacy commands alongside `size:check`.
- Preserved every matcher, ID, language, tier, native route, scope profile,
  precision/impact rating, severity and consumer snapshot. A direct comparison
  against HEAD confirmed those contracts for all three rules.
- Documented external configuration, equivalent orchestration, descendant/text
  matching gaps, native measurement, artifact freshness, paired tool compatibility
  and intentional-suppression boundaries in `docs/reference/capability-coverage.md`.
  No build, measurement, owner-output cleanup, installation or generated hook/task
  was run to test these rules; stored generated fixtures remain unchanged.

### Red → green evidence

- Mapping: `.scratch/tmp_rovo_ticket16_mapping_red.log` fails with
  `size-limit not-mapped`; `tmp_rovo_ticket16_mapping_green.log` passes after
  tagging the three existing IDs.
- Workflow diagnostic: `.scratch/tmp_rovo_ticket16_workflow_red.log` fails the
  native missing-command scan because the note claims the hook calls the task
  directly. `tmp_rovo_ticket16_fixtures_green.log` passes the new Size Limit
  controls after correcting the note. Missing/no-build commands and the
  disallowed preset retain their existing findings.
- Existing matcher/snapshot baseline and final focused run both pass:
  **3 suites; 0 failed**, covering 16 valid/invalid examples. No new failing
  matcher behavior was found or matcher change made.

### Validation

- `ast-grep test --test-dir rule-tests`: **211 passed; 0 failed**;
  `.scratch/tmp_rovo_ticket16_rules.log`.
- `bash scripts/test-authoring.sh`: passed authoring matchers/values,
  metadata, capability reporting, scope composition, severity/report/consumer
  gates, authoring checks and package boundary;
  `.scratch/tmp_rovo_ticket16_authoring.log`.
- `bun run format:check`, `shellcheck -x` and `shfmt -d` on the changed shell
  scripts, plus `git diff --check`: passed. Focused results are in
  `.scratch/tmp_rovo_ticket16_focused.log`; formatting is in
  `.scratch/tmp_rovo_ticket16_format.log`.
- Independent read-only acceptance review found no blockers.
- Full `sh scripts/check-fixtures.sh`: passed with exit status 0, including
  generated declarations, owner variants and isolated Size Limit mutations,
  **211 scope-routing definitions across four shipped tiers**, and page-title
  diagnostics. Its long-running scope matrix continued beyond the initial tool
  wait and completed successfully; see `tmp_rovo_ticket16_fixtures_green.log`.

Evidence is retained under `.scratch/tmp_rovo_ticket16_*`. The commit refers
to local ticket 16 rather than inventing a Jira key. Ticket 17 (clean-build) is
now the lowest-numbered dependency-ready ticket.
