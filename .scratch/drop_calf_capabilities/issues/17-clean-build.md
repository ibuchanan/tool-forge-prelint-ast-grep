# 17: Check the Forge app dist-only clean command

**What to build:** Forge apps get a clear finding when the clean entrypoint is missing or has drifted into destructive dependency/lockfile cleanup instead of Drop Calf's dist-only workflow.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** clean-build

**Coverage today:** No existing consumer rule checks the clean command. Script naming and lifecycle checks do not establish its cleanup target.

**Source convention:** The forge-app profile selects cleanBuild with reinstall false, maintaining a clean command that removes dist only. Another profile explicitly selects reinstall behavior that also removes node_modules and a lockfile; that is not the forge-app convention. Init/update/validate never execute the cleanup command.

- [ ] Add an ecosol root scripts.clean convention check accepting the generated dist-only removal command and narrowly documented equivalent spelling, with no broad shell interpretation.
- [ ] Diagnose missing/non-string/inert/wrongly nested scripts and commands that delete the project root, source, dependency tree or lockfile instead of the intended output directory. Do not label a quoted mention as proof that a deletion ran.
- [ ] Tag the rule `capability:clean-build`, cite the pinned forge-app selection and cleanup implementation, and state the app-directory scoping precondition so library reinstall workflows are not misreported as Forge defaults.
- [ ] Add generated positive fixtures and minimally mutated negative commands, including lookalike directory names and inert echoes. Command-text checks must not be presented as a complete shell safety audit.
- [ ] Keep IDs/tier/ratings/scope explicit for the new rule, add package routing evidence and run authoring/fixture tests. No changes to build output or dependencies are permitted during verification.

**Boundary:** The rule validates a configured command, not whether dist exists, cleanup occurred, or arbitrary shell wrappers are safe. The shared definition of done applies.
