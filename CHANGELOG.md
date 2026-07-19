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

## [0.3.0] - 2026-07-14

### 🚀 Features

- _(ecosol)_ Expand repo-init drift checks
- _(rules)_ Promote reusable script checks

## [0.2.0] - 2026-07-14

### 🚀 Features

- _(rules)_ Add ecosol package-scripts and forge-scripts rule sets
- _(rules)_ Add rules inspired by the Valiantys Forge style guide
- _(rules)_ Add ecosol repo-init dependency rules

### 📚 Documentation

- _(readme)_ Restructure rule reference into per-category summaries
