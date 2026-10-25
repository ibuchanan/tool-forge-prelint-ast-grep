# 10: Map current Prelint tasks and complete scan exclusion coverage

**What to build:** The current namespaced Prelint workflow is discoverable by capability and checked without duplicating the already-updated lint rules or allowing scans to traverse dependencies and specifications accidentally.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** prelint

**Coverage today:** The current working tree already updates `lint-with-prelint`, `lint-with-forge`, `require-valid-prelint-config` and `require-prelint-node-modules-glob` for lint:check names. Companion config/glob rules retain legacy-name validation. Do not recreate this work or revert it to the vendored generator. There is no equivalent explicit specs exclusion check.

**Source convention:** The capability maintains lint:check:prelint as an ast-grep scan excluding specs and node_modules with a shipped ecosol config under the installed Prelint dependency. It also supplies lint:check:forge. Dependency keys can differ across supported installations; the scan aggregate belongs to lint, not prelint.

- [ ] Add `capability:prelint` to the four existing rule definitions. Keep `capability:forge-manifest` on the Forge task if ticket 06 has already appended it, and otherwise permit that later additive mapping.
- [ ] Preserve the already-tested current task names, accepted shipped-tier config paths, package aliases and legacy config/glob validation. Do not hard-code the installation folder to one dependency name or require current dependency versions.
- [ ] Add a bounded check for the specifications exclusion on the existing Prelint scan task, or extend the existing glob rule without duplicating diagnostics. Distinguish missing specs exclusion from missing dependency exclusion and use an actionable message.
- [ ] Verify the exact generated command passes and missing config, wrong config, missing node_modules exclusion and missing specs exclusion mutations fail the relevant rule. Avoid imposing scan flags on unrelated scripts.
- [ ] Keep config existence, actual installed tools, scan execution and project-wide coverage out of the matcher claims; preserve metadata and scope checks and update only intentionally affected snapshots.

**Boundary:** Ticket 09 resolves the independent direct Forge lint versus Fence Rider preference. This ticket must not silently change that policy. The shared definition of done applies.
