# 12: Map and verify independent lint and check aggregates

**What to build:** Forge apps get consistent feedback when aggregate script wiring stops selecting intended read-only checks, and authors can find the existing orchestration rules through `capability:lint` independently of Git hook setup.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** lint

**Coverage today:** `require-composed-lint` and `require-composed-check` recognize direct run-p commands, but deliberately do not validate task coverage. `no-write-flags-in-readonly-script` already covers the lint:check namespace in the working tree. Existing task-presence rules belong to the capabilities supplying those tasks.

**Source convention:** The lint capability owns the runner dependency and aggregates. Lint runs the lint:check:* namespace with npm selected and labeled output. Check runs the lint, test, size:check and pack:check selection in parallel independently of Lefthook. Forge-app does not select the package-check capability, so an absent pack:check declaration is not by itself a convention failure; preserve the runner's optional-pattern behavior.

- [ ] Add `capability:lint` to both composition rules and the shared read-only guard, preserving any capability:biome mapping appended by ticket 11.
- [ ] Add focused same-package task-selection coverage for the generated lint:check glob and complete explicit equivalents. Diagnose a bare run-p command that omits all intended lint tasks rather than treating any argument as full composition compliance; avoid a general shell/glob interpreter.
- [ ] Check literal self-selection and inclusion of known write-back tasks in the aggregate where same-file command text proves it; keep supported equivalent explicit task lists and flag ordering. If a richer selection cannot be established from literal text, document the gap rather than invent completeness.
- [ ] Accept the current generated check brace pattern without requiring pack:check to exist in forge-app, and test absent optional task behavior through static fixtures/documented runner evidence. Do not require lint:docs to be selected: Drop Calf currently keeps that task outside lint:check:*.
- [ ] Keep aggregates independent of Lefthook and avoid moving the package scripts back to hook delegation. Tag-only changes preserve snapshots; intentional matcher changes receive new positive/negative tests and reviewed ratings.

**Boundary:** Individual tool dependencies and tasks are owned by their provider tickets. This ticket checks same-file wiring only, not execution success, shell expansion in arbitrary wrappers or cross-file app identity. The shared definition of done applies.
