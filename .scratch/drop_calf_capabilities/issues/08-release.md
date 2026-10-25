# 08: Check explicit release entrypoints without running a release

**What to build:** Maintainers can identify a missing or inert explicit release entrypoint while retaining their own release checks, and discover the check through `capability:release`.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** complete

**Capability:** release

**Coverage today:** No existing consumer rule checks release wiring. General lifecycle and download/execute checks are related safety guidance, not proof of this capability's release workflow.

**Source convention:** Drop Calf enforces a release script that explicitly invokes its maintained Bash release helper. It seeds release:check with test followed by typecheck for forge-app, restores it only if missing, and preserves owner-defined check content. The helper guards main/clean worktree, derives versions/notes with git-cliff, commits and tags, then atomically pushes main and its explicit tag to origin. Init/update/validate do not perform a release.

- [x] Add a package check for a string-valued release entrypoint invoking the maintained Bash release helper, rejecting missing, placeholder, echo-only or misplaced fields. Do not treat an unrelated shell command as a release helper.
- [x] Check release:check is a usable non-placeholder entrypoint without freezing its seeded command text or requiring the checks supplied by a library profile. Keep ordinary owner-authored validation extensions acceptable.
- [x] Tag release-specific findings `capability:release`. Keep git-cliff tool/command ownership in ticket 07; no artificial dependency on the changelog ticket is needed to test local package wiring.
- [x] Verify generated release wiring passes and local mutations fail. If shell helper inspection is supported, leave detailed branch/atomic-push semantics to a separately scoped follow-up rather than building a shell interpreter in this ticket.
- [x] Document that local script presence does not prove helper existence, checks execution, worktree cleanliness or atomic publication. Never run release, git writes or remote publication during verification.

**Boundary:** File names identify the current generated workflow, not a promise that ast-grep resolves external helper contents. The shared definition of done applies.

## Implementation update — 2026-10-25

Selected in dependency order: ticket 01 is complete, tickets 02–07 are complete,
and 08 is the lowest-numbered remaining ready ticket. The ticket's diagnostics,
real-file routing, capability-discovery and fixture seams were pre-approved.

### Source and scope

Reviewed the external Drop Calf checkout at
`be86d05309a32f7eef8988205208c17ca94e7a4c`, including
`src/capabilities/release.ts`, its tests, release specification and maintained
helper template. There were no existing release-specific consumer matchers to
reuse. Added `require-release-script` and `require-release-check-script` in ecosol,
both with `capability:release`, medium precision, low impact and informational
severity under the existing matrix. No changelog or generic lifecycle rule was
retagged.

The release matcher recognizes the maintained direct Bash helper command, with
ordinary spacing and optional `./`, rather than merely mentioning the helper in
an echo, comment, unrelated command or argument. The validation matcher accepts
owner commands, task choices and extensions without demanding the seeded text or
library checks; known inert starts and missing/malformed/misplaced fields fail.
Equivalent wrappers and logging-first validations need review and suppression.
The coverage reference documents these bounded text checks and explicitly
excludes helper existence, owner-update preservation, task existence/execution,
worktree/branch guards, versioning and atomic publication semantics.

### Red → green evidence

1. Added the maintained-command/missing-release tracer before its rule; native
   `ast-grep test` failed because the rule was absent, then passed after the
   minimal root package matcher.
2. Added the relative-path/spacing case; it failed against the initial literal
   matcher, then passed with the bounded direct-invocation pattern.
3. Added seeded and owner-defined `release:check` tracers before that rule; the
   missing-rule failure became green with the owner-preserving string check.
4. Added the echo-only validation counterexample; it failed as a missed finding,
   then passed after excluding known inert/placeholder starts. Final examples
   cover 2 valid/22 invalid release cases and 8 valid/22 invalid validation cases,
   with native match-range snapshots.
5. The capability-discovery assertion failed with `release: not-mapped`, then
   passed after tagging both rules. Real-file scope checks initially reported no
   selected cases, then passed across all four tiers after registering both
   package scopes, including filename and excluded-directory negatives.
6. The legacy zero-findings fixture exposed both missing entrypoints before the
   two current package declarations were added. The stored generated Drop Calf
   fixture remains verbatim: its older revision predates release wiring, so static
   temporary package copies receive the exact two commands from the pinned source.
   Generated and owner-extended checks pass; independently removed and inert
   entrypoints produce only the intended informational finding and stay out of
   error-only gates. No helper or check command is executed.

### Validation

- Focused native tests and snapshots: 2 suites, 54 cases passed.
- Both release definitions: native package routing across all four shipped tiers
  passed; capability report lists exactly both active release rules.
- Explicit authoring checks, `shellcheck -x`, `shfmt -d`, `git diff --check` and
  repository-wide `bun run format:check` passed.
- Full `bun run test`: exit 0; 209 consumer rule suites, generated/security/scope
  and page-title fixtures, 6 authoring suites, metadata/value/orchestration checks,
  capability coverage, scope composition, severity matrix/gates, repository-wide
  authoring enforcement and package-boundary checks passed.
- No release helper, validation entrypoint, git-cliff or remote operation was
  executed. No dependencies, source generator, stored generated fixture or tier
  configuration changed; existing consumer snapshots were preserved.

Independent final review found no concrete correctness, acceptance or security
blockers. Implementation verification did not run a release, helper, validation
entrypoint, git-cliff or remote publication. The final Git commit is the user's
explicitly requested delivery action, not a test of release behavior.
