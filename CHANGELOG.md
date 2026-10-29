## [Unreleased]

### Changed

- Rename `no-unapproved-forge-react-components` and its `-tsx` variant to
  `prefer-documented-forge-react-exports` and `prefer-documented-forge-react-exports-tsx`.
  Update rule-ID overrides and suppression comments to use the new names.
  Clarify the documentation-backed API preference, stale-list false positives,
  and rule-specific suppression with an accepted-risk explanation.
- Check documented exports separately for exact `@forge/react` and
  `@forge/react/jira` imports, recognizing documented `CustomFieldEdit` imports
  from the Jira entry point, including aliases. Other entry points and similarly
  named packages are outside this check. Warning severity is unchanged.

## [0.11.0] - 2026-10-24

### 🚀 Features

- *(security)* Add OWASP direct-input and crypto rules
- *(authoring)* Add ticket 03 native self-evaluation
- *(authoring)* Enforce ticket 09 severity matrix
- *(authoring)* Complete ticket 10 enforcement

### 🐛 Bug Fixes

- *(release)* Include lockfile in release commits
- *(scope)* Normalize ticket 08 Atlassian packages
- *(scope)* Normalize ticket 08 Ecosol devtools
- *(scope)* Normalize ticket 08 Ecosol Forge Ahead
- *(scope)* Normalize ticket 08 Ecosol Forge scripts
- *(scope)* Normalize ticket 08 Ecosol git-hooks
- *(scope)* Normalize ticket 08 Ecosol package-json
- *(scope)* Normalize ticket 08 Ecosol package-scripts
- *(scope)* Normalize ticket 08 Ecosol secrets
- *(scope)* Normalize ticket 08 Ecosol typescript
- *(scope)* Normalize ticket 08 architecture routing
- *(scope)* Normalize ticket 08 cost routing
- *(scope)* Normalize ticket 08 recommended devtools
- *(scope)* Normalize ticket 08 recommended frontend-ui
- *(scope)* Normalize ticket 08 recommended manifest
- *(scope)* Normalize ticket 08 recommended package-json
- *(scope)* Normalize ticket 08 recommended package-scripts
- *(scope)* Normalize ticket 08 recommended security
- *(scope)* Normalize ticket 08 recommended triggers
- *(scope)* Normalize ticket 08 recommended typescript
- *(scope)* Normalize ticket 08 API usage
- *(scope)* Normalize ticket 08 strict frontend-ui
- *(scope)* Normalize ticket 08 strict imports
- *(scope)* Normalize ticket 08 strict package-json
- *(scope)* Normalize ticket 08 strict performance
- *(scope)* Normalize ticket 08 strict runtime-boundaries
- *(scope)* Normalize ticket 08 strict security
- *(scope)* Normalize ticket 08 strict triggers
- *(severity)* Apply ticket 09 reviewed gate changes

### 📚 Documentation

- *(policy)* Broaden mechanical backfill scope

### 🧪 Testing

- *(scope)* Complete ticket 08 routing verification

### ⚙️ Miscellaneous Tasks

- *(rules)* Define and pilot rule-authoring policy
- *(authoring)* Add explicit yq metadata recipes
- *(editorconfig)* Cover JSONC, TOML, and Markdown breaks
- *(authoring)* Complete ticket 04 security metadata
- *(authoring)* Complete ticket 05 strict metadata
- *(authoring)* Complete ticket 06 recommended metadata
- *(authoring)* Complete ticket 07 convention metadata
- *(scripts)* Keep temporary workspaces under .scratch
- *(scripts)* Fix permissions

## [0.10.0] - 2026-10-23

### 🚀 Features

- *(security)* Add personal-data logging review rules

### ⚙️ Miscellaneous Tasks

- *(release)* Sync lockfile version to 0.9.0

## [0.9.0] - 2026-10-23

### 🚀 Features

- *(ecosol)* Add Fence Rider delivery and execution rules

### ⚙️ Miscellaneous Tasks

- *(release)* Sync lockfile version to 0.8.0

## [0.8.0] - 2026-10-23

### 🚀 Features

- *(ecosol)* Prefer Fence Rider for Forge commands
- *(security)* Add OWASP-derived lint rules
- *(security)* Add second-wave OWASP review rules

### 🐛 Bug Fixes

- *(security)* Improve existing rule coverage

## [0.7.0] - 2026-10-14

### 🚀 Features

- *(ecosol)* Require module package type for Forge apps
- *(ecosol)* Typecheck Forge app tests
- *(ecosol)* Guard bundle size before push
- *(ecosol)* Require Lefthook prepare script
- *(ecosol)* Require Vitest coverage script
- *(ecosol)* Require non-watch Vitest test script
- *(ecosol)* Require TypeScript build script

### 🐛 Bug Fixes

- *(ecosol)* Accept hard dist exclusions

### ⚙️ Miscellaneous Tasks

