---
title: "Rule Cheat Sheet"
source: "https://ast-grep.github.io/cheatsheet/rule.html"
type: reference
tags:
  - lint-rules
  - documentation
  - style-guide
created: 2026-07-14T12:38:17.943Z
updated: 2026-07-14T12:38:17.943Z
---

# Rule Cheat Sheet

This cheat sheet provides a concise overview of ast-grep's rule object configuration, covering Atomic, Relational, and Composite rules, along with notes on Utility rules. It's designed as a handy reference for common usage.

## Atomic Rules Cheat Sheet

These are your precision tools, matching individual AST nodes based on their inherent properties.

|                                                                                                      |                                                                                                           |
| ---------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| ⚛️ Atomic Rules                                                                                      |
| yaml<br>`<br>pattern: console.log($ARG)<br>`                                                         | 🧩 Match a node by code structure. e.g. `console.log` call with a single `$ARG`                           |
| yaml<br>`<br>pattern:<br>  context: '{ key: value }'<br>  selector: pair<br>`                        | 🧩 To parse ambiguous patterns, use `context` and specify `selector` AST to search.                       |
| yaml<br>`<br>kind: if_statement<br>`                                                                 | 🏷️ Match an AST node by its `kind` name                                                                   |
| yaml<br>`<br>regex: ^regex.+$<br>`                                                                   | 🔍 Matches node text content against a [Rust regular expression](https://docs.rs/regex/latest/regex/)     |
| yaml<br>`<br>nthChild: 1<br>`                                                                        | 🔢 Find a node by its **1-based index** among its _named siblings_                                        |
| yaml<br>`<br>nthChild:<br>  position: 2<br>  reverse: true<br>  ofRule: { kind: argument_list }<br>` | 🔢 Advanced positional control: `position`, `reverse` (count from end), or filter siblings using `ofRule` |
| yaml<br>`<br>range:<br>  start: { line: 0, column: 0 }<br>  end: { line: 0, column: 13 }<br>`        | 🎯 Matches a node based on its character span: 0-based, inclusive start, exclusive end                    |

## Relational Rules Cheat Sheet

These powerful rules define how nodes relate to each other structurally. Think of them as your AST GPS!

|                                                                            |                                                                                                                                |
| -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| 🔗 Relational Rules                                                        |
| yaml<br>`<br>inside:<br>  kind: function_declaration<br>`                  | 🏠 Target node must appear **inside** its _parent/ancestor_ node matching the sub-rule                                         |
| yaml<br>`<br>has:<br>  kind: method_definition<br>`                        | 🌳 Target node must **have** a _child/descendant_ node matching the sub-rule                                                   |
| yaml<br>`<br>has:<br>  kind: statement_block<br>  field: body<br>`         | 🌳 `field` makes `has`/`inside` match nodes by their [semantic role](https://astgrep.com/advanced/core-concepts#kind-vs-field) |
| yaml<br>`<br>precedes:<br>  pattern: function $FUNC() { $$ }<br>`          | ◀️ Target node must appear _before_ another node matching the sub-rule                                                         |
| yaml<br>`<br>follows:<br>  pattern: let x = 10;<br>`                       | ▶️ Target node must appear _after_ another node matching the sub-rule.                                                         |
| yaml<br>`<br>inside:<br>  kind: function_declaration<br>  stopBy: end<br>` | 🏠 `stopBy` makes relational rules search all the way to the end, not just immediate neighbors.                                |

## Composite Rules Cheat Sheet

Combine multiple rules using Boolean logic. Crucially, these operations apply to a single target node!

|                                                                                                 |                                                                                  |
| ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| 🧠 Composite Rules                                                                              |
| yaml<br>`<br>all:<br>  - pattern: const $VAR = $VALUE<br>  - has: { kind: string_literal }<br>` | ✅ Node must satisfy **ALL** the rules in the list.                              |
| yaml<br>`<br>any:<br>  - pattern: let $X = $Y<br>  - pattern: const $X = $Y<br>`                | 🧡 Node must satisfy **AT LEAST ONE** of the rules in the list.                  |
| yaml<br>`<br>not:<br>  pattern: console.log($$)<br>`                                            | 🚫 Node must **NOT** satisfy the specified sub-rule.                             |
| yaml<br>`<br>matches: is-function-call<br>`                                                     | 🔄 Matches the node if that utility rule matches it. Your gateway to modularity! |

## Utility Rules Cheat Sheet

Define reusable rule definitions to cut down on duplication and build complex, maintainable rule sets.

|                                                                                                                                                                               |                                                                                                         |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| 📦 Utility Rules                                                                                                                                                              |
| yaml<br>`<br>rules:<br>  - id: find-my-pattern<br>    rule:<br>      matches: my-local-check<br>utils:<br>  my-local-check:<br>    kind: identifier<br>    regex: '^my'<br>`  | 🏡 Defined within the `utils` field of your current config file. Only accessible within that file.      |
| yaml<br>`<br># In utils/my-global-check.yml<br>id: my-global-check<br>language: javascript<br>rule:<br>  kind: variable_declarator<br>  has:<br>    kind: number_literal<br>` | 🌍 Defined in separate YAML files in global `utilsDirs` folders, accessible across your entire project. |
