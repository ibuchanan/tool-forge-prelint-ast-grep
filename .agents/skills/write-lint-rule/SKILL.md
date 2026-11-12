---
name: write-lint-rule
description: Write human-readable lint rule IDs, messages, and documentation following industry standards. Use when authoring custom rule content—IDs, alert text, and long-form docs—for any linting tool (ESLint, ast-grep, Rustc, etc.). Tool-agnostic guidance emphasizing Clarity, Actionability, and Discoverability with URL references in docs.
---

# Write Lint Rule

Write human-readable content for custom lint rules—specifically rule **IDs**, **Messages**, and **Documentation**—following industry standards independent of tool or language.

The core principle: your rule's human-facing text should prioritize **Clarity**, **Actionability**, and **Discoverability**. Long-form documentation should reference authoritative sources (URLs) rather than embed code examples, enabling language-agnostic rules that work across linting tools.

## Quick Reference

| Element                     | Standard                                        | Example                                                                  |
| --------------------------- | ----------------------------------------------- | ------------------------------------------------------------------------ |
| **Rule ID**                 | Kebab-case, "no-" prefix for forbidding         | `no-eval`, `react-hooks-exhaustive-deps`                                 |
| **Message**                 | [Context] + [Problem] + [Alternative]           | `Avoid 'forEach' when mapping data. Use 'map' to preserve immutability.` |
| **Tone**                    | Objective, imperative, helpful                  | ✅ `Ensure all async functions…` ❌ `Async functions are supposed to…`   |
| **Length**                  | Messages: under 120 chars; docs: full rationale | Keep CLI output scannable; full docs in repo/site                        |
| **Long Description / Note** | URL reference + philosophy + context            | Prefer links to authoritative sources over inline examples               |

## Workflow: Three Layers

### 1. Rule ID Design

**Goal:** Help developers instantly recognize what the rule forbids or enforces.

#### Naming Conventions

- **"No" Prefix for Forbidding:** If a rule forbids something, start with `no-`.
  - ✅ `no-eval`, `no-console`, `no-unused-vars`
  - ❌ `disallow-eval`, `avoid-console`

- **Kebab-Case with Core Entity:** Use lowercase kebab-case focusing on the entity and what is wrong.
  - ✅ `react-hooks-exhaustive-deps`, `missing-error-handling`, `sql-injection-risk`
  - ❌ `useEffectDepsCheck`, `err_handling_missing`

- **Namespace Prefix for Scope:** For organization-specific or tool-specific rules, use a prefix.
  - ✅ `security/no-hardcoded-secrets`, `company/internal-api-only`
  - ❌ `forbidden-secrets`, `api-rule-1`

#### ID Checklist

- [ ] Matches `^[a-z0-9]([a-z0-9-]*[a-z0-9])?$` (kebab-case)
- [ ] Starts with `no-` if forbidding; action-verb if enforcing (`require-`, `prefer-`, etc.)
- [ ] Focuses on the core entity, not the action
- [ ] Scoped with a namespace prefix if needed (e.g., `security/`, `company/`)
- [ ] Avoids acronyms unless widely recognized (`sql`, `html`, `api` are OK; `AWHC` is not)

### 2. Rule Message (The Alert Text)

**Goal:** Concisely explain _why_ the rule triggered and _how to fix it_.

#### The Message Blueprint: [Context] + [Problem] + [Alternative]

A strong message follows this structure:

```
[Context of the issue] + [What is wrong] + [How to fix it]
```

**Weak examples (avoid):**

- `Don't use bad array methods.` — No context, no alternative
- `forEach is not allowed.` — No explanation of why
- `Use immutable operations.` — Too vague, no concrete suggestion

**Strong examples:**

- ✅ `Avoid using 'forEach' when mapping data. Use 'map' instead to preserve immutability.`
- ✅ `The variable "$NAME" is assigned but never read. Consider removing it.`
- ✅ `Ensure all async functions contain a try/catch block to handle potential errors.`

#### Tone Rules

- **Imperative & Objective:** Speak directly to the developer; avoid sarcasm or shame.
  - ✅ `Ensure all async functions contain a try/catch block.`
  - ❌ `Async functions are supposed to have try/catch blocks.`
  - ❌ `Why would you forget try/catch here?`

- **Use Active Voice:** Make the developer the agent of change.
  - ✅ `Remove unused variable "$NAME".`
  - ❌ `Variable "$NAME" was found to be unused.`

