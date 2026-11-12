---
title: "Build a Lint Rule"
source: "https://fixit.readthedocs.io/en/v0.1.4/build_a_lint_rule.html\#Build-a-Lint-Rule"
type: reference
tags:
  - lint-rules
  - documentation
  - style-guide
created: 2026-07-14T12:41:13.987Z
updated: 2026-07-14T12:41:13.987Z
---

# Build a Lint Rule

## Example: NoInheritFromObjectRule

In Python 3, a class is inherited from `object` by default.
Explicitly inheriting from `object` is redundant, so removing it keeps the code simpler.
In this tutorial, we’d like to build a lint rule to identify cases when
a class inherit from object and add an autofix to remove it.

```
[2]:
```

```
# an example with unnecessary object inheritance
class C(object):
    ...

# the above example can be simplified as this
class C:
    ...
```

## Pick a Good Name

Before starting creating a new lint rule, let’s figure out a good short name for it.
**A good lint rule name should be short and actionable.**
Instead of describing the issue, describe the action needs to be taken to fix it.
So developers can easily learn how to fix the issue by just reading the name.
A lint rule name is a class name in camel case and ends with `Rule`.

For example, to suggest gather await calls in a loop, it’s better to name as `GatherSequentialAwaitRule`
instead of `AwaitInLoopLintRule` (less actionable).
If the action need is to remove/cleanup something, it can be named as `No...Rule`, e.g. `NoAssertEqualsRule`.

In this example, we name the rule as NoInheritFromObjectRule.

## Lint Rule Scaffolding

