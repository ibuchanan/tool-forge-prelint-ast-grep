# 18: Offer advisory coverage for the seeded TODO workflow

**What to build:** Forge app owners can discover missing or inert TODO tooling as optional seed-convention advice, without having their intentionally customized or removed workflow treated as a broken Drop Calf installation.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** todo

**Coverage today:** No consumer rule checks scripts.todo. General placeholder rules intentionally do not cover this owner-managed entrypoint.

**Source convention:** Drop Calf seeds a tracked-file Git grep command with line numbers and literal text matching. The generated command assembles the TODO token to avoid matching itself, treats no matches as success, and preserves real error exit status. Update deliberately neither replaces nor re-adds this script; it is owner-managed after init.

- [ ] Add a narrowly advisory rule for absent/non-string/obviously inert root scripts.todo, tagged `capability:todo`; clearly state that this is a seeded convenience rather than an enforced update policy and document intentional-removal suppression.
- [ ] Accept the exact generated command, including split token quoting and its no-match handling. Accept nonempty owner-authored alternatives without pretending the matcher can prove they implement identical grep/exit semantics.
- [ ] Do not enforce a particular command string, fixed quote style, presence of TODO markers, a ban on TODO comments, or automatic ticket creation. Never match generic todos merely to increase diagnostics.
- [ ] Add passing generated/custom-script examples and failing missing/non-string/inert/metadata-nested examples. Use a low-consequence reviewed assessment under the severity matrix; do not promote this into a deployment blocker.
- [ ] Explain that tracked-file membership, no-match exit handling and actual Git errors are beyond the generic script-presence check. No Git invocation or repository mutation is needed for static-rule verification.

**Boundary:** If maintainers prefer to leave seed-only absence entirely unchecked, a reviewed metadata/coverage-gap disposition is preferable to mandatory exact enforcement. The shared definition of done applies.
