# 06: Check the local Forge runtime declaration and map manifest validation

**What to build:** An existing Forge manifest with no usable numeric Node runtime declaration receives a focused diagnostic, and the existing Forge-lint entrypoint is discoverable as part of the manifest capability without pretending to verify cross-file wiring.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** forge-manifest

**Coverage today:** `lint-with-forge` already checks the namespaced lint task. Other manifest rules cover egress, scopes, function costs and triggers, but these are not all conventions established by this capability and must not receive its tag wholesale. No current rule checks the runtime declaration shape.

**Source convention:** Drop Calf updates an existing manifest's app.runtime.name from a numeric .nvmrc pin, preserving app identity and other settings. Numeric pins may include v and minor/patch components; the resulting runtime is nodejs followed by the major and .x. Validation runs authenticated Forge lint; initialization does not create a manifest or module wiring.

- [ ] Add a check for an existing manifest's missing or malformed app.runtime.name, accepting the numeric Node runtime declaration shape rather than hard-coding the current Node 24 seed. Explain that syntactic shape does not establish platform support or agreement with .nvmrc.
- [ ] Scope and test manifest YAML structures, including flow/block forms and wrong nesting as supported; do not match unrelated runtime/name fields. New rules carry `capability:forge-manifest` and authoritative runtime references.
- [ ] Add `capability:forge-manifest` to `lint-with-forge` alongside its task-provider tag from ticket 10. Merge the distinct tag entries rather than replacing either; neither ticket depends on the other's matcher changes.
- [ ] Verify a generated numeric declaration passes and missing/malformed declaration examples fail. Do not impose particular module names, scopes, handlers, memory settings or app identifiers not selected by Drop Calf.
- [ ] Record .nvmrc agreement, export existence, credentials, missing-file detection and actual Forge lint success as consuming-tool or cross-file coverage gaps. Run static fixtures only; do not authenticate, deploy or install an app.

**Boundary:** Consult current Forge manifest guidance before implementing the rule. The check is for local convention shape, not a claim that any numeric runtime is supported. The shared definition of done applies.
