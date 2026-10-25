# 14: Map compiler conventions and check the typecheck lint delegate

**What to build:** Forge-app compiler and typecheck checks are discoverable under `capability:typescript`, and a missing or inert namespaced typecheck delegate is reported without applying the base compiler policy incorrectly to a dependency-selected config variant.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** complete (2026-10-25)

**Capability:** typescript

**Coverage today:** Reuse `require-typescript-build-script`, `typecheck-with-typescript`, `use-typescript-5`, the existing base `require-tsconfig-*`/`use-tsconfig-*` rules, Forge JSX/source-map mismatch rules, and all `require-tsconfig-typecheck-*` checks. There is no dedicated lint:check:typecheck delegate check. Existing filename routing must be reviewed rather than assumed to distinguish base and typecheck policy.

**Source convention:** Forge apps build the root project, typecheck the dedicated no-emit project, and delegate lint:check:typecheck to typecheck. Base defaults include ES2022, Node resolution, source root/dist output and strict settings. Typecheck config extends the base, widens rootDir, includes source/test/tests plus Vitest config when Vitest is declared, excludes generated/spec paths and uses Bundler resolution for the default Vitest-backed profile. Other dependency traits select different policies.

- [x] Add `capability:typescript` to existing rules that directly check these compiler/build conventions, keeping language companions consistent and avoiding blanket tags on unrelated source-code rules.
- [x] Add a root scripts.lint:check:typecheck delegate check accepting the generated npm command and supported Bun equivalent. Reject missing, inert, wrong-target and nested fields; do not duplicate the existing typecheck compiler-command rule.
- [x] Test representative final base and typecheck configs independently. Correct any existing native glob or matcher that wrongly forces base-only rootDir/module-resolution defaults onto the typecheck variant; preserve supported owner choices and document any behavior change.
- [x] Do not infer package dependency traits from another file in ast-grep. A typecheck-resolution check must either tolerate supported Node/Bundler variants or explicitly scope a documented default-profile policy; do not report every Bundler value as Forge-bundler incompatibility.
- [x] Keep supported inherited noEmit and include behavior within the stated rule limitations. Do not require a declarations project in forge-app merely because library builds use one, or mistake showConfig acceptance for compilation success.
- [x] Run focused compiler/script tests, JSONC/filename routing evidence and authoring/fixture checks; metadata-only rules retain snapshots while actual fixes get targeted regression cases.

**Boundary:** No compiler execution or cross-file include/dependency proof is promised by static rules. The shared definition of done applies.

## Completion update — 2026-10-25

Selected by dependency order: ticket 01 and tickets 02–13 are complete; this was
the lowest-numbered ready ticket. Used the ticket's approved public seams only:
capability-report TSV, matcher valid/invalid cases and native real-file scans.

- Added `capability:typescript` to 24 existing compiler/build/typecheck rules and
  the new `lint-with-typescript` informational ecosol rule (medium precision,
  low impact). Existing severity, native scope and unrelated metadata remain
  unchanged; 23 reused rule definitions are tag-only changes.
- The delegate accepts direct npm/Bun `run typecheck` values with ordinary
  whitespace. Tests reject missing, inert, wrong-target, non-string, unrelated
  and nested entries. Existing compiler-command validation stays separate.
- Reviewed the pinned TypeScript capability at
  `be86d05309a32f7eef8988205208c17ca94e7a4c`. Existing base/typecheck native scopes
  were already correct; no routing broadening was needed. Added independent
  JSONC fixture scans, owner-option variants, Node/Bundler typecheck variants,
  base-only mutation controls and wrong-filename checks.
- Fixed one observed false positive: base Node resolution now accepts lowercase
  `node` and other case-equivalent spellings. Replaced the obsolete universal
  Node 18/runtime claim with bounded base-policy guidance. Existing invalid
  match snapshots remain byte-for-byte unchanged.
- Documented inherited noEmit/include limitations, effective config versus
  compilation, dependency-trait boundaries and review/suppression of equivalent
  owner choices in `docs/reference/capability-coverage.md`. No cross-file
  inference, declarations requirement or compiler execution was introduced.
- Integrated `scripts/check-typescript-fixtures.sh` into the fixture gate and
  registered the new rule in four-tier package routing. Stored generated
  fixtures remain unchanged; tests apply only the pinned delegate to a copy.

### Red → green evidence

- Capability discovery: `.scratch/tmp_rovo_ticket14_mapping_red.log` reports
  `typescript not-mapped`; the green/final mapping logs report all 25 rule IDs.
- Missing delegate: `.scratch/tmp_rovo_ticket14_delegate_red.log` expected
  `lint-with-typescript` but found none before the rule existed; the green
  tracer and final native fixture log pass after implementation.
- Case-equivalent resolver: `.scratch/tmp_rovo_ticket14_resolver_red.log` fails
  the new valid `node` example; the green resolver log and final focused suite
  pass after the bounded case-insensitive matcher change.

### Validation

All checks passed using installed tools (package tools via Bun):

- `ast-grep test --test-dir rule-tests`: **211 passed; 0 failed**.
- Focused compiler/script suites: **25 passed; 0 failed**; final delegate and
  resolver rerun: **2 passed; 0 failed**.
- `bash scripts/check-typescript-fixtures.sh`: script/config mutation controls,
  JSONC, owner choices and base/typecheck filename isolation passed.
- `bash scripts/test-capability-coverage.sh`: implemented TypeScript mapping
  passed with the exact 25-rule list.
- `sh scripts/check-fixtures.sh`: all fixture checks passed, including scope
  routing of **211 definitions across four shipped tiers**.
- `bash scripts/test-authoring.sh`: authoring matchers, metadata, scope
  composition, severity/report/consumer gates and package boundary passed.
- `bun run format:check`, ShellCheck, shfmt and `git diff --check`: passed.
- Read-only acceptance review: no blockers. No dependency install, Forge
  operation, generated task or remote write was performed.

Validation logs are retained under `.scratch/tmp_rovo_ticket14_*`.
The commit uses this ticket's local identifier rather than inventing a Jira key.
