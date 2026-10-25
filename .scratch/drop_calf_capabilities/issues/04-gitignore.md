# 04: Establish honest static coverage for managed gitignore conventions

**What to build:** Maintainers get a verified answer about which Drop Calf ignore conventions Forge Prelint can actually check, with a working native rule only if a supported parser can represent the artifact reliably. An unsupported capability remains an explicit coverage gap, not a fabricated green check.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** gitignore

**Coverage today:** No existing rule checks Git ignore files. Biome exclusions are a different capability and must not be mislabeled `capability:gitignore`.

**Source convention:** Drop Calf seeds a gitignore.io topics block and a drop-calf additional-ignores block. Markers use Created by / End of source comments. Additional ignores include scratch, session, temporary and tool cache paths. Update replaces only existing owned blocks, preserves outside bytes and deliberately does not restore absent blocks. Git acceptance does not prove desired paths are ignored.

- [ ] Run a bounded feasibility test using the repository's installed ast-grep languages and routing support on real ignore-file content, including comments, negation, wildcard and slash syntax. Do not treat the file as YAML/JSON or introduce a new parser/plugin merely for this ticket.
- [ ] If supported, deliver one useful rule for malformed owned marker pairing in an existing block, tagged `capability:gitignore`, with passing generated content and failing missing-end/nested-marker examples. Do not require whole-file template equality or a mandatory block that update intentionally does not restore.
- [ ] If unsupported, publish a tested coverage-gap disposition instead of a non-executable rule: record the parser limitation, the owned-marker and preserve-outside-block conventions, and that Drop Calf update is the existing owner of reconciliation. This is an accepted completion path for the ticket.
- [ ] Keep effective ignore evaluation, negation ordering, tracked-file status and missing-file detection outside ast-grep claims. Do not introduce a separate repository auditor or silently widen the scope into an ignore engine.
- [ ] Make capability coverage reporting distinguish implemented checks from this explicit unsupported/gap result; never add an inert placeholder just to expose a tag.

**Boundary:** This is the only intentionally feasibility-led slice; it must end with either runnable evidence or an explicit limitation. The shared definition of done applies.
