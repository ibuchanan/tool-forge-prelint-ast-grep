# 17: Check the Forge app dist-only clean command

**What to build:** Forge apps get a clear finding when the clean entrypoint is missing or has drifted into destructive dependency/lockfile cleanup instead of Drop Calf's dist-only workflow.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** completed

**Capability:** clean-build

**Coverage today:** No existing consumer rule checks the clean command. Script naming and lifecycle checks do not establish its cleanup target.

**Source convention:** The forge-app profile selects cleanBuild with reinstall false, maintaining a clean command that removes dist only. Another profile explicitly selects reinstall behavior that also removes node_modules and a lockfile; that is not the forge-app convention. Init/update/validate never execute the cleanup command.

- [x] Add an ecosol root scripts.clean convention check accepting the generated dist-only removal command and narrowly documented equivalent spelling, with no broad shell interpretation.
- [x] Diagnose missing/non-string/inert/wrongly nested scripts and commands that delete the project root, source, dependency tree or lockfile instead of the intended output directory. Do not label a quoted mention as proof that a deletion ran.
- [x] Tag the rule `capability:clean-build`, cite the pinned forge-app selection and cleanup implementation, and state the app-directory scoping precondition so library reinstall workflows are not misreported as Forge defaults.
- [x] Add generated positive fixtures and minimally mutated negative commands, including lookalike directory names and inert echoes. Command-text checks must not be presented as a complete shell safety audit.
- [x] Keep IDs/tier/ratings/scope explicit for the new rule, add package routing evidence and run authoring/fixture tests. No changes to build output or dependencies are permitted during verification.

**Boundary:** The rule validates a configured command, not whether dist exists, cleanup occurred, or arbitrary shell wrappers are safe. The shared definition of done applies.

## Implementation update — 2026-10-25

- Selected in dependency order: ticket 01 is complete and tickets 02–16 are complete; 17 is the lowest-numbered remaining ready ticket. Used the approved direct-command and native-routing seams.
- Added `require-clean-script` in ecosol/package-scripts: Json, medium precision, low impact, informational severity, `package-json` plus additive `tests` scope, tagged `capability:clean-build`. Only direct root `scripts.clean` satisfies the rule.
- Accepts `rm -rf dist` plus ordinary spacing, optional `./` prefix and optional trailing slash; no extra arguments, alternate flags or shell interpretation. Missing, non-string, nested, inert, lookalike, destructive-target and chained commands get one bounded recommendation, not an execution or deletion conclusion. Equivalent wrappers require owner review/suppression.
- Confirmed the Forge-app default and distinct library `reinstall: true` selection from `src/composition/profiles.ts` and `src/capabilities/clean-build.ts` at pinned revision `be86d05309a32f7eef8988205208c17ca94e7a4c`; cited both in the rule. App-directory selection remains the caller's responsibility.
- Added 36 focused rule examples (3 valid, 33 invalid) and a new snapshot, 12 static generated-package variants, capability discovery assertion and native package-routing row. The legacy zero-findings fixture gains only its missing maintained clean declaration. Added a coverage-reference section documenting accepted syntax and limits.
- TDD evidence: the generated-package mutation initially failed because a missing clean entrypoint returned zero findings (`.scratch/tmp_rovo_ticket17_missing_red.log`). After implementation it returned one informational finding. The spaced `./dist/` spelling failed before broadening only the bounded target/spacing pattern, then passed (`.scratch/tmp_rovo_ticket17_equivalent_red.log`, `.scratch/tmp_rovo_ticket17_equivalent_green.log`).
- Passed: focused suite (36 examples), all 212 consumer rule suites, full authoring suite (including capability/severity/scope-composition/package-boundary checks), focused four-tier native routing, Prettier, ShellCheck, shfmt and `git diff --check`. Full fixture suite passed, including generated-package mutations, security checks, all 212 definitions across four shipped tiers and page-title diagnostics. Evidence: `.scratch/tmp_rovo_ticket17_{focused,rules,authoring,routing,fixtures,format}.log`.
- Read-only acceptance review found no blockers or material testing gaps. Stored generated Drop Calf snapshot, vendored source, dependencies, build output, existing consumer snapshots and other tiers are unchanged. No cleanup, build, install, release, deployment or secrets resolution was executed.
