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

- `sgconfig.recommended.yml`
- `sgconfig.strict.yml`
- `sgconfig.atlassian.yml`
- `sgconfig.ecosol.yml`

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

Each rule file documents itself: `message` states the finding, `note` explains
the reasoning and usually links to further reading. Browse `rules/<tier>/<category>/`
for the full list of rule IDs, or run a scan and read the output directly.
The categories below describe what each rule set covers.

### recommended/architecture

Wiring conventions that keep `invoke()` calls, `Queue` keys, and resolver files
resolvable and maintainable — static keys instead of dynamic strings, and a cap
on how many actions live in one resolver file.

### recommended/cost

Patterns that inflate Forge invocation counts, storage reads/writes, or bundle
memory/timeout settings beyond what's needed — N+1 API calls, unbounded
searches, batchable invokes, and verbose backend logging.

### recommended/devtools

Bundle-size guardrails for CI.

### recommended/frontend-ui

UI Kit correctness and Custom UI embedding conventions — strict mode, avoiding
duplicate page titles, and preferring `<Frame>` over a raw `<iframe>`.

### recommended/manifest

Manifest scope and remote review — granular over classic scopes, admin-level
scopes flagged for least-privilege review, and remotes flagged for
eligibility/residency/auth review.

### recommended/package-json

package.json hygiene that applies to any Forge app, independent of team-specific
tooling choices — currently, review of automatically-triggered npm lifecycle
scripts.

### recommended/security

Manifest-level security: no wildcard egress, no unsafe Custom UI CSP entries.

### recommended/triggers

Trigger filtering to avoid unnecessary invocations — scheduled trigger
intervals and Jira `filter.ignoreSelf`.

### strict/api-usage

Safe patterns for calling Jira/Confluence product APIs — explicit
`asUser()`/`asApp()`, route templates over absolute URLs, and no native
`fetch()` in backend runtime code.

### strict/runtime-boundaries

Enforces the frontend/backend module boundary in both directions, so bundling
and Forge runtime assumptions aren't violated by a stray import.

### strict/frontend-ui

Stricter UI Kit correctness — no native HTML elements, no deprecated
components, and a required `ForgeReconciler.render()` entry point.

### strict/imports

Blocks deprecated packages and boundary-violating imports (`@forge/ui`,
`@forge/api` storage, `@forge/kvs`/`@forge/bridge` on the wrong side of the
frontend/backend split, and unapproved `@forge/react` components).

### strict/package-json

Flags third-party dependencies that duplicate a Forge platform capability
(e.g. HTTP client libraries where Forge fetch already covers the need).

### strict/performance

Bounds expensive Forge storage operations before they hit platform limits.

### strict/security

Source-level security hygiene — no committed Atlassian API tokens, no
wildcard CORS origins, no logging of credential-shaped values.

### strict/triggers

Prefer manifest-level trigger filters over in-code filtering.

### ecosol/repo-init

Dependency-level conventions from the ecosol repo-init template that don't fit
the package-scripts checks below (Forge Ahead helper packages, Node version
pin).

### ecosol/package-scripts

npm script conventions from the ecosol repo-init template — which scripts
should exist, what they should compose, and naming/behavior hygiene for the
`scripts` block as a whole.

### ecosol/forge-scripts

Naming and wrapping conventions for scripts that call the Forge CLI directly
(`forge deploy`, `install`, `uninstall`, `register`, ...) — a `forge:<verb>`
namespace so wrapper scripts are discoverable by a predictable name, and
consistent secret/environment handling around those commands.

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
