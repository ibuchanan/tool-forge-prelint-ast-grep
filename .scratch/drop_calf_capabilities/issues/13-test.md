# 13: Map existing Vitest conventions to the test capability

**What to build:** A Forge app's existing one-shot, watch, coverage and explicit-import test conventions are discoverable together through `capability:test` without duplicating checks or confusing the capability name with the test runner.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** test

**Coverage today:** Reuse `require-vitest-run-script`, `require-vitest-coverage-script`, `use-explicit-vitest-watch` and `require-vitest-globals-false`. These already represent the selected Forge testing convention. Use the exact tag capability:test, not capability:vitest.

**Source convention:** The forge-app profile uses Vitest, unlike profiles that use Bun's runner. Maintained scripts run once, watch explicitly, and run once with coverage; current generated commands add passWithNoTests. Vitest and its matching V8 coverage provider are seeded, and globals false/V8 coverage/exclusions are owner-managed configuration. No sample test or coverage threshold is promised.

- [ ] Add `capability:test` to the four existing rule definitions, preserving IDs, tiers, native scope, ratings, severity and any existing tags. Prefer this metadata-only slice over additional rules for already-covered behavior.
- [ ] Retain accepted one-shot and coverage commands without forcing the optional passWithNoTests flag or its ordering. Keep watch flags out of the default noninteractive test script and allow the explicit watch entrypoint.
- [ ] Verify current generated scripts and globals configuration pass, and existing watch/coverage/global misuse examples still produce the same findings and snapshots.
- [ ] Describe provider version alignment and actual coverage initialization as native-tool/dependency evidence, not something the script matcher proves. Do not hard-code current Vitest versions, require sample tests, or invent coverage percentages.
- [ ] Preserve owner-managed configuration: seed V8 provider and exclusion choices may be documented as defaults, not silently promoted to mandatory policy. Verify authoring checks and capability-tag discovery.

**Boundary:** The tag maps the convention, not successful test execution, test quality, or presence of tests. No model evaluations are included. The shared definition of done applies.
