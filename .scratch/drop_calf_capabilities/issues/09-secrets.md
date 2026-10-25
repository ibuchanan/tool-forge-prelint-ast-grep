# 09: Align and tag SecretSpec and Fence Rider workflow checks

**What to build:** Drop Calf's generated Forge lifecycle scripts satisfy their convention checks, genuine unguarded generated-script execution is still flagged, and maintainers can discover those rules with `capability:secrets`.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** complete

**Capability:** secrets

**Coverage today:** Reuse `use-forge-register`, `use-forge-deploy`, `use-forge-install`, `use-forge-uninstall`, `use-forge-upgrade`, `use-forge-variables-set`; the corresponding Fence Rider deploy/install/uninstall/variables checks; `require-fence-rider-script-execution`; and `no-unguarded-fence-rider-evaluation`. Existing `use-fence-rider-for-forge-lint` conflicts with current generated direct Forge lint. The tunnel preference is additional team policy; this capability seeds no tunnel task.

**Source convention:** Six Forge scripts are maintained. Register invokes Forge directly; deploy/install/uninstall/upgrade generate Fence Rider scripts and execute them only after generation succeeds; variables uses Fence Rider directly. Deploy/install/upgrade forward noninteractive/consent flags. SecretSpec declarations are owner-managed and its native validation checks TOML structure and declared scope members without resolving secrets.

- [x] Tag the existing lifecycle and execution-safety checks that materially enforce these conventions `capability:secrets`, preserving their IDs and existing safety tests rather than creating duplicates.
- [x] Test all six currently generated commands as a compatibility matrix, including guarded execution and forwarded flags. Missing scripts, wrong command roles, generation without execution and unguarded evaluation retain appropriate findings.
- [x] Reconcile `use-fence-rider-for-forge-lint` with the fact that current Drop Calf emits direct lint:check:forge. Do not silently claim the generator uses a wrapper: document and implement a narrowly justified exception or retire the incompatible preference under explicit policy/severity review. Preserve protections on generated lifecycle commands.
- [x] Do not require tunnel wrappers or SecretSpec values as conditions of satisfying Drop Calf's required capability. Keep broader tunnel/security guidance distinct from generator-convention coverage.
- [x] Record SecretSpec TOML schema/scope membership as native-tool coverage unless a supported parser is demonstrated. Do not add fake YAML matching, resolve values, read real credentials, or claim AST text proves encryption or secret isolation.
- [x] Prove generated package scripts pass the reconciled convention subset, mutated unsafe examples fail, and all affected rule/authoring/fixture regressions remain green.

**Boundary:** Reconcile the lint preference here; ticket 10 owns the lint task's presence and Prelint config/globs. Those are distinct policies and need no extra blocking edge. The shared definition of done applies.

## Implementation update — 2026-10-25

Selected by dependency order: blocker 01 and tickets 02–08 were complete, making
09 the lowest-numbered ready ticket. Used the pre-approved ast-grep matcher,
real-file fixture and capability-discovery seams.

### Source and implementation

Reviewed the external Drop Calf checkout at
`be86d05309a32f7eef8988205208c17ca94e7a4c`, including the secrets capability,
its command tests and native TOML/scope validation. Reused twelve stable rule IDs:
six naming rules, four lifecycle wrapper preferences and two execution-safety
checks, all tagged `capability:secrets`. No new consumer rule, tier, dependency,
parser, source generator or stored generated fixture was introduced.

The six naming matchers now require recognizable command-role text in direct
root script strings, rather than accepting a key with an unrelated command,
wrong type or nested location. Direct Forge and the legacy variable-upload helper
remain naming-compatible while the separate wrapper preferences retain their
advisories. Naming remains medium precision/low impact/informational: this is
bounded command text, not shell interpretation or proof of effective CLI options.

The lint preference now exempts only root `lint:check:forge` containing direct
`forge lint` with ordinary whitespace. Flags, chaining and other script names
retain the existing preference. Lint/tunnel preferences remain outside required
secrets discovery. Native SecretSpec TOML/schema/profile/scope checks are
explicitly documented rather than simulated using YAML matching. No credentials,
resolved values, encryption, isolation or successful remote execution are inferred.

### Red → green evidence

- Added direct generated lint as a positive tracer; it initially produced a noisy
  finding, then passed with the narrow exception. Three negative boundary cases
  retain findings. See `.scratch/tmp_rovo_ticket09_role_lint_green.log`.
- Wrong lifecycle command roles initially escaped all six naming checks. Deploy
  and sibling red logs are `.scratch/tmp_rovo_ticket09_role_red.log` and
  `.scratch/tmp_rovo_ticket09_siblings_red.log`; the subsequent six-suite green
  run is `.scratch/tmp_rovo_ticket09_siblings_green.log`.
- Discovery initially omitted the execution/wrapper mappings; the failing
  assertion is `.scratch/tmp_rovo_ticket09_discovery_red.log`. The final report
  lists exactly twelve active secrets rules, excluding lint/tunnel preferences.
- The static generated-command matrix exposed unguarded
  `cmd=$(fence-rider deploy); sh -c "$cmd" sh`. Added a matcher regression, observed
  the missed-finding red run, and added bounded detection for this literal root
  capture form while preserving guarded captures. Evidence:
  `.scratch/tmp_rovo_ticket09_capture_red.log` and
  `.scratch/tmp_rovo_ticket09_capture_green.log`.
- `scripts/check-secrets-fixtures.sh` scans the six exact pinned lifecycle
  commands plus direct lint, and independently mutates missing commands,
  wrong roles/types, nested keys, lookalikes, generator-only execution, unguarded
  captures/eval and direct lifecycle commands. All 43 real-file matrix cases pass;
  `.scratch/tmp_rovo_ticket09_matrix_green.log` records the focused result.
  Fixtures remain static: no command under test is executed.

### Validation

- Full `bun run test`: exit 0; 209 consumer suites, generated/security/scope and
  page-title fixtures, 6 authoring suites, metadata/value/orchestration checks,
  capability discovery, scope composition, severity gates and package-boundary
  checks passed. Evidence: `.scratch/tmp_rovo_ticket09_full_tests.log`.
- Fourteen focused lifecycle/safety/lint/tunnel suites and snapshots passed after
  formatting. Existing safety examples are retained; only eight behaviorally
  affected snapshot files were updated.
- All 209 definitions passed native routing across four shipped tiers; scope
  composition passed. No routing or tier configuration changed.
- Repository-wide `bun run format:check`, `git diff --check`, shell syntax and
  `shfmt -d` passed. ShellCheck's SC2016 notices reflect deliberately literal jq
  programs and fixture command text, not shell expansion; checked separately
  with that diagnostic excluded.
- Execution-only validation did not resolve SecretSpec, inspect real credentials,
  upload variables, deploy/install/tunnel, execute a fixture script or contact
  Forge. The requested Git commit is delivery, not a test of those workflows.

Shell access was temporarily interrupted during implementation, then restored;
remaining regressions were completed successfully before delivery.
