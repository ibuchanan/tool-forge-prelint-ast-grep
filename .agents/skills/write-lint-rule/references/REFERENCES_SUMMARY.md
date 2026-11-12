# Write-Lint-Rule Skill: References Summary

## Overview

This document describes the reference materials collected and integrated into the `write-lint-rule` skill to provide industry-standard guidance on writing human-readable lint rule content (IDs, messages, and documentation).

## Reference Materials Collected

### Main References (5 files, ~114 KB)

1. **`rustc-dev-guide-diagnostics.md`** (49 KB)
   - Source: [Rust Compiler Development Guide](https://rustc-dev-guide.rust-lang.org/diagnostics.html)
   - Coverage: Lint naming conventions, message structure, suggestion applicability levels, diagnostic output style guide
   - Key guidance: Lint names should read naturally with "allow" prefix; use plain English; wrap code in backticks

2. **`eslint-custom-rules.md`** (43 KB)
   - Source: [ESLint: Custom Rules Documentation](https://eslint.org/docs/latest/extend/custom-rules)
   - Coverage: Rule metadata structure, `meta.description`, `meta.messages`, suggestion confidence levels, code fix guidelines
   - Key guidance: Use `messageIds` for maintainability; include applicability levels; keep fixes minimal

3. **`eslint-custom-rule-tutorial.md`** (10 KB)
   - Source: [ESLint: Custom Rule Tutorial](https://eslint.org/docs/latest/extend/custom-rule-tutorial)
   - Coverage: End-to-end example of ESLint rule creation with real code
   - Key guidance: Imperative tone; context + problem + alternative structure

4. **`fixit-build-a-lint-rule.md`** (12 KB)
   - Source: [Fixit: Build a Lint Rule](https://fixit.readthedocs.io/en/v0.1.4/build_a_lint_rule.html)
   - Coverage: Python linter rule naming, documentation practices, actionable feedback
   - Key guidance: Action-oriented names; brief descriptions with links to extended docs; clear, actionable feedback

5. **`ast-grep/` folder** (3 files)
   - Source: [ast-grep Documentation](https://ast-grep.github.io/)
   - Files:
     - `astgrep-lint-rule.md` — Complete lint rule guide (Find → Rewrite → Patch workflow)
     - `astgrep-rule-config.md` — Rule configuration reference
     - `astgrep-cheatsheet-rule.md` — Quick syntax reference
   - Key guidance: YAML-based rules with Find/Rewrite/Patch; severity levels; constraint filtering

## Integration into SKILL.md

The SKILL.md file has been enhanced with an "Industry Reference Guidance" section that includes:

### Sections Added

1. **Lint Naming & Messaging (from Rustc Dev Guide)**
   - Plain English principle
   - Backtick wrapping for code identifiers
   - Grammatical naturalness test ("allow `X`")
   - Suggestion applicability levels

2. **Rule Messages & Documentation (from ESLint)**
   - `meta.description` for rules index
   - `messageIds` centralization
   - Applicability confidence levels
   - Minimal, mechanical fixes
   - Objective, imperative tone

3. **Lint Rule Documentation Best Practices (from Fixit & Mago)**
   - Brief, informative descriptions
   - Action-oriented naming
   - Rule categorization
   - Detailed rationale with before/after examples

4. **ast-grep Rule Structure**
   - Find → Rewrite → Patch workflow
   - Message and note fields
   - Constraint filtering
   - Severity levels

## Reference File Processing

All reference files were:

- ✅ Enhanced with OKF-compatible frontmatter
- ✅ Cleaned of web navigation noise (sidebars, breadcrumbs, search elements)
- ✅ Code blocks formatted with inline language tags (yaml, javascript, typescript, bash, etc.)
- ✅ Indexed in SKILL.md with direct links to authoritative sources

## How to Use These References

When authoring lint rule content, consult:

1. **For Rule IDs:** rustc-dev-guide-diagnostics.md (naming section)
2. **For Messages:** eslint-custom-rules.md + ESLint tutorial for tone and structure
3. **For Documentation:** fixit-build-a-lint-rule.md for best practices; Mago rules for category patterns
4. **For Tool-Specific Patterns:** ast-grep folder for YAML syntax and Rustc guide for compiler diagnostics

## Key Takeaways

| Aspect                | Standard                               | Source           |
| --------------------- | -------------------------------------- | ---------------- |
| **Naming**            | Kebab-case, "allow" test               | Rustc Dev Guide  |
| **Message Structure** | [Context] + [Problem] + [Alternative]  | SKILL.md, ESLint |
| **Tone**              | Objective, imperative, no shame        | SKILL.md, ESLint |
| **Documentation**     | Brief + links to authoritative sources | Fixit, Mago      |
| **Categorization**    | Clarity, Security, Best Practice, etc. | Mago             |
| **Code in Messages**  | Wrap in backticks                      | Rustc Dev Guide  |
| **Suggestions**       | Include applicability level            | ESLint, Rustc    |

## Next Steps

- Reference these materials when writing lint rule content
- Follow the checklists in SKILL.md for ID, message, and documentation quality
- Cross-reference tool-specific guides (ast-grep, ESLint, Rustc) for implementation details
