# Forge Prelint — ast-grep rules

AST-level lint rules for [Atlassian Forge](https://developer.atlassian.com/platform/forge/) apps, packaged as [ast-grep](https://ast-grep.github.io/) configs. Point one of the tier configs at your Forge app to catch deprecated packages, frontend/backend boundary violations, and common cost and performance mistakes — no build step required.

## Tiers

Rules are organized into composing tiers. Each tier includes all rules from tiers below it.
Some frontend checks have a `-tsx` companion rule file so the same policy applies to both `.ts` and `.tsx` sources.

| Tier          | Audience                                 | Config                     |
| ------------- | ---------------------------------------- | -------------------------- |
| `recommended` | Any Forge developer                      | `sgconfig.recommended.yml` |
| `strict`      | Production-quality Forge apps            | `sgconfig.strict.yml`      |
| `atlassian`   | Atlassian-internal Forge apps            | `sgconfig.atlassian.yml`   |
| `ecosol`      | Atlassian sample/demo apps (ecosol team) | `sgconfig.ecosol.yml`      |

## Quickstart

Install [ast-grep](https://ast-grep.github.io/guide/quick-start.html) (`npm i -g @ast-grep/cli` or `brew install ast-grep`), then run from your Forge app root:

```sh
ast-grep scan --config path/to/forge-prelint/sgconfig.recommended.yml
```

Zero findings on a clean project. Rule IDs with file locations appear for anything that needs attention.

## Prerequisites

- [ast-grep](https://ast-grep.github.io/) ≥ 0.38

## Development

```sh
npm install          # install dev dependencies
npm test             # run all rule tests (55 rules)
npm run check        # tests + self-lint + format check
```

To regenerate snapshots after changing a rule:

```sh
npm run test:update
```

To step through mismatches interactively:

```sh
npm run test:interactive
```

## Rule reference

### recommended/architecture

- `require-static-invoke-key` — Frontend `invoke()` calls must use string literal keys
- `require-static-queue-key` — `new Queue({ key })` must use a string literal key when `Queue` is imported from `@forge/events`
- `no-monolithic-resolver` — flag resolver files with five or more `resolver.define()` actions

### recommended/cost

- `no-unpaginated-product-search` — search/list product API calls should include pagination
- `no-product-request-in-loop` — avoid N+1 Atlassian product API requests in loops or array callbacks
- `no-storage-operation-in-loop` — avoid Forge storage reads/writes in loops or array callbacks
- `no-use-action-invoke` — avoid resolver invocations from `useAction()`
- `no-jira-search-without-fields` — Jira search requests should select explicit fields
- `no-invoke-without-effect-deps` — `invoke()` inside `useEffect` should have stable dependencies
- `no-multiple-invokes-in-effect` — multiple load-time invokes can often be batched
- `review-high-function-memory` — review high `memoryMiB` values against observed usage
- `review-max-function-timeout` — review long `timeoutSeconds` values against realistic runtime
- `no-verbose-hot-path-logging` — avoid `console.log` in backend hot paths

### recommended/devtools

- `use-size-limit` — add size-limit to measure and enforce bundle size in CI
- `use-detect-secrets` — add detect-secrets to scan for committed credentials in CI

### recommended/frontend-ui

- `require-strict-mode` — `ForgeReconciler.render()` must wrap root in `<React.StrictMode>`

### recommended/manifest

- `no-classic-product-scopes` — prefer granular Jira/Confluence scopes where possible
- `review-forge-remotes` — flag `remotes` for explicit eligibility, residency, and auth review

### recommended/security

- `no-wildcard-egress` — no wildcard external egress in `manifest.yml`
- `no-unsafe-custom-ui-csp` — no `unsafe-inline` or `unsafe-eval` Custom UI CSP entries

### recommended/triggers

- `no-excessive-scheduled-trigger` — avoid five-minute/hourly schedules for slow-changing data
- `prefer-jira-trigger-ignore-self` — Jira triggers should review `filter.ignoreSelf`

### strict/api-usage

- `require-as-user-or-as-app` — `requestJira`/`requestConfluence` must be chained from `api.asUser()` or `api.asApp()`
- `require-route-template` — API requests must use the `` route`...` `` template tag or `assumeTrustedRoute()`
- `no-absolute-urls-in-api` — no absolute URLs (`http://`, `https://`, or `//`) passed to Forge product request helpers or `assumeTrustedRoute`

### strict/architecture

- `no-native-fetch-in-resolvers` — no native `fetch()` calls in `src/resolvers/`, `src/external/`, `src/import-lifecycle/`
- `no-frontend-escape-imports` — frontend files must not import from outside `src/frontend/` (except `src/util/`)
- `no-resolver-import-in-frontend` — frontend must not import from `src/resolvers/`
- `no-frontend-import-in-backend` — backend runtime files must not import from `src/frontend/`

### strict/frontend-ui

- `no-native-html-elements` — no native HTML elements (`<div>`, `<span>`, etc.) in frontend JSX
- `no-deprecated-table` — use `<DynamicTable>` not `<Table>`
- `no-render-from-forge-react` — do not import `render` from `@forge/react`; use `ForgeReconciler.render()`
- `require-forge-reconciler-render` — `src/frontend/index.tsx` must call `ForgeReconciler.render()`

### strict/imports

- `no-forge-ui-import` — no imports from deprecated `@forge/ui` package
- `no-deprecated-storage-import` — no `storage` imported from `@forge/api` (use `@forge/kvs`)
- `no-forge-api-in-frontend` — no `@forge/api` imports in `src/frontend/**`
- `no-forge-kvs-in-frontend` — no `@forge/kvs` imports in `src/frontend/**`
- `no-forge-bridge-in-backend` — no `@forge/bridge` imports in Forge backend runtime files
- `no-unapproved-forge-react-components` — only approved UI Kit components may be imported from `@forge/react`

### strict/package-json

- `prefer-forge-fetch` — flag third-party HTTP client libraries that should be replaced with Forge platform fetch

### strict/performance

- `no-storage-query-scan` — bound Forge storage queries before `getMany()`

### strict/security

- `no-hardcoded-atlassian-token` / `-tsx` — flag Atlassian API token literals (`ATATT3xFfG…`) committed in source

### strict/triggers

- `prefer-trigger-filter` — product event triggers should use manifest-level filters where possible

## Scope boundaries

These checks require cross-file context and cannot be expressed as single-file ast-grep rules:

- Handler wiring (manifest function handlers → exported symbols)
- Queue wiring (`new Queue({ key })` → manifest consumer names)
- Frontend-to-manifest (`invoke('fn')` → manifest function keys)
- `storage:app` scope declared when `@forge/kvs` is used
- Source dependency cycle detection

Judgment-heavy checks that need app intent, cross-file dataflow, or human trade-off evaluation remain as LLM review guidance:

- Unused scopes and egress declarations
- Missing resolver implementation for manifest functions
- Missing payload validation through local helpers
- Whether `api.asApp()` is necessary for a specific privilege decision
- Read-only resolver calls that can safely move to `@forge/bridge`
- N+1 product API patterns across helper functions
- Replacing polling with web triggers or Forge Realtime

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Rule files live under `rules/<tier>/<category>/`, tests mirror that path under `rule-tests/`, and every rule change needs a matching test. Run `npm test` before opening a PR.

## License

Apache 2.0 — see [LICENSE](LICENSE).
