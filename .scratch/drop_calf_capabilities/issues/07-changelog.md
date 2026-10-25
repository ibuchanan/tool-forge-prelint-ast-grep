# 07: Check the idempotent changelog command convention

**What to build:** A Forge app receives an actionable finding when its changelog entrypoint is absent or uses the old prepend workflow instead of regenerating the unreleased changelog through the owner's git-cliff policy.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** changelog

**Coverage today:** No consumer rule checks the changelog command. `no-stale-placeholder` can reject a placeholder but does not establish the git-cliff convention.

**Source convention:** Drop Calf maintains a changelog script invoking git cliff with the cliff.toml config, unreleased selection and output to CHANGELOG.md. It seeds git-cliff and initial policy/output documents; policy and changelog are owner-managed after init. Regeneration uses output rather than prepend to avoid duplicate headings/entries.

- [ ] Add a root scripts.changelog check for the configured git-cliff regenerate workflow; accept supported output-option spellings and harmless flag ordering, while rejecting missing commands, inert echo/lookalike commands and prepend-only variants.
- [ ] Accept the exact pinned generated command. Do not require byte-identical output, a fixed release version, pinned commit categories or an immutable policy file.
- [ ] Tag the convention rule `capability:changelog`, preserving generic placeholder rules without assigning them ownership of every capability they can encounter.
- [ ] Give the matcher an accurate command-text limitation, references to Drop Calf and git-cliff, and reviewed precision/impact. A missing preferred script is not proof release history is invalid.
- [ ] Add positive/negative matcher tests and existing package filename routing checks; record TOML policy acceptance, git history and output equivalence as native-tool coverage, not AST claims.

**Boundary:** No git-cliff execution, file regeneration or Git history mutation is necessary for static-rule tests. The shared definition of done applies.
