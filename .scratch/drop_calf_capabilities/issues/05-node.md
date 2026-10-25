# 05: Align Node checks with the current forge-app baseline

**What to build:** A current Drop Calf Forge app passes Node convention checks, and genuine package engines drift is reported without falsely freezing refreshed Node type dependencies at a seed literal.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** node

**Coverage today:** `use-node-24` requires the literal devDependency value 24 and omits engines. Its note says types are pinned to the runtime major. Current forge-app calls nodeBaseline without an explicit major, so existing types are kept fresh; the strict literal check is stale. `require-package-license-apache-2-0` covers the license derived through Node and is mapped in ticket 03.

**Source convention:** Seed .nvmrc at Node 24, the public npm registry configuration, and @types/node; remove engines on forge-app updates. Explicit-major semver constraints are a separate option used by other profiles, not this forge-app policy.

- [ ] Reuse and tag `use-node-24` with `capability:node`; correct its diagnostic, rationale and matcher so it does not claim current forge-app requires an exact @types/node 24 string. Preserve the ID unless a separately justified compatibility decision is approved.
- [ ] Keep a high-signal root package engines-absence check. Treat seeded type declaration presence separately from exact pin policy; do not add hard-coded current tool versions or attempt semver subset algebra in regex.
- [ ] Add regression examples for the current seed, a refreshed valid types declaration, engines present, and misleading nested fields. Record whether missing owner-removed types is advisory seed guidance or intentionally unchecked.
- [ ] Explicitly document numeric .nvmrc/public-registry conventions as separate artifact coverage gaps unless a supported native parser is demonstrated. Do not equate a JSON dependency declaration with runtime selection.
- [ ] Record runtime agreement with the manifest and catalog-derived package licensing as cross-file reconciliation owned by Drop Calf, not something this rule proves. Run focused tests, metadata checks and fixture regression.

**Boundary:** No host fnm changes or Node downloads are needed to validate a static rule. Coordinate package-license tagging through ticket 03 without duplicating its edit. The shared definition of done applies.
