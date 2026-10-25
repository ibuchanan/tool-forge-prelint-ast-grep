# 14: Map compiler conventions and check the typecheck lint delegate

**What to build:** Forge-app compiler and typecheck checks are discoverable under `capability:typescript`, and a missing or inert namespaced typecheck delegate is reported without applying the base compiler policy incorrectly to a dependency-selected config variant.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** typescript

**Coverage today:** Reuse `require-typescript-build-script`, `typecheck-with-typescript`, `use-typescript-5`, the existing base `require-tsconfig-*`/`use-tsconfig-*` rules, Forge JSX/source-map mismatch rules, and all `require-tsconfig-typecheck-*` checks. There is no dedicated lint:check:typecheck delegate check. Existing filename routing must be reviewed rather than assumed to distinguish base and typecheck policy.

**Source convention:** Forge apps build the root project, typecheck the dedicated no-emit project, and delegate lint:check:typecheck to typecheck. Base defaults include ES2022, Node resolution, source root/dist output and strict settings. Typecheck config extends the base, widens rootDir, includes source/test/tests plus Vitest config when Vitest is declared, excludes generated/spec paths and uses Bundler resolution for the default Vitest-backed profile. Other dependency traits select different policies.

- [ ] Add `capability:typescript` to existing rules that directly check these compiler/build conventions, keeping language companions consistent and avoiding blanket tags on unrelated source-code rules.
- [ ] Add a root scripts.lint:check:typecheck delegate check accepting the generated npm command and supported Bun equivalent. Reject missing, inert, wrong-target and nested fields; do not duplicate the existing typecheck compiler-command rule.
- [ ] Test representative final base and typecheck configs independently. Correct any existing native glob or matcher that wrongly forces base-only rootDir/module-resolution defaults onto the typecheck variant; preserve supported owner choices and document any behavior change.
- [ ] Do not infer package dependency traits from another file in ast-grep. A typecheck-resolution check must either tolerate supported Node/Bundler variants or explicitly scope a documented default-profile policy; do not report every Bundler value as Forge-bundler incompatibility.
- [ ] Keep supported inherited noEmit and include behavior within the stated rule limitations. Do not require a declarations project in forge-app merely because library builds use one, or mistake showConfig acceptance for compilation success.
- [ ] Run focused compiler/script tests, JSONC/filename routing evidence and authoring/fixture checks; metadata-only rules retain snapshots while actual fixes get targeted regression cases.

**Boundary:** No compiler execution or cross-file include/dependency proof is promised by static rules. The shared definition of done applies.
