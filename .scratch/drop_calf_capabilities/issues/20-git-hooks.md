# 20: Map Git hook checks and add pre-push delegation coverage

**What to build:** Maintainers can find existing hook guards with `capability:git-hooks`, and a hook that duplicates or bypasses the central check workflow receives a focused finding rather than silently drifting from local/CI validation.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** git-hooks

**Coverage today:** Reuse `require-lefthook-prepare`, `require-lefthook-pre-commit-format` and `require-lefthook-pre-commit-gitleaks`. Existing pre-commit rules mostly recognize entry names, not executable command bodies. No rule establishes pre-push delegation to the package check script.

**Source convention:** Drop Calf maintains prepare as Lefthook installation with an optional failure-tolerant fallback. It seeds owner-managed hook YAML: parallel pre-commit Gitleaks on staged changes, formatting with stage_fixed, and pre-push delegation to check. The formatter hook writes intentionally; default lint/check scripts remain read-only. Validation uses isolated Git metadata without installing or executing hooks.

- [ ] Add `capability:git-hooks` to the three existing definitions, preserving their behavior where already sufficient. Clarify that pre-commit formatting intentionally writes and stages changes rather than being format:check.
- [ ] Add a YAML check for an existing pre-push command that delegates to the package check script, accepting the generated npm invocation and supported Bun spelling. Missing hook/delegation, inert echo and a copied direct tool list must be distinguishable in tests.
- [ ] Strengthen existing pre-commit checks only enough to reject a correctly named but inert command and recognize the seeded staged Gitleaks/formatter behavior; if behavior remains key-only, state that gap instead of claiming execution coverage.
- [ ] Do not require owner hook YAML to remain byte-identical, freeze command names unnecessarily, or demand build-on-prepare behavior from the library profile. Keep ordinary equivalent hook naming/configuration variants within the documented support boundary.
- [ ] Verify prepare fallback variants and the generated YAML pass; wrong nesting, similarly named keys and unrelated runs do not satisfy requirements. Add real-file routing tests because snippet tests cannot prove filename scope.
- [ ] Document that installed hooks, scanner availability, staging effects, skip filters and successful hook execution are not established by declarations. Do not run prepare, hooks, Gitleaks, formatting or Git writes during static-rule verification.

**Boundary:** Aggregate composition stays in capability:lint; tags on hook checks do not move package command ownership into Lefthook. The shared definition of done applies.