- **Leverage Metavariables:** If your linting tool supports it (e.g., ast-grep), inject captured variable names into the message.
  - ✅ `The variable "$NAME" is assigned but never read.`
  - ❌ `A variable is assigned but never read.`

#### Message Checklist

- [ ] Under 120 characters (CLI readability)
- [ ] Contains context (why this matters)
- [ ] Contains problem (what is wrong)
- [ ] Contains alternative (how to fix it)
- [ ] Uses backticks for code symbols: `use \`map\` instead`
- [ ] Imperative tone, no shame or sarcasm
- [ ] If applicable, includes metavariables (e.g., `$VAR`, `$NAME`)

### 3. Rule Documentation / Long Description / Note

**Goal:** Provide rationale and context for developers who look up the rule in your documentation.

Preserve the field name the caller or target tool uses.
If the user asks for a `note`,
or the target linter has a `note` field such as ast-grep,
write `note` content rather than renaming it to generic documentation.
The note should be a concise long-form rationale with at least one URL to an authoritative source.

#### The Documentation Blueprint

Structure your long-form rule documentation as:

##### a) **Rule Overview** (1–2 sentences)

Explain exactly what the rule enforces and the philosophy behind it (Performance, Security, Style, Best Practice).

##### b) **Rationale & Context**

Provide the "why" behind the rule. Link to authoritative sources where possible:

- **Security rules:** Link to OWASP, CWE, or security best practices
- **Performance rules:** Link to performance benchmarks or platform documentation
- **Style rules:** Link to style guide references or language docs
- **Best practices:** Link to established patterns, RFCs, or framework guidelines

##### c) **When Not to Use It** (Optional but valuable)

Explain edge cases or situations where the rule should not apply or be disabled.

#### Documentation Checklist

- [ ] Overview: 1–2 sentences explaining the category (Security/Performance/Style/Best Practice)
- [ ] Rationale: Clear explanation of why this rule matters
- [ ] References: At least one URL to authoritative source (OWASP, MDN, style guide, docs, etc.)
- [ ] Edge cases: When not to apply or how to disable
- [ ] Related rules: Links to similar or complementary rules if applicable
- [ ] If the target field is `note`, keep calling it `note` in the proposed metadata and implementation steps

## Full Example: End-to-End

### Rule: `no-foreach-for-mapping`

**ID:** `no-foreach-for-mapping`

- Prefix: `no-` (forbidding)
- Core entity: `foreach-for-mapping` (the anti-pattern)
- Scope: Language-agnostic (applies to JavaScript, Python, Java, etc.)

**Message:**

```
Avoid using loop constructs for data transformation. Use map/filter operations
to preserve immutability and enable better optimization.
```

(109 characters ✓)

**Documentation:**

```markdown
## no-foreach-for-mapping

Forbids using imperative loop constructs (foreach, for loops) when the intent
is to transform or filter data.

### Overview

This rule enforces functional, immutable patterns over side-effect-based iteration.
Functional transformations are easier to reason about, optimize, and parallelize.

### Rationale & Context

- **Functional Programming Principle:** Data transformation should be declarative,
  not imperative. See [Functional Programming Basics](https://en.wikipedia.org/wiki/Functional_programming)
- **Performance:** Map/filter operations enable compiler optimizations and vectorization.
  See your language's standard library docs for performance characteristics.
- **Readability:** Declarative code expresses intent directly. See
  [The Pragmatic Programmer](https://pragprog.com/titles/tpp20/the-pragmatic-programmer-your-journey-to-mastery-2nd-edition/)

### When Not to Use It

This rule does not apply when side effects are intentional:

- Logging or debugging statements
- Event handling or callbacks
- Imperative loops in test setup/teardown
- Legacy codebases where refactoring is not feasible

Consult your linter's documentation for how to disable this rule on specific lines.
```

## Tips & Gotchas

- **Keep IDs Stable:** Renaming a rule ID breaks downstream configs and documentation. Plan for long-term stability.
- **Avoid Tool-Specific Language:** Write rule IDs and messages in language-agnostic terms. A rule forbidding `forEach` in JavaScript should generalize to `for` loops in Python, not mention language syntax.
- **Use Metavariables Wisely:** If your linter supports variable capture (e.g., `$VAR`, `$NAME`), leverage them in messages to make errors concrete. Keep docs generic.
- **Reference Over Examples:** Link to authoritative sources (OWASP, language docs, style guides, RFCs) instead of embedding code snippets. This keeps docs language-agnostic and maintainable.
- **Test Across Languages:** If your rule applies to multiple languages, verify that the ID and message make sense in each context.
- **Internationalization:** If your rule supports i18n, keep message templates simple and translatable. Avoid idioms or culture-specific phrases.

