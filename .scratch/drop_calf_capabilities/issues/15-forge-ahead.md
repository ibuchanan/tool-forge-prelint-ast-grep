# 15: Map Forge Ahead checks and make dependency placement truthful

**What to build:** Maintainers can discover the existing Forge Ahead dependency conventions through `capability:forge-ahead`, and an unrelated metadata key or development-only entry no longer masquerades as the runtime dependency described by a rule.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** forge-ahead

**Coverage today:** Reuse `use-forge-ahead-api-types`, `use-forge-ahead-errors` and `use-forge-ahead-logging`. Their current descendant key searches do not reliably establish production dependency placement. `no-verbose-hot-path-logging` expresses additional runtime logging advice; dependency seeding alone does not make it a generated convention.

**Source convention:** Drop Calf seeds three production dependencies: @forge-ahead/atlassian-api-types, @forge-ahead/errors and @forge-ahead/logging. References are owner-managed and freshness skips GitHub references. No source import, logger use, redaction setting or error-handling behavior is generated or validated by this capability.

- [ ] Add `capability:forge-ahead` to the three existing dependency rules; do not create duplicates or tag all generic logging/security rules.
- [ ] Correct the root dependency placement checks to match their existing claims: an entry in unrelated metadata, scripts or devDependencies must not satisfy a rule that explicitly asks for a production dependency. Accept the generated entries and supported owner-selected dependency references without version pinning.
- [ ] Retain the API-types rule's current @forge/api applicability gate unless a separately reviewed convention decision intentionally broadens it; an unconditional seed does not by itself justify flagging frontend-only apps. Explain partial seed coverage rather than claiming full parity.
- [ ] Keep seed-only dependency suggestions advisory and document that owner removal can be intentional. Installing a preferred package does not prove runtime helper adoption, correctness or redaction.
- [ ] Add focused nested-key/section regression cases for intentional matcher corrections; metadata-only mappings preserve snapshots. Record source-usage and version compatibility as build/test/native-tool concerns.

**Boundary:** Do not require importing every seeded package or force exact GitHub hashes. The shared definition of done applies.
