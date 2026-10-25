# 03: Map OSS licensing checks and validate catalog license input

**What to build:** Forge sample maintainers can find existing Apache licensing guidance by capability and receive a local finding when the catalog license supplied to the pinned OSS templates is unsupported.

**Blocked by:** 01 — Check catalog conventions and enable capability tags.

**Status:** ready-for-agent

**Capability:** oss

**Coverage today:** Reuse `require-package-license-apache-2-0`. There are no consumer catalog-license rules or checks for the generated OSS document suite.

**Source convention:** OSS seeds LICENSE, README, contribution, conduct, SECURITY and OWNER documents. Authoritative pinned legal/ownership assets are refreshed using catalog metadata, while owner README prose is preserved according to the capability's update behavior. The pinned OSS template supports Apache-2.0. Node derives the package license from the same catalog annotation; OSS does not independently own package reconciliation.

- [ ] Tag `require-package-license-apache-2-0` with `capability:oss`; add `capability:node` only with the documented package-license derivation relationship, without changing the existing policy or severity.
- [ ] Add a narrowly scoped catalog finding for absent, empty or unsupported forge-ranch/license input to the selected Apache OSS convention; tag it `capability:catalog` and `capability:oss`, explaining the producer/consumer mapping.
- [ ] Accept the current generated catalog and package; reject a changed license annotation and package license independently. Unrelated nested license keys must not satisfy either check.
- [ ] Separate the catalog-dependent OSS convention from generic Backstage acceptance. Do not require byte-identical README text, a fixed year/owner, or erase owner-authored prose.
- [ ] Document file existence, legal-document equivalence and catalog/package/OWNER agreement as cross-file or plain-text gaps left to Drop Calf/native tools. Run metadata, rule and real-file routing checks for the new catalog scope.

**Boundary:** No missing LICENSE or SECURITY finding can arise from a file that was never scanned. Do not add unsupported document parsers solely to carry a tag. The shared definition of done applies.
