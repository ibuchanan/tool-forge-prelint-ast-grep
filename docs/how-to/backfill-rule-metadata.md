# Backfill rule metadata with yq

Use these repository-only recipes for explicit metadata maintenance, not assessment approval. Scope intent, source authority, module identity, ratings, and rationale need review under the [rule-authoring policy](../reference/rule-authoring-policy.md). Metadata recipes do not infer scope profiles, extract URLs from prose, or change native scope. The separate severity recipe requires explicit gate review.

## Check and review a rule

1. Run `bash scripts/check-authoring.sh` for all definitions, or pass explicit rule paths for a focused read-only check. There are no migration allowances, including for new rules, companions, and disabled placeholders. Status 1 means violations; status 2 means a tool/input failure that must be fixed, not suppressed. Treat `REVIEW:` as unresolved scope review even with status 0.
2. Match `metadata.category` to the containing directory. Supply nonempty inline precision and impact rationales citing actual test/snapshot evidence; mark untested limitations as gaps. Review precision against the stated policy, and impact against the consequences of genuine non-compliance, independently. Compare equivalent language companions without copying language-specific evidence blindly.
3. Select exact authoritative HTTP(S) references, preserving meaningful queries/fragments. Optional tags use `module:<namespace>:<identifier>` for a documented exact Forge module, or `capability:<name>` for ownership/relevance to one of the 20 required Drop Calf conventions in the [tag vocabulary](../reference/rule-authoring-policy.md#references-and-classifications). Preserve existing module tags and omit uncertain tags; a capability tag never proves installation or changes file routing. Neither a shape check nor a classification proves authority, module identity, or exploitability.
4. Review native scope and real-file routing. Use standard selectors where they express the intended boundary. For a justified permanent exception, select only `[unique]`, document exact positive boundaries, exclusions and test policy in `scope-rationale`, and add or update `rule-tests/fixtures/scope-routing.tsv` and scanner fixtures. Never use `unique`, `off`, or a suppression to hide malformed metadata or avoid a policy decision. Unsupported positive comparisons require explicit maintainer review and routing evidence; do not infer arbitrary glob equivalence.
5. Preview mechanical repairs below. For rating/severity changes, run `bash scripts/report-rule-severity.sh` on the same selection, review promotions to blocking `error` and demotions with a maintainer, then preview `yq -e --from-file "$RULE_AUTHORING_DIR/recipes/severity.yq" "$rule"` before adding `-i`. Do not invent severity overrides or activate `off` placeholders; see the [severity reference](../reference/rule-severity.md).

Keep durable decisions in each rule's metadata and routing tests, not a parallel assessment store. A clean checker does not replace maintainer review of evidence adequacy, rationale truth, companion consistency, reference/tag validity, or unsupported scope relationships.

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

Normalization removes exact duplicate references/tags and orders existing scope selectors according to `authoring/policy.yml`. It does not create absent fields, deduplicate invalid selectors, assign a standard/unique profile, invent rationale, repair classifications, or reorder/deduplicate native `files`/`ignores`. Tag screening checks module-tag shape and the exact required capability vocabulary. Distinct mixed tags retain first-seen order. It does not establish an exact supported Forge module, capability installation/relevance, or a supporting reference.

All four recipes share `validate.yq` guards, not a full policy validator. They reject unsupported layouts, unknown tiers/categories, ID/filename mismatch, explicit null/non-mapping metadata, malformed touched values, invalid known ratings, unsupported tag shapes, unknown/duplicate selectors, multiple documents, YAML anchors, and duplicate mapping keys. Existing unrelated metadata is preserved; OWASP/CWE string content and rationale truth still require review. Missing required assessment fields are not filled in automatically. Run the mandatory authoring checker after any edit.

## Verify the edit

Run the recipe tests, consumer suites, and formatter:

```bash
bash scripts/check-authoring.sh "${rules[@]}"
bun run test
bun run format:check
git diff --check
```

`bun run test` includes consumer tests, real-file routing fixtures, all authoring and recipe regressions, the whole-repository check and `bash scripts/check-package.sh`. The latter creates a real archive without lifecycle scripts, compares its complete membership and loads all four packed consumer configs. The saved archive and lists remain under `.scratch/tmp_rovo_package.*` for inspection; no package is published.

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

Use repository searches and ordinary diffs to discover test/snapshot evidence and likely companions. Maintainers review equivalence, evidence gaps, scope intent, reference authority, and judgments; no report store or companion analyzer is needed. Scope and severity changes are behavior changes requiring review and scanner evidence, not metadata formatting.
