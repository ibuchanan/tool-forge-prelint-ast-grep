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
  --config node_modules/tool-forge-prelint-ast-grep/sgconfig.recommended.yml \
  --globs '!node_modules/**'
```

The expected project integration is a package script named `lint:prelint`:

```json
{
  "scripts": {
    "lint:prelint": "ast-grep scan --config node_modules/tool-forge-prelint-ast-grep/sgconfig.recommended.yml --globs '!node_modules/**'",
    "lint": "npm run lint:prelint && forge lint"
  }
}
```

If your app already has a `lint` script,
keep it and add `lint:prelint` to the script or CI job
that should fail early on Forge Prelint findings.
Keep the `--globs '!node_modules/**'` argument so ast-grep does not traverse
vendored dependencies.

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

## Rule category reference

Each rule file documents itself:
`message` states the finding,
`note` explains the reasoning and usually links to further reading.
The same category name can exist under more than one tier — the sections
below describe what each category covers regardless of tier, and break out
tier-specific differences where they matter.
Browse `rules/<tier>/<category>/` for the exact rule files,
or run a scan and read the output directly.

### api-usage

Safe patterns for calling Jira/Confluence product APIs — explicit
`asUser()`/`asApp()`, route templates over absolute URLs, and no native
`fetch()` in backend runtime code. _(strict)_

### architecture

Wiring conventions that keep `invoke()` calls, `Queue` keys, and resolver files
resolvable and maintainable — static keys instead of dynamic strings, and a cap
on how many actions live in one resolver file. _(recommended)_

### cost

Patterns that inflate Forge invocation counts, storage reads/writes, or bundle
memory/timeout settings beyond what's needed — N+1 API calls, unbounded
searches, and batchable invokes. _(recommended)_

### devtools

Tooling conventions that don't fit a more specific category:

- **recommended** — bundle-size guardrails for CI, including size-limit setup.
- **ecosol** — biome.json config drift and vitest.config.ts globals specific
  to the ecosol repo-init template.

### forge-ahead

Conventions tied to the `@forge-ahead/*` helper packages (errors, Atlassian
API types, structured logging) — adding the right package for what a Forge
app actually does, and using `@forge-ahead/logging`'s `createForgeLogger`
instead of raw `console.log` in backend hot paths, where verbose or
unredacted output can inflate log volume or leak sensitive data. _(ecosol)_

### forge-scripts

Naming and wrapping conventions for scripts that call the Forge CLI directly
(`forge deploy`, `install`, `uninstall`, `register`, ...) — a `forge:<verb>`
namespace so wrapper scripts are discoverable by a predictable name, and
consistent secret/environment handling around those commands. _(ecosol)_

### frontend-ui

UI Kit and Custom UI correctness:

- **recommended** — strict mode, avoiding duplicate page titles, and
  preferring `<Frame>` over a raw `<iframe>`.
- **strict** — no native HTML elements, no deprecated components, and a
  required `ForgeReconciler.render()` entry point.

### git-hooks

lefthook.yml guard coverage — a lightweight pre-commit gitleaks and format
guard (lint/typecheck are too heavy-handed for every commit), and a
comprehensive pre-push guard covering format, typecheck, lint, and test, so
CI and `npm run check` can both reuse `lefthook run pre-push` as the single
source of truth. Each guard is its own rule so a missing one is named
specifically instead of bundled into one generic "hooks are incomplete"
finding. _(ecosol)_

### imports

Blocks deprecated packages and boundary-violating imports (`@forge/ui`,
`@forge/api` storage, `@forge/kvs`/`@forge/bridge` on the wrong side of the
frontend/backend split, and unapproved `@forge/react` components). _(strict)_

### manifest

Manifest scope and remote review — granular over classic scopes, admin-level
scopes flagged for least-privilege review, and remotes flagged for
eligibility/residency/auth review. _(recommended)_

### package-json

package.json hygiene, split by how universal each concern is:

- **recommended** (any Forge app) — marking the package private so it's
  never accidentally published, and not declaring main/types/exports — a
  Forge app is a deployable, not a library, and Forge's bundler resolves
  entrypoints from manifest.yml regardless of what these fields say.
- **strict** — flags third-party dependencies that duplicate a Forge
  platform capability (e.g. HTTP client libraries where Forge fetch already
  covers the need).
- **atlassian** — the Apache-2.0 license requirement from Atlassian's OSS
  credo checklist. Applies to any Atlassian OSS/sample repo, not just Forge
  apps, so it isn't gated on an `@forge` dependency like the tiers above.
- **ecosol** — the `engines.node` version pin. A team-specific choice, since
  each team can reasonably pin a different Node version independently of
  what Forge's own runtime targets.

### package-scripts

npm script hygiene for the `scripts` block:

- **recommended** — wiring a `size` script when size-limit tooling is
  configured, keeping read-only check scripts (`lint`, `lint:check`,
  `format:check`) free of `--write`/`--fix` flags that would mutate files
  instead of failing on drift, and reviewing automatically-triggered npm
  lifecycle scripts (a common supply-chain attack vector).
- **ecosol** — which scripts should exist, what they should compose, and
  naming/behavior hygiene for the ecosol repo-init template's `scripts`
  block as a whole.

### performance

Bounds expensive Forge storage operations before they hit platform limits.
_(strict)_

### runtime-boundaries

Enforces the frontend/backend module boundary in both directions, so bundling
and Forge runtime assumptions aren't violated by a stray import. _(strict)_

### security

- **recommended** — manifest-level security: no wildcard egress, no unsafe
  Custom UI CSP entries.
- **strict** — source-level security hygiene: no committed Atlassian API
  tokens, no wildcard CORS origins, no logging of credential-shaped values.

### triggers

Trigger filtering to avoid unnecessary invocations:

- **recommended** — scheduled trigger intervals and Jira
  `filter.ignoreSelf`.
- **strict** — prefer manifest-level trigger filters over in-code filtering.

### typescript

- **recommended** — Forge facts that apply to any Forge app's tsconfig.json,
  regardless of team convention. jsx/jsxFactory/sourceMap are hardcoded by
  the bundler at build time, so declaring (or omitting) anything else
  misrepresents what actually happens to your code (an error).
  target/module/moduleResolution/lib are Node 18 runtime facts every Forge
  app builds through that the bundler won't auto-correct for you (also an
  error). rootDir/include drifting from `"src"` — Forge's own CLI
  scaffolding — causes real local `tsc` errors or silently excluded files
  (a warning). strict/esModuleInterop/skipLibCheck/
  forceConsistentCasingInFileNames are typical but not bundler-enforced (a
  hint). Keeping the `typescript` devDependency on a 5.x major is also a
  warning — a major bump risks breaking the bundler's pinned `@babel/parser`
  metadata pass and ts-loader compatibility.
- **ecosol** — tsconfig.json's outDir baseline, and tsconfig.typecheck.json's
  extends/noEmit shape plus its exhaustive strict flags that Biome's linter
  can't catch (noImplicitReturns, noUncheckedIndexedAccess,
  noUncheckedSideEffectImports, noImplicitOverride,
  noPropertyAccessFromIndexSignature, exactOptionalPropertyTypes).

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

## License

Apache 2.0 — see [LICENSE](LICENSE).
