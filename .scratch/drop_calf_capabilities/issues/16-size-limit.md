# 16: Map size-budget checks and correct workflow ownership

**What to build:** Existing size-budget and build-before-measure guidance is discoverable through `capability:size-limit`, and diagnostics accurately describe the current check aggregate rather than an obsolete hook structure.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** size-limit

**Coverage today:** Reuse `use-size-limit`, `no-size-limit-preset-app` and `require-size-check-script`. The script rule already checks build-before-measure, but its note says the pre-push hook calls size:check directly; current Drop Calf instead routes pre-push through check.

**Source convention:** Drop Calf seeds size-limit with @size-limit/file and an initial 10 kB dist JavaScript budget. It enforces the size:check command that builds before measuring; budgets, labels and paths remain owner-managed. Only a legacy size script equal to the old generated command is removed; arbitrary owner size scripts are preserved.

- [ ] Add `capability:size-limit` to the three existing rules, preserving IDs, tiers, native scope, ratings/severity and any prior tags.
- [ ] Update outdated note/rationale text to describe pre-push → check → size:check, keeping package-script composition owned by lint and hook wiring owned by git-hooks. No new blocker on those tickets is needed for prose correction.
- [ ] Verify the generated tools, budget and exact build-before-measure command pass current checks; retain existing diagnostics for configured tooling without the required command and the disallowed preset.
- [ ] Do not freeze the initial 10 kB threshold, Forge app bundle label, dist glob or exact tool version; do not flag a retained custom size script merely because the generator removed a particular legacy command.
- [ ] Keep actual byte measurement, external configuration and paired tool compatibility as explicit limitations. Do not claim that absence of a tool proves material Forge spend.
- [ ] This is primarily a tag/documentation slice: consumer snapshots should remain unchanged unless a separately evidenced matcher defect is corrected. Run focused and authoring checks.

**Boundary:** Do not build, delete or measure owner output to test static rules. The shared definition of done applies.
