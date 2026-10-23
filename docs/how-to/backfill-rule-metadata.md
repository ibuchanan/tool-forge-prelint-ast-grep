# Backfill rule metadata with yq

Use these repository-only recipes for explicit metadata maintenance, not assessment approval. Scope intent, source authority, module identity, ratings, and rationale need review under the [rule-authoring policy](../reference/rule-authoring-policy.md). These recipes do not infer scope profiles, extract URLs from prose, or change native scope/severity.

## Prerequisites

- Bash and Mike Farah `yq` v4; tested with **v4.54.1**. Other tools named `yq` are not supported.
- Work from the repository root, with a reviewed, explicit selection of ordinary rule files under `rules/<tier>/<category>/<id>.yml`. Do not select symlinks or paths through symlink directories. Do not use stdin: category derives from the selected filename.
- Inspect the worktree first. Back up or commit existing changes; bulk in-place edits are not a transaction. A failure on a later file does not undo earlier files.

In a Bash session, load the tool guard and absolute recipe location:

```bash
source scripts/rule-metadata-env.sh || exit $?
```

The sourced helper checks the `yq` implementation/version and exports `RULE_AUTHORING_DIR`. It has no argument parser, edit mode, or rule-discovery logic.

## Preview and apply categories

Select files explicitly. `category.yq` derives the category from the parent directory, including corrections to existing string values. Review every correction before applying it.

```bash
set -euo pipefail
rules=(
  'rules/recommended/package-json/no-package-main.yml'
  'rules/ecosol/package-scripts/lint-with-forge.yml'
)
mkdir -p "$PWD/.scratch"
work=$(mktemp -d "$PWD/.scratch/tmp_rovo_metadata_preview.XXXXXX")
trap 'rm -rf "$work"' EXIT

for i in "${!rules[@]}"; do
  yq -e --from-file "$RULE_AUTHORING_DIR/recipes/category.yq" \
    "${rules[$i]}" > "$work/$i.yml"
  # diff returns 1 for a proposed change; do not swallow execution errors.
  diff -u "${rules[$i]}" "$work/$i.yml" || { status=$?; [ "$status" -eq 1 ]; }
done
```

After reviewing all previews, apply that same selection:

```bash
for rule in "${rules[@]}"; do
  yq -e -i --from-file "$RULE_AUTHORING_DIR/recipes/category.yq" "$rule"
done
```

No wrapper silently discovers or edits the entire repository. Paths containing spaces or quotes work when passed as quoted arguments.

## Add a reviewed reference

Supply one exact URL explicitly. The reference recipe preserves note prose, inline links, queries/fragments, and existing supported references, removing only exact duplicate strings. Invoke it separately for each reviewed URL and selection.

```bash
rule='rules/recommended/package-json/no-package-main.yml'
export REFERENCE='https://docs.npmjs.com/cli/v11/configuring-npm/package-json/#main'
yq -e --from-file "$RULE_AUTHORING_DIR/recipes/reference.yq" "$rule"
# Review the output first, then:
yq -e -i --from-file "$RULE_AUTHORING_DIR/recipes/reference.yq" "$rule"
```

The offline URL screen accepts HTTP(S), an ASCII hostname, an optional numeric port, and a path/query/fragment without whitespace, quotes, angle brackets, or backslashes. It is deliberately not a full URL parser: unusual valid URLs such as IPv6 authorities are unsupported and require manual review/editing. Passing the screen does not prove validity, reachability, relevance, or authority. Punctuation is not stripped: supply a reviewed URL, not text copied with Markdown delimiters or trailing prose punctuation.

## Normalize existing valid metadata

```bash
rule='rules/recommended/package-json/require-package-private-true.yml'
yq -e --from-file "$RULE_AUTHORING_DIR/recipes/normalize.yq" "$rule"
# After review:
yq -e -i --from-file "$RULE_AUTHORING_DIR/recipes/normalize.yq" "$rule"
```

Normalization removes exact duplicate references/tags and orders existing scope selectors according to `authoring/policy.yml`. It does not create absent fields, deduplicate invalid selectors, assign a standard/unique profile, invent rationale, repair classifications, or reorder/deduplicate native `files`/`ignores`. Tag screening checks `module:<product>:<module>` shape only; it does not establish an exact supported Forge module or a supporting reference.

All three recipes share `validate.yq` guards, not a full policy validator. They reject unsupported layouts, unknown tiers/categories, ID/filename mismatch, explicit null/non-mapping metadata, malformed touched values, invalid known ratings, unsupported tag shapes, unknown/duplicate selectors, multiple documents, YAML anchors, and duplicate mapping keys. Existing unrelated metadata is preserved; OWASP/CWE string content and rationale truth still require review. Missing required assessment fields are not filled in automatically. Ticket 03 owns authoring diagnostics and migration enforcement.

## Verify the edit

Run the recipe tests, consumer suites, and formatter:

```bash
bash scripts/test-rule-metadata.sh
bun run test
bun run format:check
git diff --check
```

The new recipe test is opt-in in ticket 02; CI/check integration belongs to ticket 03. It needs no JavaScript/TypeScript runtime. Existing consumer tests continue using the repository's established runtime/dependencies.

For each edited rule, compare parsed documents with `metadata` removed against a saved before-copy or HEAD. For a tracked rule:

```bash
rule='rules/recommended/package-json/no-package-main.yml'
diff -u \
  <(git show "HEAD:$rule" | yq -o=json -I=0 'del(.metadata) | sort_keys(..)' -) \
  <(yq -o=json -I=0 'del(.metadata) | sort_keys(..)' "$rule")
```

Review `git diff` for all changes, including YAML presentation. yq can change presentation/comments/blank lines; the guarantee is parsed field preservation, not byte-identical successful output. After formatting, rerun the recipe and formatter and confirm no further diff. The tests exercise idempotency and byte-preservation on rejected in-place edits. Do not redirect preview output over the input file.

## Interpret outcomes

- The sourced tool guard returns **0** on success and **2** for a missing/wrong yq implementation or unavailable recipe directory. Stop on failure.
- `yq -e` returns **0** when it emits the transformed document and nonzero for a guard rejection, parse/evaluation/I/O failure, or no result. In tested v4.54.1, recipe guard/parse failures return **1**. Diagnostics on stderr distinguish the cause; no custom exit-code protocol treats errors as advisory findings.
- `diff` returns **0** for equal output, **1** for changes, and greater than **1** for errors.
- Successful edits are mechanical success only, not proof of full metadata or scope compliance. The recipes never approve a legacy package rule's incomplete exclusions as `[package-json, tests]`.

Use repository searches and ordinary diffs to discover test/snapshot evidence and likely companions during tickets 04–07. Maintainers review equivalence, evidence gaps, scope intent, reference authority, and judgments; no report store or companion analyzer is needed. Scope changes belong to ticket 08 and severity changes to ticket 09.
