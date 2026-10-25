# Glossary

## Category

The subject area of a rule. A category is distinct from the rule's deployment
tier, file scope, and security classifications.

## Impact

The seriousness of the consequences of genuine non-compliance with a rule's
policy, independently of how reliably the rule detects that non-compliance.

## Language companion

A rule expressing the same policy for another parser language. Equivalent
companions share their policy judgments while retaining language-specific
limitations and evidence.

## Precision

Confidence that a match establishes non-compliance with the stated policy.
Precision is not confidence that the finding is exploitable.

## Scope profile

A named selection of conventions governing where a rule applies. Standard scope
profiles compose runtime scope, artifact scope, and test inclusion. A unique
scope profile expresses a justified rule-specific boundary.

## Severity

The diagnostic level assigned to a finding. Severity is distinct from impact;
it reflects both precision and impact. An explicitly disabled rule has no
active diagnostic level.

## Tag

A descriptive classification of a rule's relevance to a Forge module or ownership
by a Drop Calf capability convention. A tag does not determine where the rule
executes or establish that a capability is installed.

## Tier

A consumer-facing grouping of rules. A tier is not a scope profile or an impact
rating.
