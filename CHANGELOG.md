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
