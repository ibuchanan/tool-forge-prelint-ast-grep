# Forge Prelint ast-grep rules

As explained in [Atlassian Forge documentation](https://go.atlassian.com/forge):
> Forge makes it possible to build a fully-functional app in just a few hours,
> with hosting, multiple development environments, and API authentication built-in.
> Forge can be used to build custom apps and integrations or apps distributed through the Atlassian Marketplace.

[The Forge CLI](https://developer.atlassian.com/platform/forge/getting-started/#install-the-forge-cli)
provides an opinionated developer experience
so that you can quickly and easily extend Atlassian apps.
The `forge lint` command checks for Forge-specific errors and gates deployment.
Those quick static checks help save hours of frustration in runtime debugging
and help make sure your app is secure by design.

While `forge lint` covers the strictest of checks,
we find AI coding agents (and maybe people too)
could use additional guardrails
that are open to developer preference,
quick to implement,
and provide less strict feedback.

This repo provides AST-level lint rules for Forge apps,
packaged as [ast-grep](https://ast-grep.github.io/) configs.
Install the rules into a Forge app,
then point `ast-grep` at one of the tier configs to catch
deprecated packages,
frontend/backend boundary violations,
and common cost and performance mistakes.

Use Forge Prelint as an early local or CI check before deeper Forge validation.
It is intentionally single-file and AST-based;
it complements
`forge lint`,
type checking,
manifest validation,
and human review
rather than replacing them.
See [How this fits with forge lint](#how-this-fits-with-forge-lint)
and [Scope boundaries](#scope-boundaries)
for where this rule set fits.

## Prerequisites

- [ast-grep](https://ast-grep.github.io/) >= 0.38 to scan a Forge app.
  when using the dev dependency shown below,
  ast-grep will be installed into your Forge app's node modules.
- Node.js and npm to develop or test rules in this repository

## Install

Install the rules package as a GitHub dependency
in the Forge app you want to scan.
Prefer pinning a commit SHA or tag
so installs are reproducible:

```json
{
  "devDependencies": {
    "@ast-grep/cli": "^0.44",
    "tool-forge-prelint-ast-grep": "github:ibuchanan/tool-forge-prelint-ast-grep#0.1.0"
  }
}
```

This package ships the YAML rule files under `rules/`
plus the tier configs:
* `sgconfig.recommended.yml`
* `sgconfig.strict.yml`
* `sgconfig.atlassian.yml`
* `sgconfig.ecosol.yml`

There is no package build step;
the installed files are the configs that `ast-grep` reads directly.

If npm reports an `allow-scripts` warning,
it is usually for `@ast-grep/cli`,
which uses an install script to select the native binary for your platform.
Approve `@ast-grep/cli` in your repo's script-approval workflow,
then rerun `npm install`.
If your project intentionally blocks dependency lifecycle scripts,
install `ast-grep` through another trusted path such as Homebrew
and keep this rules package as the Git dependency.

## Run

For a one-off scan from the root of your Forge app,
point `ast-grep` at the installed config file:

```sh
./node_modules/.bin/ast-grep scan \
  --config node_modules/tool-forge-prelint-ast-grep/sgconfig.recommended.yml
```

The expected project integration is a package script named `lint:prelint`:

```json
{
  "scripts": {
    "lint:prelint": "ast-grep scan --config node_modules/tool-forge-prelint-ast-grep/sgconfig.recommended.yml",
    "lint": "npm run lint:prelint && forge lint"
  }
}
```

If your app already has a `lint` script,
keep it and add `lint:prelint` to the script or CI job
that should fail early on Forge Prelint findings.

Start with `sgconfig.recommended.yml`.
Move to `sgconfig.strict.yml`
when you want production-oriented API, import, performance, and runtime-boundary checks.
Rule IDs with file locations appear for anything that needs attention.

## Tiers

Rules are organized into composing tiers.
Each tier includes all rules from tiers below it.
Some frontend checks have a `-tsx` companion rule file
so the same policy applies to both `.ts` and `.tsx` sources.

| Tier          | Audience                                 | Config                     |
| ------------- | ---------------------------------------- | -------------------------- |
| `recommended` | Any Forge developer                      | `sgconfig.recommended.yml` |
| `strict`      | Production-quality Forge apps            | `sgconfig.strict.yml`      |
| `atlassian`   | Atlassian's standards for Forge apps     | `sgconfig.atlassian.yml`   |
| `ecosol`      | Atlassian sample/demo apps (ecosol team) | `sgconfig.ecosol.yml`      |

## How this fits with forge lint

`forge lint` is the canonical Forge CLI validation layer.
Keep running it.
Use `forge lint` for
Forge platform validation,
manifest semantics,
and required checks maintained by the Forge tooling itself.

Forge Prelint is a fast AST pass for patterns
that are useful to catch before Forge CLI validation:
deprecated package imports,
frontend/backend boundary mistakes,
expensive API usage patterns,
and manifest snippets that deserve review.
With Forge Prelint and `ast-grep`,
you can
build your own rule sets
and write new rules for problems you don't want to repeat.

A typical local or CI order is:

```sh
npm run lint:prelint
forge lint
npm test
```

Don't forget type checking,
tests,
and human review for cross-file wiring
and intent-heavy decisions.
Linting is just 1 guardrail for quality.

## Development

```sh
npm install          # install dev dependencies
npm test             # run all rule tests
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

### recommended/frontend-ui

- `require-strict-mode` — `ForgeReconciler.render()` must wrap root in `<React.StrictMode>`
- `review-duplicate-page-title` — review large in-app headings that may duplicate the manifest module `title`

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
- `no-native-fetch-in-resolvers` — no native `fetch()` calls in `src/resolvers/`, `src/external/`, `src/import-lifecycle/`

### strict/runtime-boundaries

- `no-frontend-escape-imports` — frontend files must not import backend runtime modules from `external`, `import-lifecycle`, or `queues`
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

See [CONTRIBUTING.md](CONTRIBUTING.md).
Rule files live under `rules/<tier>/<category>/`,
tests mirror that path under `rule-tests/`,
and every rule change needs a matching test.
Run `npm test` before opening a PR.

## License

Apache 2.0 — see [LICENSE](LICENSE).