A lint rule is a subclass of [`CstLintRule`](https://fixit.readthedocs.io/en/v0.1.4/build_a_lint_rule.html#fixit.CstLintRule "fixit.CstLintRule") which inherits from CSTVisitor in LibCST.
LibCST provides [visitors](https://libcst.readthedocs.io/en/latest/tutorial.html#Build-Visitor-or-Transformer) for traversing the syntax tree.
Defining a `visit_` or `leave_` functions for a specific types of [CSTNode](https://libcst.readthedocs.io/en/latest/nodes.html) allows us to register a callback function to be called during the syntax tree traversal.

In this example, we can inspect all class definitions in a file by defining a `visit_ClassDef` function, which will get called once per class definition encountered during syntax tree traversal.

To add types, we’ll need to import [ClassDef](https://libcst.readthedocs.io/en/latest/nodes.html#libcst.ClassDef) from libcst, and annotate the function signature:

```
[3]:
```

```
from fixit import CstLintRule
import libcst as cst

class NoInheritFromObjectRule(CstLintRule):
    def visit_ClassDef(self, node: cst.ClassDef) -> None:
        ...
```

We don’t need to perform any work after visiting our children, so we won’t define `leave_ClassDef`.
While not needed for this lint rule, if we wanted to visit specific attributes of a given node type,
we could specify that attribute as part of the method name too:

```
[4]:
```

```
def visit_If(self, node: cst.If) -> None:
    # called first
    ...

def visit_If_test(self, node: cst.If) -> None:
    # called after visit_If, but before we visit the test attribute
    # `leave_If_test` would be called next, followed by `leave_If`.
    if check_something(node.test):
        ...
```

Iteration order of attributes is the same as the order they appear in the source code.
In this case, that means visit\_If\_test is called before visit\_If\_body and visit\_If\_orelse.

Use fixit’s cli to generate a skeleton of adding a new rule file:

```
$ python -m fixit.cli.add_new_rule # Creates new.py at fixit/rules/new.py
$ python -m fixit.cli.add_new_rule --path fixit/rules/my_rule.py --name rule_name # Creates my_rule.py at path specified
```

This will generate a rule file used to create and add new rule to fixit module.

The fixit.cli.add\_new\_rule contains two argument, `-path` and `--name`

- `--path` is used to create rule file at path given in `--path`, defaults to `fixit/rules/new.py`

- `--name` is used to assign the name of the rule and should be in snake case, defaults to the rule file name if `path` provided else new. Otherwise, considers the value specified in `--name`

Please provide the name of the rule in snake case without the suffix `rule` as CLI will take care of adding `Rule` to end of the rule name.

```
[6]:
```

```
! python -m fixit.cli.add_new_rule --path fixit/rules/my_rule.py --name abcd
```

```
All done! ✨ 🍰 ✨
1 file left unchanged.
Successfully created my_rule.py rule file at fixit/rules
```

```
[7]:
```

```
! cat fixit/rules/my_rule.py
```

```
# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

import libcst as cst
import libcst.matchers as m

from fixit import CstLintRule, InvalidTestCase as Invalid, ValidTestCase as Valid

"""
This is a model rule file for adding a new rule to fixit module
"""

class AbcdRule(CstLintRule):
    """
    docstring or new_rule description
    """

    MESSAGE = "Enter rule description message"

    VALID = [Valid("'example'")]

    INVALID = [Invalid("'example'")]
```

Now, you can add rule’s functionality on top of above generated file. Also, make sure to check the class name in generated file. Your class name should always be suffixed with `Rule`.

## The Declarative Matcher API

Once we have a `ClassDef` node, we need to see if it contains a base class named `object`.
We could implement by inspecting attributes of the node using equality and isinstance.

```
[8]:
```

```
# check if any of the base classes of this class def is "object"
def visit_ClassDef(self, node: cst.ClassDef):
    has_object_base = any(
        isinstance(arg.value, cst.Name) and arg.value.value == "object"
        for arg in node.bases
    )
```

Unfortunately, that imperative approach isn’t easy to read or write, especially when matching a more complex syntax tree structure.
LibCST has [a declarative matcher API](https://libcst.readthedocs.io/en/latest/matchers_tutorial.html)
which allows you to define the shape of an object to match. It’s like a regular expression, but for the CST.

```
[9]:
```

```
import libcst.matchers as m

def visit_ClassDef(self, node: cst.ClassDef):
    has_object_base = m.matches(
        node, m.ClassDef(bases=[m.AtLeastN(n=1, matcher=m.Arg(value=m.Name("object")))])
    )
```

It makes the code easier to read and maintain.

## Reporting Violations

To report a lint violation, simply call [`report()`](https://fixit.readthedocs.io/en/v0.1.4/build_a_lint_rule.html#fixit.CstLintRule.report "fixit.CstLintRule.report") with a CSTNode.
Define a lint message via the `MESSAGE` attribute in your lint class.
Keep your lint descriptions brief but informative. Link to other documentation if you want to provide an extended explanation. Feedback that you provide to a developer should be clear and actionable.
Add a docstring to the rule class to provide more context and the docstring will be included in the generated document.

```
[10]:
```

```
class NoInheritFromObjectRule(CstLintRule):
    """
    In Python 3, a class is inherited from ``object`` by default.
    Explicitly inheriting from ``object`` is redundant, so removing it keeps the code simpler.
    """
    MESSAGE = "Inheriting from object is a no-op. 'class Foo:' is just fine =)"

    def visit_ClassDef(self, node: cst.ClassDef) -> None:
        new_bases = tuple(
            base for base in node.bases if not m.matches(base.value, m.Name("object"))
        )
        if tuple(node.bases) != new_bases:
            self.report(node)
```

## Adding an Autofix

Warning a user about a problem is nice, but offering to fix it for them is even better!
That’s what you can do with an auto-fixer.
Currently we support replacing a node (use [with\_changes](https://libcst.readthedocs.io/en/latest/nodes.html#libcst.CSTNode.with_changes) to modify a CSTNode) or removing it (by passing a [libcst.RemovalSentinel](https://libcst.readthedocs.io/en/latest/visitors.html?highlight=RemovalSentinel#libcst.RemovalSentinel) as the replacement).
In our example, we want to remove any references to object in the base classes of a class definition:

```
[11]:
```

```
class NoInheritFromObjectRule(CstLintRule):
    MESSAGE = "Inheriting from object is a no-op. 'class Foo:' is just fine =)"

    def visit_ClassDef(self, node: cst.ClassDef) -> None:
        new_bases = tuple(
            base for base in node.bases if not m.matches(base.value, m.Name("object"))
        )

        if tuple(node.bases) != new_bases:
            # reconstruct classdef, removing parens if bases and keywords are empty
            new_classdef = node.with_changes(
                bases=new_bases,
                lpar=cst.MaybeSentinel.DEFAULT,
                rpar=cst.MaybeSentinel.DEFAULT,
            )

            # report warning and autofix
            self.report(node, replacement=new_classdef)
```

This example also makes use of [libcst.MaybeSentinel](https://libcst.readthedocs.io/en/latest/nodes.html?highlight=MaybeSentinel#libcst.MaybeSentinel) to properly handle the rendering syntax.
In this case, using a MaybeSentinel for the parens fields will remove the parentheses following the class name if removing object from bases means there are no other base classes or keywords in the class definition.

## Skipping Files

Certain behaviors may be acceptable in a set of files, but not in others.
We can avoid running the linter on some files by overriding should\_skip\_file.
The properties provided by `self.context` ( [`BaseContext()`](https://fixit.readthedocs.io/en/v0.1.4/build_a_lint_rule.html#fixit.common.base.BaseContext "fixit.common.base.BaseContext")) are useful when implementing `should_skip_file()`.

```
[12]:
```

```
class MyRule(CstLintRule):
    def should_skip_file(self):
        # Assert statements are okay for tests.
        # We could check the self.context.file_path object (see pathlib.Path), but
        # Context has a helper property for tests, since this is a common use-case
        return self.context.in_tests
```

Your lint rule does something, but now you need to test it.
Testing lint rules is easy, and every lint rule should include test cases.
Continue to the next tutorial [Test a Lint Rule](https://fixit.readthedocs.io/en/v0.1.4/test_a_lint_rule.html)

## Reference

_class_`fixit.``CstLintRule` [](https://fixit.readthedocs.io/en/v0.1.4/build_a_lint_rule.html#fixit.CstLintRule "Permalink to this definition")`MESSAGE` [](https://fixit.readthedocs.io/en/v0.1.4/build_a_lint_rule.html#fixit.CstLintRule.MESSAGE "Permalink to this definition")

a short message in one or two sentences show to user when the rule is violated.

`METADATA_DEPENDENCIES` _= (<class 'libcst.metadata.position\_provider.PositionProvider'>,)_ [](https://fixit.readthedocs.io/en/v0.1.4/build_a_lint_rule.html#fixit.CstLintRule.METADATA_DEPENDENCIES "Permalink to this definition")`should_skip_file`() → bool [](https://fixit.readthedocs.io/en/v0.1.4/build_a_lint_rule.html#fixit.CstLintRule.should_skip_file "Permalink to this definition")`report`( _node: libcst.\_nodes.base.CSTNode_, _message: Optional\[str\] = None_, _\*_, _position: Optional\[libcst.\_position.CodePosition\] = None_, _replacement: Union\[libcst.\_nodes.base.CSTNode_, _libcst.\_flatten\_sentinel.FlattenSentinel_, _libcst.\_removal\_sentinel.RemovalSentinel_, _None\] = None_) → None [](https://fixit.readthedocs.io/en/v0.1.4/build_a_lint_rule.html#fixit.CstLintRule.report "Permalink to this definition")

Report a lint violation for a given node. Optionally specify a custom
position to report an error at or a replacement node for an auto-fix.

_classmethod_`requires_metadata_caches`() → bool [](https://fixit.readthedocs.io/en/v0.1.4/build_a_lint_rule.html#fixit.CstLintRule.requires_metadata_caches "Permalink to this definition")_class_`fixit.common.base.``BaseContext` [](https://fixit.readthedocs.io/en/v0.1.4/build_a_lint_rule.html#fixit.common.base.BaseContext "Permalink to this definition")_property_`in_tests` [](https://fixit.readthedocs.io/en/v0.1.4/build_a_lint_rule.html#fixit.common.base.BaseContext.in_tests "Permalink to this definition")_property_`in_scripts` [](https://fixit.readthedocs.io/en/v0.1.4/build_a_lint_rule.html#fixit.common.base.BaseContext.in_scripts "Permalink to this definition")_class_`fixit.``CstContext` [](https://fixit.readthedocs.io/en/v0.1.4/build_a_lint_rule.html#fixit.CstContext "Permalink to this definition")
