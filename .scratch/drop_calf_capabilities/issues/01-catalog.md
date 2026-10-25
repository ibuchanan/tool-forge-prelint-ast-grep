# 01: Check catalog conventions and enable capability tags

**What to build:** A Forge app with a locally malformed catalog receives actionable convention findings, and rule authors can map checks to Drop Calf capabilities without breaking the existing module-tag contract. Deliver the first usable `capability:catalog` mapping in the same slice as the vocabulary expansion.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

**Capability:** catalog

**Coverage today:** No consumer rule targets catalog-info.yaml. Existing authoring rules validate rule definitions, not app catalogs. The policy, supplemental value checker, and recipe preconditions currently accept module tags only.

**Source convention:** Catalog initialization seeds a Backstage Component, normalized metadata.name, project title, spec.type forge-app, experimental lifecycle, a user owner reference, and forge-ranch annotations for package-name, license and copyright-date. Catalog update preserves owner content. Validation checks Backstage structure, Component kind, user owner and optional copyright date; downstream consumers impose their own annotation requirements.

- [ ] Extend documented tag semantics and the glossary to permit module and capability relevance. Introduce the exact 20-name vocabulary in the backlog index; accept distinct mixed module/capability tags, preserve ordering/content on unrelated edits, and reject misspellings, unknown capabilities, malformed values, duplicates and non-string entries. Update both authoring value checks and every metadata recipe precondition that currently rejects capability tags.
- [ ] Add catalog findings for an existing catalog's non-Component kind and missing/invalid spec.owner user reference, accepting both user:id and user:namespace/id forms supported by Drop Calf. Do not require only the initially seeded default namespace.
- [ ] Check an explicitly declared copyright-date for the supported year/year-range shape; do not claim regex proves chronological ordering or Backstage schema validity. Optional absent annotations are not globally required by this first slice; consumers add their own checks later.
- [ ] Tag all new catalog checks `capability:catalog`, cite the pinned catalog implementation and authoritative Backstage guidance, and prove the generated catalog passes. Do not freeze lifecycle, title, or copyright year at seed values.
- [ ] Add focused matcher and filename-routing evidence plus tag/recipe acceptance and rejection tests, including preservation of existing module tags. Keep existing module-only rules and consumer snapshots working.

**Boundary:** Scan existing catalog-info.yaml documents only; no missing-file detection, remote user lookup, cross-file identity comparison, or claim of full schema validation. The shared definition of done in the backlog index applies.
