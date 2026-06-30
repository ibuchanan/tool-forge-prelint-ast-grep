# Forge Prelint

ast-grep lint rules for Atlassian Forge apps.

## Tiers

Rules are organized into composing tiers. Each tier includes all rules from tiers below it.
Some frontend checks have `-tsx` companion rule files so the same policy applies
to both `.ts` and `.tsx` sources.

| Tier | Audience | Config |
|------|----------|--------|
| `recommended` | Any Forge developer | `sgconfig.recommended.yml` |
| `strict` | Production-quality Forge apps | `sgconfig.strict.yml` |
| `atlassian` | Atlassian-internal Forge apps | `sgconfig.atlassian.yml` |
| `ecosol` | Atlassian sample/demo apps (ecosol team) | `sgconfig.ecosol.yml` |

## Usage

Run a specific tier against your Forge app:

```sh
# From your Forge app root
ast-grep scan --config path/to/forge-lint/sgconfig.recommended.yml
ast-grep scan --config path/to/forge-lint/sgconfig.strict.yml
```

## Rule categories

### recommended/imports
- `no-forge-ui-import` — No imports from deprecated `@forge/ui` package
- `no-deprecated-storage-import` — No `storage` imported from `@forge/api` (use `@forge/kvs`)
- `no-forge-api-in-frontend` — No `@forge/api` imports in `src/frontend/**`
- `no-forge-kvs-in-frontend` — No `@forge/kvs` imports in `src/frontend/**`
- `no-forge-bridge-in-backend` — No `@forge/bridge` imports in Forge backend runtime files

### recommended/architecture
- `no-frontend-escape-imports` — Frontend files must not import from outside `src/frontend/` (except `src/util/`)
- `no-resolver-import-in-frontend` — Frontend must not import from `src/resolvers/`
- `no-frontend-import-in-backend` — Backend runtime files must not import from `src/frontend/`
- `require-static-invoke-key` — Frontend `invoke()` calls must use string literal keys

### recommended/frontend-ui
- `no-native-html-elements` — No native HTML elements (`<div>`, `<span>`, etc.) in frontend JSX
- `no-deprecated-table` — Use `<DynamicTable>` not `<Table>`
- `no-render-from-forge-react` — Do not import `render` from `@forge/react`; use `ForgeReconciler.render()`
- `require-forge-reconciler-render` — `src/frontend/index.tsx` must call `ForgeReconciler.render()`
- `require-strict-mode` — `ForgeReconciler.render()` must wrap root in `<React.StrictMode>`

### recommended/security
- `no-wildcard-egress` — `SEC-02`: no wildcard external egress in `manifest.yml`
- `no-unsafe-custom-ui-csp` — `SEC-05`: no `unsafe-inline` or `unsafe-eval` Custom UI CSP entries

### recommended/manifest
- `no-classic-product-scopes` — `SEC-09`: prefer granular Jira/Confluence scopes where possible
- `review-forge-remotes` — `ARC-10`: flag `remotes` for explicit eligibility, residency, and auth review

### strict/architecture
- `no-native-fetch-in-resolvers` — No native `fetch()` calls in `src/resolvers/`, `src/external/`, `src/import-lifecycle/`
- `require-static-queue-key` — `new Queue({ key })` must use a string literal key when `Queue` is imported from `@forge/events`
- `no-monolithic-resolver` — `ARC-02`: flag resolver files with five or more `resolver.define()` actions

### strict/api-usage
- `require-as-user-or-as-app` — `requestJira`/`requestConfluence` must be chained from `api.asUser()` or `api.asApp()`
- `require-route-template` — API requests must use `route\`...\`` template tag or `assumeTrustedRoute()`
- `no-absolute-urls-in-api` — No absolute URLs (`http://`, `https://`, or `//`) passed to Forge product request helpers or `assumeTrustedRoute`

### strict/imports
- `no-unapproved-forge-react-components` — Only approved UI Kit components may be imported from `@forge/react`

### strict/security
- `no-hardcoded-secret-literals` — `SEC-03`: detect common literal credential and private-key formats in source

### strict/cost
- `no-unpaginated-product-search` — `CST-02`: search/list product API calls should include pagination
- `no-product-request-in-loop` — `CST-03`: avoid N+1 Atlassian product API requests in loops or array callbacks
- `no-storage-operation-in-loop` — `CST-05`: avoid Forge storage reads/writes in loops or array callbacks
- `no-use-action-invoke` — `CST-06`: avoid resolver invocations from `useAction()`
- `no-jira-search-without-fields` — `CST-07`: Jira search requests should select explicit fields
- `no-invoke-without-effect-deps` — `CST-09`: `invoke()` inside `useEffect` should have stable dependencies
- `no-multiple-invokes-in-effect` — `CST-01`: multiple load-time invokes can often be batched
- `review-high-function-memory` — `CST-10`: review high `memoryMiB` values against observed usage
- `review-max-function-timeout` — `CST-11`: review long `timeoutSeconds` values against realistic runtime
- `no-verbose-hot-path-logging` — `CST-12`: avoid `console.log` in backend hot paths

### strict/performance
- `no-storage-query-scan` — `PRF-06`: bound Forge storage queries before `getMany()`

### strict/triggers
- `no-excessive-scheduled-trigger` — `TRG-01`: avoid five-minute/hourly schedules for slow-changing data
- `prefer-trigger-filter` — `TRG-02`: product event triggers should use manifest-level filters where possible
- `prefer-jira-trigger-ignore-self` — `TRG-03`: Jira triggers should review `filter.ignoreSelf`

### strict/package-json
- `no-bundle-bloat-dependencies` — `CST-04`: flag common avoidable production dependencies

## What stays as Vitest tests

The following checks require cross-file context (manifest.yml ↔ source files) and cannot be expressed as single-file ast-grep rules:

- Handler wiring (manifest function handlers → exported symbols)
- Queue wiring (`new Queue({ key })` → manifest consumer names)
- Frontend-to-manifest (`invoke('fn')` → manifest function keys)
- `storage:app` scope declared when `@forge/kvs` is used
- Source dependency cycle detection

## What stays as review guidance

The LLM review skill still covers judgment-heavy checks that need app intent,
cross-file dataflow, or human trade-off evaluation:

- Unused scopes and unused egress declarations
- Missing resolver implementation for manifest functions
- Missing payload validation when validation happens through local helpers
- Whether `api.asApp()` is necessary for a specific privilege decision
- Read-only resolver calls that can safely move to `@forge/bridge`
- N+1 product API patterns across helper functions
- Missing loading states, oversized payloads, and unused UI fields
- Replacing polling with web triggers or Forge Realtime when the external system supports it
- Cache TTL choices, Forge Remote offload decisions, and right-sized memory/timeouts based on observed usage
