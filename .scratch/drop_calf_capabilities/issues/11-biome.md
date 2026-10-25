# 11: Tag existing Biome script and configuration conventions

**What to build:** Maintainers can discover the already-covered Biome conventions by `capability:biome`, with no duplicate rules or unnecessary changes to owner-managed configuration.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** biome

**Coverage today:** Reuse `lint-and-format-with-biome`, `require-biome-files-exclude-dist`, `require-biome-formatter-indent-style`, `require-biome-vcs-default-branch` and `require-biome-vcs-use-ignore-file`. The current working tree already aligns the script rule with lint:check:biome and lint:check:format. The shared `no-write-flags-in-readonly-script` guard also applies to Biome check tasks.

**Source convention:** Biome package scripts are maintained. Configuration and EditorConfig are seeded then owner-managed; update lets Biome migrate an existing root config rather than restoring template policy. Current seed uses hard exclusions for dist/specs/vendor, Git ignore integration/main, space indentation, recommended linting, and explicit overrides; these are not all immutable application requirements.

- [ ] Add `capability:biome` to the five existing Biome rules. Add that tag to the shared read-only guard only with a documented relationship to its formatting/lint task convention; preserve any capability:lint tag added by ticket 12.
- [ ] Retain the current npm/Bun format-check delegation support, separate write-back commands and new task names. Do not reproduce the already-landed-in-working-tree script matcher changes.
- [ ] Keep configuration checks explicitly described as reviewed team-default advice rather than claiming Drop Calf update enforces every seed value. Preserve owner customization/suppression guidance and do not create rules for every template setting.
- [ ] Prove the generated script family and both supported Biome JSON/JSONC file routes pass the existing intended checks; existing mutated fixture cases keep their diagnostics. New seed changes should not force an exact schema-version pin.
- [ ] This slice should remain metadata-only for matcher behavior: retain IDs, native scope, tiers, ratings/severity and consumer snapshots; run tag/authoring and focused rule tests. Record any newly discovered behavioral gap as a scoped follow-up, not speculative expansion.

**Boundary:** Effective inherited Biome configuration and tool acceptance stay with Biome. The shared definition of done applies.