- *(tooling)* Align Forge lint rules with Drop Calf

## [0.6.2] - 2026-07-26

### 🐛 Bug Fixes

- *(ecosol)* Recognize lint-group delegation for pre-push format
- *(recommended)* Recognize size:check delegation for size script

## [0.6.1] - 2026-07-22

### 🐛 Bug Fixes

- *(ecosol)* Recognize monorepo dist exclusion in biome.json
- *(recommended,ecosol)* Back off tsconfig rules when extends is present
- *(ecosol)* Recognize per-package lefthook lint groups

### 📚 Documentation

- *(ecosol,recommended)* Note the Forge-app scan assumption

## [0.6.0] - 2026-07-21

### 🚀 Features

- *(security)* Add Forge tenant isolation rules
- *(cost)* Add lint rule for JQL 1000 value limit
- *(api-usage)* Add Forge egress HTTPS/port lint rules

### 🐛 Bug Fixes

- *(forge-ahead)* Flag all console log levels in hot paths
- *(ecosol)* Disable require-biome-files-exclude-projen by default
- *(ecosol)* Allow pre-push typecheck via delegated lint group

## [0.5.0] - 2026-07-19

### 🚀 Features

- *(devtools)* Flag @size-limit/preset-app in Forge apps

## [0.4.4] - 2026-07-19

### 🐛 Bug Fixes

- *(recommended)* Allow 'lefthook install || true' in prepare script

## [0.4.3] - 2026-07-19

### 🐛 Bug Fixes

- *(scripts)* Remove non-existent build step from prepare

## [0.4.2] - 2026-07-19

### 💼 Other

- Add build step to prepare script

### 📚 Documentation

- *(changelog)* Regenerate history to include 0.1.0

## [0.4.1] - 2026-07-19

### 🐛 Bug Fixes

- *(rules)* Accept --force on the required lefthook check script
- *(rules)* Correct stale ForgeUI JSX assumptions for UI Kit 2
- *(rules)* Narrow avoid-life-cycle-scripts prepare exemption

### 🚜 Refactor

- *(rules)* Split lint-with-prelint into three focused checks
- *(rules)* Drop unnecessary @forge dependency gates

### ⚙️ Miscellaneous Tasks

- Configure lefthook for this repo's own dev workflow
- Exclude generated files from prettier
- *(release)* V0.4.1

## [0.4.0] - 2026-07-19

### 🚀 Features

- *(rules)* Reorganize rule tiers and add fine-grained checks

### 🐛 Bug Fixes

- *(rules)* Reduce Forge Prelint false positives
- *(rules)* Disable verbose logging rule
- *(rules)* Add Pressable to forge-react component allow-list
- *(changelog)* Add blank line between changelog releases

### 📚 Documentation

- *(readme)* Split dev workflow into DEVELOPMENT.md
- Fill in CONTRIBUTING.md and LICENSE placeholders

### ⚙️ Miscellaneous Tasks

- *(release)* V0.4.0

## [0.3.0] - 2026-07-14

### 🚀 Features

- *(ecosol)* Expand repo-init drift checks
- *(rules)* Promote reusable script checks

### ⚙️ Miscellaneous Tasks

- *(release)* V0.3.0

## [0.2.0] - 2026-07-14

### 🚀 Features

- *(rules)* Add ecosol package-scripts and forge-scripts rule sets
- *(rules)* Add rules inspired by the Valiantys Forge style guide
- *(rules)* Add ecosol repo-init dependency rules

### 📚 Documentation

- *(readme)* Restructure rule reference into per-category summaries

### ⚙️ Miscellaneous Tasks

- *(gitignore)* Ignore .turbo cache directory
- *(release)* V0.2.0

## [0.1.0] - 2026-07-09

### 🚀 Features

- *(rules)* Add devtools tier and refine security and HTTP rules
- *(rules)* Add review-duplicate-page-title rule

### 🐛 Bug Fixes

- *(rules)* Raise review-* cost rule severity from info to warning
- *(rules)* Correct remediation note for no-hardcoded-atlassian-token-tsx
- *(rules)* Reduce frontend boundary false positives
- *(rules)* Remove use-detect-secrets rule
- *(rules)* Exempt avi:forge events from trigger filter rule

### 🚜 Refactor

- *(rules)* Correct rule tier placement and wire missing dirs
- *(rules)* Promote import rules from recommended to strict tier

### 📚 Documentation

- *(readme)* Rewrite README as a proper front door
- *(rules)* Add authoritative Forge docs links to rule notes
- *(readme)* Clarify Forge Prelint usage
- *(use-detect-secrets)* Improve what and why of secrets detection
- *(readme)* Clarify install and Forge lint usage

### 🧪 Testing

- *(rules)* Add tests for all remaining rule categories
- Add tests for all 55 rules with snapshots

### ⚙️ Miscellaneous Tasks

- Bump deps
- *(release)* V0.1.0