## Industry Reference Guidance

The following specific practices come from authoritative lint rule documentation:

### Lint Naming & Messaging (from Rustc Dev Guide)

**Key principles from rustc-dev-guide-diagnostics.md:**

- Write in **plain simple English** without jargon
- Error messages should be **matter of fact**, avoiding excessive capitalization and periods
- When mentioning code/identifiers, **wrap in backticks**: `` `functionName` ``
- **Lint names** should read naturally when prefixed with "allow": "allow `unused_variables`" ✓ vs. "allow `unsafe_block`" ✗ (grammatically wrong)
- For **lints that apply to specific types**, mention the type: `unused_variables` not just `unused`
- Provide **suggestions with applicability levels** (MachineApplicable vs. MaybeIncorrect) to signal confidence

**Source:** [Rust Compiler Development Guide: Errors and Lints](https://rustc-dev-guide.rust-lang.org/diagnostics.html)

### Rule Messages & Documentation (from ESLint)

**Key principles from eslint-custom-rules.md:**

- **Rule meta.description:** Short phrase for rules index, used in documentation generation
- **Message structure:** Can use `messageIds` object in `meta.messages` for centralized, maintainable message templates
- **Suggestions:** Include `Applicability` confidence level (`MachineApplicable`, `MaybeIncorrect`) to indicate fix safety
- **Code fixes:** Keep fixes minimal—avoid large refactors; focus on mechanical correctness
- **Tone:** Be objective; guide without shaming. ESLint examples show imperative phrasing: "Avoid X. Use Y instead."

**Source:** [ESLint: Custom Rules](https://eslint.org/docs/latest/extend/custom-rules)

### Lint Rule Documentation Best Practices (from Fixit & Mago)

**Key principles from fixit-build-a-lint-rule.md:**

- **Lint descriptions should be brief but informative**; link to extended docs rather than embedding examples
- **Feedback should be clear and actionable**
- **Docstrings** on the rule class provide context for generated documentation
- **Rule names** should be short and action-oriented, describing the action needed to fix the issue, not the problem itself
  - ✓ `GatherSequentialAwaitRule` (what to do)
  - ✗ `AwaitInLoopLintRule` (just the problem)

**Key principle from Mago PHP Linter (mago.carthage.software):**

- Rules should be **grouped by category** (Clarity, Best Practices, Consistency, Security, Maintainability, Deprecation)
- Each rule should include a **detailed rationale** explaining why the rule exists and what harm/improvement it addresses
- Show **before/after code examples** when documentation is available

**Sources:**

- [Fixit: Build a Lint Rule](https://fixit.readthedocs.io/en/v0.1.4/build_a_lint_rule.html)
- [Mago Linter Rules](https://mago.carthage.software/1.40.2/en/tools/linter/rules/)

### ast-grep Rule Structure (from ast-grep references)

**Key principles from ast-grep-lint-rule.md:**

- Lint rule files use YAML with three core workflows: **Find** → **Rewrite** → **Patch**
- `message` field should be self-descriptive and concise
- `note` field (optional) can contain extended markdown explanation, rationale, or links
- Rules can reference `constraints` to filter matches based on conditions
- Use `severity` levels: `hint`, `info`, `warning`, `error`, `off`

**Source:** [ast-grep: Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)

## Reference Files

Detailed reference material available in `references/`:

- **`rustc-dev-guide-diagnostics.md`** — Comprehensive guide on Rust compiler diagnostics, lint naming, message structure, and suggestion applicability
- **`eslint-custom-rules.md`** — ESLint rule metadata, message templates, and fix guidelines
- **`eslint-custom-rule-tutorial.md`** — Hands-on ESLint example showing rule structure end-to-end
- **`fixit-build-a-lint-rule.md`** — Python lint rule naming conventions and documentation practices
- **`ast-grep/` folder** — YAML-based lint rule structure, finding/rewriting patterns, constraint filtering
  - `astgrep-lint-rule.md` — Complete lint rule guide
  - `astgrep-rule-config.md` — Rule configuration reference
  - `astgrep-cheatsheet-rule.md` — Quick syntax reference
