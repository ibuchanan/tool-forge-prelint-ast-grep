# 09: Align and tag SecretSpec and Fence Rider workflow checks

**What to build:** Drop Calf's generated Forge lifecycle scripts satisfy their convention checks, genuine unguarded generated-script execution is still flagged, and maintainers can discover those rules with `capability:secrets`.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** secrets

**Coverage today:** Reuse `use-forge-register`, `use-forge-deploy`, `use-forge-install`, `use-forge-uninstall`, `use-forge-upgrade`, `use-forge-variables-set`; the corresponding Fence Rider deploy/install/uninstall/variables checks; `require-fence-rider-script-execution`; and `no-unguarded-fence-rider-evaluation`. Existing `use-fence-rider-for-forge-lint` conflicts with current generated direct Forge lint. The tunnel preference is additional team policy; this capability seeds no tunnel task.

**Source convention:** Six Forge scripts are maintained. Register invokes Forge directly; deploy/install/uninstall/upgrade generate Fence Rider scripts and execute them only after generation succeeds; variables uses Fence Rider directly. Deploy/install/upgrade forward noninteractive/consent flags. SecretSpec declarations are owner-managed and its native validation checks TOML structure and declared scope members without resolving secrets.

- [ ] Tag the existing lifecycle and execution-safety checks that materially enforce these conventions `capability:secrets`, preserving their IDs and existing safety tests rather than creating duplicates.
- [ ] Test all six currently generated commands as a compatibility matrix, including guarded execution and forwarded flags. Missing scripts, wrong command roles, generation without execution and unguarded evaluation retain appropriate findings.
- [ ] Reconcile `use-fence-rider-for-forge-lint` with the fact that current Drop Calf emits direct lint:check:forge. Do not silently claim the generator uses a wrapper: document and implement a narrowly justified exception or retire the incompatible preference under explicit policy/severity review. Preserve protections on generated lifecycle commands.
- [ ] Do not require tunnel wrappers or SecretSpec values as conditions of satisfying Drop Calf's required capability. Keep broader tunnel/security guidance distinct from generator-convention coverage.
- [ ] Record SecretSpec TOML schema/scope membership as native-tool coverage unless a supported parser is demonstrated. Do not add fake YAML matching, resolve values, read real credentials, or claim AST text proves encryption or secret isolation.
- [ ] Prove generated package scripts pass the reconciled convention subset, mutated unsafe examples fail, and all affected rule/authoring/fixture regressions remain green.

**Boundary:** Reconcile the lint preference here; ticket 10 owns the lint task's presence and Prelint config/globs. Those are distinct policies and need no extra blocking edge. The shared definition of done applies.
