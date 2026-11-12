# OpenGrep Forge security rule migration

Source: `vendor/forge-skills/skills/forge-security-review/assets/opengrep-rules/forge-security-rules.yaml` (44 rules). This is a **partial migration**, not a claim of equivalent coverage. ast-grep matches syntax within a file; it does not implement OpenGrep taint tracking, cross-file alias resolution, runtime authorization checks, or secret provenance. Do not replace the OpenGrep security review with these checks without accepting the gaps below.

| OpenGrep source rule                                                                                                                                                                                                                                   | ast-grep status                                                                                                                                                     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forge-bridge-postmessage-wildcard-origin`                                                                                                                                                                                                             | New `review-wildcard-postmessage-origin` (literal target origin; review whether message is sensitive and target is a Window)                                        |
| `forge-private-cross-tenant-api`                                                                                                                                                                                                                       | New `no-private-forge-request-atlassian` (direct call only; no tenant-flow proof)                                                                                   |
| `forge-webtrigger-literal-shared-secret`                                                                                                                                                                                                               | New `review-webtrigger-literal-secret` (direct literal comparisons only; not proof of authentication)                                                               |
| `forge-manifest-wildcard-egress`                                                                                                                                                                                                                       | Existing `no-wildcard-egress` covers exact wildcard fetch entries; script-host forms are not equivalent                                                             |
| `forge-manifest-csp-unsafe-script-directive`                                                                                                                                                                                                           | Existing `no-unsafe-custom-ui-csp` reviews unsafe script directives, with different match scope                                                                     |
| `forge-sandbox-no-dynamic-code`                                                                                                                                                                                                                        | Existing `no-dynamic-code-evaluation` covers explicit dynamic evaluation; not necessarily every source form                                                         |
| `forge-module-state-holds-request-data`, `forge-process-env-mutation`                                                                                                                                                                                  | Existing `no-module-scope-mutable-state` and `no-global-state-mutation` cover some mutation shapes, without request-data flow                                       |
| `forge-unsafe-html-rendering`, `forge-bridge-invoke-to-html-sink`, `forge-bridge-invoke-then-html-sink`, `forge-bridge-product-data-to-html-sink`, `forge-bridge-product-data-then-html-sink`                                                          | Existing `review-raw-html-sink` checks sinks, not whether bridge/product data reaches them                                                                          |
| `forge-dynamic-raw-sql-query`, `forge-jql-cql-injection`, `forge-asapp-query-in-request-body`                                                                                                                                                          | Existing `review-input-sql` and `no-jira-search-without-fields` address related but different conditions; **not converted**                                         |
| `forge-api-fetch-tainted-url`, `forge-asapp-user-input-in-path`, `forge-assume-trusted-route-dynamic-path`, `forge-invoke-remote-dynamic-path`, `forge-storage-key-user-controlled`, `forge-storage-tainted-key`, `forge-request-headers-from-payload` | **Not converted**: source-to-sink taint and/or authorization context cannot be established by the current syntax checks                                             |
| `forge-resolver-returns-secret`, `forge-token-in-plain-storage`, `forge-sensitive-data-console-logging`, `forge-ui-credential-console-logging`, `forge-atlassian-api-token-basic-auth`, `forge-bitbucket-basic-auth-credential`                        | **Not converted**: secret provenance/context would need additional review; `review-hardcoded-secret` and `no-sensitive-data-logging` are related but not equivalent |
| `forge-webtrigger-missing-auth`, `forge-resolver-global-write-without-permission-check`, `forge-payload-identity-trusted`, `forge-context-identifier-payload-fallback`, `forge-hardcoded-account-gate`, `forge-jwt-literal-secret`                     | **Not converted**: authorization or authentication context needs a dedicated design and focused fixtures                                                            |
| `forge-sandbox-no-child-process`, `forge-sandbox-no-filesystem`, `forge-process-env-in-ui-render`, `forge-webtrigger-html-response-interpolation`, `forge-payload-merge-prototype-pollution`                                                           | **Not converted**: needs targeted syntax and counterexample tests                                                                                                   |
| `forge-manifest-shared-hosting-wildcard-egress`                                                                                                                                                                                                        | **Not converted**: needs YAML path-aware checks and routing tests                                                                                                   |
| `forge-llm-output-drives-privileged-action`                                                                                                                                                                                                            | **Not converted**: requires model-output provenance and action authorization analysis                                                                               |

`forge-manifest-anonymous-access-module` now has a **partial syntax conversion** in
`review-anonymous-module-access` (recommended, inherited by the other tiers). It
reviews direct module declarations under top-level `modules`: literal
`access: anonymous` or access lists containing `anonymous`, and `unlicensedAccess`
lists containing `anonymous`, `unlicensed`, or `customer`. Block/flow mappings and
sequences and quoted keys/values are covered; unrelated and nested configuration
keys are excluded. Real scanner fixtures check both manifest filenames, tier
composition, and generated/dependency directory exclusions. Unlicensed/customer
users may be authenticated. A finding proves neither module/user-type support nor
missing resolver authorization, restricted-data exposure, unsafe writes, or
billable abuse. YAML aliases/merges and cross-file resolver reachability are not
resolved; OpenGrep/manual authorization review remains necessary.

`forge-manifest-dev-tunnel-egress` now has a **partial syntax conversion** in
`review-development-tunnel-egress` (recommended, inherited by the other tiers).
It checks literal scalar and address-object entries under top-level
`permissions.external.fetch.backend/client` and the external
`scripts/styles/images/fonts/media/frames` lists. Block/flow mappings and sequences,
quoted keys/values, host wildcards, case-insensitive hosts and URL ports/paths are
covered. Hostname boundaries exclude lookalike hosts and tunnel names appearing
only in URL paths/queries, descriptions or unrelated keys. The service families
are ngrok/ngrok-free (io/app/dev), localtunnel.me, loca.lt, trycloudflare.com,
serveo.net, localhost.run, tunnelmole.com/net, localtonet.com and pinggy.io.
Real scanner fixtures check both manifest filenames, tier inheritance and directory
exclusions. This is bounded YAML syntax matching, not URL validation, a complete
tunnel-service inventory, or proof of hostname reassignment, traffic or compromise.
Aliases, merge expansion, tagged/anchored scalar normalization, block scalars,
computed values and remote-reference destinations are not resolved; manual review
remains necessary. Intentional tunnel use requires review rather than an automatic fix.

The `review-` rules report candidates rather than proven vulnerabilities. See each rule's `note` and precision rationale for false positives and missed forms. For rule authoring conventions, see [rule-authoring-policy](rule-authoring-policy.md).
