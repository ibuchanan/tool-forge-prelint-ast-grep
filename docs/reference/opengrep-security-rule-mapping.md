# OpenGrep Forge security rule migration

Source: `vendor/forge-skills/skills/forge-security-review/assets/opengrep-rules/forge-security-rules.yaml` (44 rules). This is a **partial migration**, not a claim of equivalent coverage. ast-grep matches syntax within a file; it does not implement OpenGrep taint tracking, cross-file alias resolution, runtime authorization checks, or secret provenance. Do not replace the OpenGrep security review with these checks without accepting the gaps below.

| OpenGrep source rule                                                                                                                                                                                                                                   | ast-grep status                                                                                                                                                     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forge-bridge-postmessage-wildcard-origin`                                                                                                                                                                                                             | New `review-wildcard-postmessage-origin` (literal target origin; review whether message is sensitive and target is a Window)                                        |
| `forge-private-cross-tenant-api`                                                                                                                                                                                                                       | New `no-private-forge-request-atlassian` (direct call only; no tenant-flow proof)                                                                                   |
| `forge-webtrigger-literal-shared-secret`                                                                                                                                                                                                               | New `review-webtrigger-literal-secret` (direct literal comparisons only; not proof of authentication)                                                               |
| `forge-manifest-wildcard-egress`                                                                                                                                                                                                                       | Reconciled `no-wildcard-egress`: exact wildcard fetch/script scalars and address objects; partial syntax overlap, not engine equivalence                            |
| `forge-manifest-csp-unsafe-script-directive`                                                                                                                                                                                                           | Reconciled `no-unsafe-custom-ui-csp`: unsafe script directives plus CSP wildcard; partial syntax overlap with stricter YAML paths                                   |
| `forge-sandbox-no-dynamic-code`                                                                                                                                                                                                                        | Existing `no-dynamic-code-evaluation` covers explicit dynamic evaluation; not necessarily every source form                                                         |
| `forge-module-state-holds-request-data`, `forge-process-env-mutation`                                                                                                                                                                                  | Existing `no-module-scope-mutable-state` and `no-global-state-mutation` cover some mutation shapes, without request-data flow                                       |
| `forge-unsafe-html-rendering`, `forge-bridge-invoke-to-html-sink`, `forge-bridge-invoke-then-html-sink`, `forge-bridge-product-data-to-html-sink`, `forge-bridge-product-data-then-html-sink`                                                          | Existing `review-raw-html-sink` checks sinks, not whether bridge/product data reaches them                                                                          |
| `forge-dynamic-raw-sql-query`, `forge-jql-cql-injection`, `forge-asapp-query-in-request-body`                                                                                                                                                          | Existing `review-input-sql` and `no-jira-search-without-fields` address related but different conditions; **not converted**                                         |
| `forge-api-fetch-tainted-url`, `forge-asapp-user-input-in-path`, `forge-assume-trusted-route-dynamic-path`, `forge-invoke-remote-dynamic-path`, `forge-storage-key-user-controlled`, `forge-storage-tainted-key`, `forge-request-headers-from-payload` | **Not converted**: source-to-sink taint and/or authorization context cannot be established by the current syntax checks                                             |
| `forge-resolver-returns-secret`, `forge-token-in-plain-storage`, `forge-sensitive-data-console-logging`, `forge-ui-credential-console-logging`, `forge-atlassian-api-token-basic-auth`, `forge-bitbucket-basic-auth-credential`                        | **Not converted**: secret provenance/context would need additional review; `review-hardcoded-secret` and `no-sensitive-data-logging` are related but not equivalent |
| `forge-webtrigger-missing-auth`, `forge-resolver-global-write-without-permission-check`, `forge-payload-identity-trusted`, `forge-context-identifier-payload-fallback`, `forge-hardcoded-account-gate`, `forge-jwt-literal-secret`                     | **Not converted**: authorization or authentication context needs a dedicated design and focused fixtures                                                            |
| `forge-process-env-in-ui-render`                                                                                                                                                                                                                       | Partial direct JSX syntax review via `review-environment-in-ui-tsx` and `review-environment-in-ui-js`; no secret provenance or alias/cross-file flow                |
| `forge-payload-merge-prototype-pollution`                                                                                                                                                                                                              | **Not converted**: needs targeted syntax and counterexample tests                                                                                                   |
| `forge-manifest-shared-hosting-wildcard-egress`                                                                                                                                                                                                        | New `review-shared-hosting-wildcard-egress` (partial YAML syntax conversion; selected provider wildcards only, no ownership or traffic proof)                       |
| `forge-llm-output-drives-privileged-action`                                                                                                                                                                                                            | **Not converted**: requires model-output provenance and action authorization analysis                                                                               |
| `forge-sandbox-no-child-process`, `forge-sandbox-no-filesystem`                                                                                                                                                                                        | Partial syntax review via `review-child-process-import` and `review-filesystem-import`; current native runtime allows built-ins, so no blanket prohibition          |
| `forge-webtrigger-html-response-interpolation`                                                                                                                                                                                                         | Partial direct literal response review via `review-webtrigger-html-response` and TSX/JS companions; no alias tracing or sanitizer correctness proof                 |

## HTML web-trigger responses: direct syntax review

`forge-webtrigger-html-response-interpolation` has a **partial syntax conversion**
in strict-tier `review-webtrigger-html-response` and its TSX/JavaScript companions
(inherited by Atlassian/Ecosol, absent from recommended). It matches sibling
literal `headers` and `body` properties on the same object, regardless of order:
`Content-Type` or `content-type` arrays containing exactly `text/html` or
`text/html; charset=utf-8`, and a direct template body with a substitution.
Quoted keys, single/double-quoted header strings, extra properties/header values,
return objects and arrow-expression objects are covered. JSON headers, static
HTML/string templates, escaped template markers and headers/body split across
nested objects are excluded. Shape alone does not prove web-trigger reachability;
a response-shaped unrelated object can still match.

Unlike the source's ERROR classification and sanitizer-name exclusions, this is a
low-precision/high-impact review warning. Direct `escapeHtml`, `DOMPurify.sanitize`
and safe-looking variable names still match: neither a function name nor local
syntax establishes correct context-sensitive escaping, input trust or executable
XSS. No automatic fix is provided. Source alias-assignment forms (`body: html`),
concatenations, header aliases, computed keys, scalar header values, other MIME
casing/parameters and cross-file flows are not resolved. Nonmatching alias tests
document **gaps**, not safety; sanitizer flows require manual review.

Evidence: `rule-tests/strict/security/review-webtrigger-html-response*.test.yml`
and their snapshots cover direct forms and counterexamples. Real-scanner fixtures
exercise TS/MTS/CTS, TSX and JS/JSX/MJS/CJS, tier inheritance, root/backend/frontend/
Custom UI/shared/build paths and test/dependency/generated exclusions. Unlike the
source rule, static and build paths remain eligible under repository scope policy;
paths do not establish runtime identity. This is bounded syntax review, not
OpenGrep equivalence or a replacement for source-to-sink/output-encoding review.

## Environment values in JSX output: direct syntax review

`forge-process-env-in-ui-render` has partial direct-render coverage through
strict-tier `review-environment-in-ui-tsx` and `review-environment-in-ui-js`.
Both report `process.env` and literal `process['env']` reads inside JSX children
and attributes, including nested calls, templates, operators, object props,
bracket/dynamic field access, whole-environment stringification and spreads.
Nested JSX inside a callback is checked, but traversal stops at intervening
function boundaries: an event handler's environment read alone is not UI output.
No non-JSX TypeScript companion is added because this bounded check requires JSX.
The existing `no-environment-disclosure` remains responsible for its separate
whole-environment logging, handler-return and model-message sinks.

These are nonblocking **review warnings** (low precision, high potential impact),
not proof of a secret leak. Unlike OpenGrep's name-based exclusions, public and
diagnostic names such as `NODE_ENV`, `PUBLIC_BASE_URL`, `LOG_LEVEL` and `VERSION`
are deliberately included and tested. Names do not prove safety; broad substring
exclusions would also hide names such as `SECRET_VERSION_TOKEN`. Review whether
the value is sensitive and whether the component actually exposes the prop.
Sanitizing helpers and shadowed `process` identifiers may match. No automatic fix
is safe. See the [Forge environment-variable guidance](https://developer.atlassian.com/platform/forge/environments-and-versions/#environment-variables)
and [CWE-200](https://cwe.mitre.org/data/definitions/200.html).

Aliases, destructuring, imported values, cross-file flows, `createElement` calls,
computed access to the `env` property itself, and reads behind intervening function
boundaries (including immediately invoked functions) remain gaps, not evidence
of safety. This is a syntax comparison against the vendored source, not execution
of OpenGrep or equivalent taint/secret-provenance analysis.

Snippet tests and snapshots cover direct sinks and counterexamples; real-scanner
fixtures verify TSX and JS/JSX/MJS/CJS, strict/Atlassian/Ecosol inclusion and
recommended absence, UI Kit and Custom UI outside `frontend`, shared/backend and
`build` source paths, plus baseline and test exclusions. `build` remains included
under repository policy rather than copying OpenGrep's exclusion. No manifest,
component identity, bundle configuration or runtime reachability is inferred.

## Runtime capability imports: reviewed, not blanket-prohibited

`forge-sandbox-no-child-process` and `forge-sandbox-no-filesystem` have partial
syntax overlap with new strict-tier `review-child-process-import` and
`review-filesystem-import` (TypeScript, TSX and JavaScript companions). They are
**warning-level review checks, not equivalent prohibitions**. The source rules
assign ERROR to subprocess loading and WARNING to filesystem loading. The
[current Node.js runtime reference](https://developer.atlassian.com/platform/forge/function-reference/nodejs-runtime/)
allows built-in modules and requires that customer data not persist in memory or
on disk across invocations. The child_process unsupported-module list belongs to
the [deprecated legacy sandbox](https://developer.atlassian.com/platform/forge/runtime-reference/legacy-runtime-reference/).
No cross-file manifest/runtime inference is attempted. An import alone cannot
establish command injection, forbidden process execution, durable storage misuse
or cross-tenant disk persistence; legitimate built-in use can match. Low precision
and high potential impact yield nonblocking warnings under the severity matrix.

Both rules cover exact bare and `node:` literal specifiers in default, namespace,
named/aliased and side-effect imports, require calls and dynamic imports (including
options). Filesystem coverage includes `fs/promises` and `node:fs/promises`.
TypeScript/TSX also support import-equals; explicit `import type` declarations
are excluded, but inline type-only specifiers may still match. Re-exports,
computed names, loader aliases, lexical require shadowing, transitive dependency
loads, direct calls through previously bound aliases, actual filesystem paths,
command trust and invocation lifetime are not resolved. Nonmatching test snippets
for these forms document gaps, not safety. Compared with the vendored filesystem
rule, side-effect and dynamic imports and named `node:fs/promises` imports are
additional bounded syntax coverage.

Real-scanner fixtures exercise TS/MTS/CTS, TSX and JS/JSX/MJS/CJS; strict-tier
inheritance by Atlassian/Ecosol and absence from recommended; root, backend,
resolver, lifecycle, external and unconventional source paths; and frontend,
static/UI/public, tooling/configuration/generator, tests and baseline exclusions.
`build` is intentionally included per repository scope policy, unlike the source
rule's build exclusion. Paths do not prove Forge function reachability or exclude
all remote-service/custom frontend layouts. Manual runtime and tenant-isolation
review remains necessary; neither rule supplies an automatic fix.

## Reconciled wildcard egress and script CSP checks

The existing rules are retained; no duplicate source-ID rules are added. Comparison
is against the vendored OpenGrep regex definitions, not an OpenGrep execution or a
claim that the engines are interchangeable.

| Comparison                                 | `forge-manifest-wildcard-egress` → `no-wildcard-egress`                                                                                                                                                                                                                                                                                                           | `forge-manifest-csp-unsafe-script-directive` → `no-unsafe-custom-ui-csp`                                                                                                                                                                                                                                                                                       |
| ------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Equivalent policy on bounded literal forms | Exact quoted `*` in fetch backend/client and external scripts, as scalar or `address` entries                                                                                                                                                                                                                                                                     | `unsafe-eval` and `unsafe-inline` in content script lists                                                                                                                                                                                                                                                                                                      |
| Partial overlap / intentional differences  | ast-grep now includes external script entries in block/flow YAML, quoted keys, comments and inline anchors/tags. Source regexes are not restricted to the top-level permissions path; ast-grep excludes unrelated or nested keys and nested metadata. Source is ERROR; ast-grep remains a review warning because supported wildcard workflows can be intentional. | ast-grep restricts matches to top-level `permissions.content.scripts`, excluding styles, external script lists, unrelated/nested keys, URLs, hashes, nonces and `wasm-unsafe-eval`. Source regexes are keyed only on `scripts` and may match unrelated lists. ast-grep additionally reviews exact CSP `*` and supports inline anchors/tags. Both are warnings. |
| Unhandled / non-equivalent forms           | Aliases, YAML merge expansion, block scalars, remote-reference destinations and specific host wildcards are not resolved by this rule. Shared-host provider wildcards have a separate review rule.                                                                                                                                                                | Aliases, YAML merge expansion and block scalars are not resolved. Whether the exception is necessary or an HTML sink is exploitable requires review.                                                                                                                                                                                                           |

Evidence: `rule-tests/recommended/security/no-wildcard-egress.test.yml` and
`no-unsafe-custom-ui-csp.test.yml` in the same directory, with their snapshots,
exercise positive and negative block/flow and path-boundary cases. Tests for
aliases and block scalars document **missed forms**, not safe configurations.
`scripts/check-security-fixtures.sh` scans script-only wildcard/CSP fixtures under
both manifest filenames in all four composing tiers, including nested/tests/build
paths and dependency/generated exclusions. Neither rule has an automatic fix;
findings do not establish actual requests, exfiltration or script injection.

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

`forge-manifest-shared-hosting-wildcard-egress` now has a **partial syntax conversion**
in `review-shared-hosting-wildcard-egress` (recommended, inherited by the other tiers).
It reviews wildcard hosts directly under top-level
`permissions.external.fetch.backend/client` and external
`scripts/styles/images/fonts/media/frames` lists. Block/flow YAML, quoted keys and
values, scalar/address-object entries, case-insensitive hosts and URL ports/paths
are covered. The selected provider suffixes are cloudfront.net, amazonaws.com,
s3.amazonaws.com and regional s3.*.amazonaws.com, googleapis.com,
storage.googleapis.com, appspot.com, web.app, firebaseapp.com, github.io,
githubusercontent.com, herokuapp.com, azurewebsites.net, blob.core.windows.net,
vercel.app, netlify.app, pages.dev, workers.dev, onrender.com, fly.dev, glitch.me,
repl.co, wp.com, wordpress.com, blogspot.com, surge.sh, digitaloceanspaces.com,
backblazeb2.com and r2.dev. Each requires a leading `*.`; exact hosts, unrestricted
`*` (handled separately by `no-wildcard-egress`), unrelated/Atlassian/analytics
suffixes and narrower tenant-specific wildcards are not reported.
Unlike the source's unbounded text search, hostname boundaries and YAML paths
exclude descriptions, lookalike suffixes, userinfo and host strings only in URL
paths/queries. Real scanner fixtures check both manifest filenames, inherited
tiers and directory exclusions. This is not a complete provider inventory or URL
validator, and does not establish tenant ownership, actual requests or compromise.
Aliases, merge expansion, tagged/anchored scalar normalization, block scalars,
computed values and remote-reference destinations are not resolved. There is no
automatic fix; intentional broad permissions and missed forms need manual review.

The `review-` rules report candidates rather than proven vulnerabilities. See each rule's `note` and precision rationale for false positives and missed forms. For rule authoring conventions, see [rule-authoring-policy](rule-authoring-policy.md).
