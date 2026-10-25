# 08: Check explicit release entrypoints without running a release

**What to build:** Maintainers can identify a missing or inert explicit release entrypoint while retaining their own release checks, and discover the check through `capability:release`.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** release

**Coverage today:** No existing consumer rule checks release wiring. General lifecycle and download/execute checks are related safety guidance, not proof of this capability's release workflow.

**Source convention:** Drop Calf enforces a release script that explicitly invokes its maintained Bash release helper. It seeds release:check with test followed by typecheck for forge-app, restores it only if missing, and preserves owner-defined check content. The helper guards main/clean worktree, derives versions/notes with git-cliff, commits and tags, then atomically pushes main and its explicit tag to origin. Init/update/validate do not perform a release.

- [ ] Add a package check for a string-valued release entrypoint invoking the maintained Bash release helper, rejecting missing, placeholder, echo-only or misplaced fields. Do not treat an unrelated shell command as a release helper.
- [ ] Check release:check is a usable non-placeholder entrypoint without freezing its seeded command text or requiring the checks supplied by a library profile. Keep ordinary owner-authored validation extensions acceptable.
- [ ] Tag release-specific findings `capability:release`. Keep git-cliff tool/command ownership in ticket 07; no artificial dependency on the changelog ticket is needed to test local package wiring.
- [ ] Verify generated release wiring passes and local mutations fail. If shell helper inspection is supported, leave detailed branch/atomic-push semantics to a separately scoped follow-up rather than building a shell interpreter in this ticket.
- [ ] Document that local script presence does not prove helper existence, checks execution, worktree cleanliness or atomic publication. Never run release, git writes or remote publication during verification.

**Boundary:** File names identify the current generated workflow, not a promise that ast-grep resolves external helper contents. The shared definition of done applies.
