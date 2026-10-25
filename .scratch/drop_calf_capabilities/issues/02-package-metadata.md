# 02: Map existing package metadata checks to Drop Calf

**What to build:** Authors can discover the existing checks for a private ESM Forge app through `capability:package-metadata`, without introducing duplicate package rules or freezing release identity.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** package-metadata

**Coverage today:** `require-package-type-module` and `require-package-private-true` already enforce the two forge-app package policies. `no-package-main`, `no-package-types` and `no-package-exports` express additional Forge packaging advice, not policies contributed by this capability; do not assign them this tag automatically.

**Source convention:** The capability enforces type module and private true; seeds version 0.1.0; and updates name, optional description and author from catalog input while preserving release version. Its native validation checks metadata types/formats rather than equality with catalog values.

- [ ] Add `capability:package-metadata` to the existing type and privacy checks, preserving rule IDs, matcher behavior, scope, tiers, ratings, severity and existing tags. This slice is metadata-only for these already-covered policies.
- [ ] Demonstrate the current generated package passes and explicit CommonJS/missing type or false/missing private still produces the existing expected findings.
- [ ] Record structural name/version/description/author validation as consuming-tool coverage unless a concrete high-signal local gap is demonstrated; do not add a partial semver parser or require author presence when native validation permits omission.
- [ ] Record cross-file catalog identity reconciliation as out of scope. Never require version 0.1.0, a particular package name, a fixed description or a particular staff ID.
- [ ] Verify capability-tag discovery returns both existing rules, authoring checks accept the metadata, and consumer snapshots remain unchanged.

**Boundary:** The capability applies to Forge-app packages, not every workspace root or published library. The shared definition of done applies.
