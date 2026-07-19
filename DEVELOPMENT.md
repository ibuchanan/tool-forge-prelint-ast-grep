# Development

This is the contributor guide for developing and testing rules in this
repository. If you just want to _use_ the rules in a Forge app, see the
[README](README.md) instead.

## Prerequisites

- Node.js and npm

## Setup

```sh
npm install
```

There's no build step — the rule files are the shipped artifact.

## Repository structure

```
rules/<tier>/<category>/*.yml          rule definitions
rule-tests/<tier>/<category>/*.test.yml  matching valid/invalid test cases
rule-tests/__snapshots__/              auto-generated match snapshots
rule-tests/fixtures/repo-init-forge-app/ a fixture app used as a regression check
sgconfig.yml                           dev-only config covering every rule dir
sgconfig.<tier>.yml                    the four shipped tier configs
scripts/check-fixtures.sh              runs the fixture regression check
scripts/release-prepare.sh             cuts a release (see Releasing below)
cliff.toml                             git-cliff config for CHANGELOG.md generation
```

`<tier>` is one of `recommended`, `strict`, `atlassian`, `ecosol`.
`rule-tests/fixtures/repo-init-forge-app/` models a fully repo-init-compliant
Forge app; it must produce zero findings when scanned with
`sgconfig.ecosol.yml` — `npm run test:fixtures` enforces this.

## Development loop

```sh
npm test             # rule tests + fixture regression check
npm run lint         # self-lint this repo with its own recommended + strict tiers
npm run format:check # prettier --check
npm run check        # all three of the above
```

To regenerate snapshots after changing a rule:

```sh
npm run test:update
```

To step through mismatches interactively:

```sh
npm run test:interactive
```

## Adding or changing a rule

1. Add or edit the `.yml` rule file under `rules/<tier>/<category>/`.
2. Add or update the matching test file under
   `rule-tests/<tier>/<category>/`. Every rule change needs a matching test —
   this is enforced by convention, not tooling, so don't skip it.
3. Run `npm run test:update` to (re)generate the snapshot, then `npm test` to
   confirm everything passes, including the fixture regression check.
4. If the rule applies to the `ecosol` tier, make sure
   `rule-tests/fixtures/repo-init-forge-app/` either already satisfies it or
   is updated to satisfy it — that fixture must stay a zero-findings example
   of full compliance.

`ast-grep test` has a few sharp edges worth knowing before you hit them:

- `valid`/`invalid` entries must be plain strings — there's no way to give a
  test case a synthetic file path, so a rule's `files:`/`ignores:` glob is
  untestable via `ast-grep test`; only the `rule:` node-matching logic itself
  is exercised.
- Every `.yml`/`.yaml` file under `rule-tests/` is treated as a test-case
  file, including anything under `rule-tests/fixtures/`. Don't add a
  `.yml`/`.yaml` fixture file (e.g. a realistic `lefthook.yml`) — it will be
  misparsed as a broken test case and fail the whole suite.
- A rule with `severity: off` can't be loaded by `ast-grep test` at all, so
  it can't have a test file. This is by design for intentional placeholder
  rules, not a bug to work around.

## Releasing

```sh
npm run release:prepare
```

This bumps the version in `package.json`, regenerates `CHANGELOG.md` via
`git cliff`, commits, tags, and pushes `main` plus the new tag — review the
diff before running it, since it pushes on your behalf.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the pull request process.
