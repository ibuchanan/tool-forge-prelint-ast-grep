# Rule severity reference

Enabled consumer rules use the [reviewed precision/impact matrix](rule-authoring-policy.md#severity-matrix).
`authoring/policy.yml` is its executable data source. Only high precision and high
impact produce `error`. Precision concerns the stated policy, not exploitability;
impact describes supported consequences, not every match's observed harm.
`off` remains disabled and still requires valid ratings.

## Repository interfaces

The scripts require Bash, Mike Farah yq v4 and the existing authoring tools.
They are repository-only and are not loaded by consumer configurations.

| Interface                                                    | Contract                                                                                                                                                                                       |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `bash scripts/report-rule-severity.sh [rule.yml ...]`        | Read-only TSV; defaults to all shipped rules. Returns 0 for a complete report, including differences, or 2 for invalid input/tool failure. No partial report is emitted.                       |
| `bash scripts/check-authoring.sh [rule.yml ...]`             | Enforces current versus expected severity alongside other authoring checks. Stale or unsupported severity is a `severity` violation (status 1); unsafe input or execution failure is status 2. |
| `yq --from-file authoring/recipes/severity.yq <rule.yml>`    | Preview of one transformed rule document. Requires `source scripts/rule-metadata-env.sh` first.                                                                                                |
| `yq -i --from-file authoring/recipes/severity.yq <rule.yml>` | Explicit edit after preview and approval; only the parsed severity changes. Repeated application is idempotent. yq may reflow YAML presentation.                                               |
| `bash scripts/test-rule-severity.sh`                         | Matrix, document preservation, disabled/input rejection, report/status, enforcement/repair and real consumer gate regression tests; included in `test:authoring`.                              |

The report columns are `file`, `id`, `precision`, `impact`, `current`, `expected`,
and `blocking`. Blocking labels are `unchanged`, `disabled`, `promote-to-error`,
`demote-from-error`, or `nonblocking-change`. It reports every selected rule,
not only differences. Missing/invalid ratings and unsupported current severities
are rejected, including on disabled definitions; no classification is inferred
from names, messages or notes. The edit recipe also uses the existing layout and
metadata guards. The report rejects unsafe/multiple YAML documents before lookup.

The report does not approve changes. Every error promotion, error demotion and
nonblocking change requires review; disputed ratings return to the rubric.
There are no severity overrides, automatic apply command or report database.
Bulk editing consists of explicit recipe invocations over reviewed files. An
invocation failure stops that operation; a multi-file shell loop is not an atomic
transaction. Preview and diff review remain required.

## Ticket 09 approved rollout

On 2026-10-23 the maintainer approved the complete 206-rule preview and all 93
changes, without rating corrections. The earlier ticket 04–07 assessments and
each rule's inline evidence remain the rating basis. The shipped rule diff
contains only one severity-line replacement in each of the 93 definitions.
IDs, languages, matchers, utilities, fixes, prose, exclusions, metadata, test
snapshots, consumer configurations and dependencies remain unchanged.

| Current | Expected | Definitions | Blocking effect       |
| ------- | -------- | ----------: | --------------------- |
| warning | error    |           2 | New blocking findings |
| error   | warning  |          42 | No longer blocking    |
| error   | info     |           2 | No longer blocking    |
| hint    | warning  |           6 | Nonblocking           |
| info    | warning  |           5 | Nonblocking           |
| hint    | info     |           9 | Nonblocking           |
| warning | info     |          24 | Nonblocking           |
| warning | hint     |           2 | Nonblocking           |
| info    | hint     |           1 | Nonblocking           |

The two promotions are `no-global-state-mutation` and
`no-module-scope-mutable-state`: their syntax directly violates the stated
convention, with high conditional tenant-isolation impact. This does not prove
that every match leaks tenant data. The 44 demotions include both
`no-hardcoded-atlassian-token` definitions, environment disclosure, sensitive-data
logging, JWT `none`, package-script TLS bypass, contextual API/import/frontend
and runtime-boundary checks, and bounded compiler/license conventions. Their
reviewed precision/impact do not meet the high/high error threshold. The token
prefix cannot distinguish realistic fabricated credentials from genuine ones.
No rating was raised merely to retain an old gate.

After rollout, the 206 definitions comprise 11 errors, 134 warnings, 57 infos and
4 hints, with no disabled definitions at this baseline. Disabled preservation is
covered using isolated definitions rather than activating a shipped placeholder.

## Consumer scan behavior

With ast-grep 0.51, the blocking-only scan is:

```sh
ast-grep scan --config sgconfig.strict.yml --min-severity error <app-src>
```

The all-severity scan is:

```sh
ast-grep scan --config sgconfig.strict.yml --json --include-metadata <app-src>
```

Both return 1 when selected error findings exist. An all-severity scan containing
only warning/info/hint findings returns 0; these findings still need review.
`--min-severity error` excludes advisory rules rather than promoting them.
`--error` changes severity and is not a blocking-only filter.

Real-file regression checks assert both promoted rules produce error diagnostics
and status 1 in both modes. A token example produces warning diagnostics and
status 0 in all-severity mode, and an empty result/status 0 in blocking-only mode.
Invalid scanner configuration produces an execution failure (status greater than
1), not advisory success. A reporting wrapper must validate the scanner's status
and result shape; `|| true` would hide broken scanners/configuration.

References: [ast-grep severity configuration](https://ast-grep.github.io/reference/yaml.html)
and [scan CLI](https://ast-grep.github.io/reference/cli/scan.html).
