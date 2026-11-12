---
title: "Custom Rule Tutorial"
source: "https://eslint.org/docs/latest/extend/custom-rule-tutorial"
type: reference
tags:
  - lint-rules
  - documentation
  - style-guide
created: 2026-07-14T12:41:13.988Z
updated: 2026-07-14T12:41:13.988Z
---

# Custom Rule Tutorial

## Table of Contents

This tutorial covers how to create a custom rule for ESLint and distribute it with a plugin.

You can create custom rules to validate if your code meets a certain expectation, and determine what to do if it does not meet that expectation. Plugins package custom rules and other configuration, allowing you to easily share and reuse them in different projects.

To learn more about custom rules and plugins refer to the following documentation:

Create a custom rule if the ESLint [built-in rules](https://eslint.org/docs/latest/rules/) and community-published custom rules do not meet your needs. You might create a custom rule to enforce a best practice for your company or project, prevent a particular bug from recurring, or ensure compliance with a style guide.

Before creating a custom rule that isn’t specific to your company or project, it’s worth searching the web to see if someone has published a plugin with a custom rule that solves your use case. It’s quite possible the rule may already exist.

Before you begin, make sure you have the following installed in your development environment:

This tutorial also assumes that you have a basic understanding of ESLint and ESLint rules.

The custom rule in this tutorial requires that all `const` variables named `foo` are assigned the string literal `"bar"`. The rule is defined in the file `enforce-foo-bar.js`. The rule also suggests replacing any other value assigned to `const foo` with `"bar"`.

For example, say you had the following `foo.js` file:

```javascript

```

Running ESLint with the rule would flag `"baz123"` as an incorrect value for variable `foo`. If ESLint is running in autofix mode, then ESLint would fix the file to contain the following:

```javascript

```

First, create a new project for your custom rule. Create a new directory, initiate a new npm project in it, and create a new file for the custom rule:

```shell

```

In the `enforce-foo-bar.js` file, add some scaffolding for the `enforce-foo-bar` custom rule. Also, add a `meta` object with some basic information about the rule.

```javascript

```

Before writing the rule, add some metadata to the rule object. ESLint uses this information when running the rule.

Start by exporting an object with a `meta` property containing the rule’s metadata, such as the rule type, documentation, and fixability. In this case, the rule type is “problem,” the description is “Enforce that a variable named `foo` can only be assigned a value of ‘bar’.”, and the rule is fixable by modifying the code.

Because this rule targets JavaScript, we also add `languages: ["js/js"]` to declare that it only applies to the built-in JavaScript language. ESLint will throw an error if this rule is enabled for a non-JavaScript language.

```javascript

```

To learn more about rule metadata, refer to [Rule Structure](https://eslint.org/docs/latest/extend/custom-rules#rule-structure).

Define the rule’s `create` function, which accepts a `context` object and returns an object with a property for each syntax node type you want to handle. In this case, you want to handle `VariableDeclarator` nodes.
You can choose any [ESTree node type](https://github.com/estree/estree) or [selector](https://eslint.org/docs/latest/extend/selectors).

Tip

You can view the AST for any JavaScript code using [Code Explorer](http://explorer.eslint.org/). This is helpful in determining the type of nodes you’d like to target.

Inside the `VariableDeclarator` visitor method, check if the node represents a `const` variable declaration, if its name is `foo`, and if it’s not assigned to the string `"bar"`. You do this by evaluating the `node` passed to the `VariableDeclaration` method.

If the `const foo` declaration is assigned a value of `"bar"`, then the rule does nothing. If `const foo` **is not** assigned a value of `"bar"`, then `context.report()` reports an error to ESLint. The error report includes information about the error and how to fix it.

```javascript

```

With the rule written, you can test it to make sure it’s working as expected.

ESLint provides the built-in [`RuleTester`](https://eslint.org/docs/latest/integrate/nodejs-api#ruletester) class to test rules. You do not need to use third-party testing libraries to test ESLint rules, but `RuleTester` works seamlessly with tools like Mocha and Jest.

Next, create the file for the tests, `enforce-foo-bar.test.js`:

```shell

```

You will use the `eslint` package in the test file. Install it as a development dependency:

npmyarnpnpmbun

```shell

```

```shell

```

```shell

```

```shell

```

And add a test script to your `package.json` file to run the tests:

```javascript

```

To write the test using `RuleTester`, import the class and your custom rule into the `enforce-foo-bar.test.js` file.

The `RuleTester#run()` method tests the rule against valid and invalid test cases. If the rule fails to pass any of the test scenarios, this method throws an error.
`RuleTester` requires that at least one valid and one invalid test scenario be present.

```javascript

```

Run the test with the following command:

```shell

```

If the test passes, you should see the following in your console:

```shell

```

Now that you’ve written the custom rule and validated that it works, you can include it in a plugin. Using a plugin, you can share the rule in an npm package to use in other projects.

Create the file for the plugin:

```shell

```

And now write the plugin code. Plugins are just exported JavaScript objects. To include a rule in a plugin, include it in the plugin’s `rules` object, which contains key-value pairs of rule names and their source code.

To learn more about creating plugins, refer to [Create Plugins](https://eslint.org/docs/latest/extend/plugins).

```javascript

```

You can use a locally defined plugin to execute the custom rule in your project. To use a local plugin, specify the path to the plugin in the `plugins` property of your ESLint configuration file.

You might want to use a locally defined plugin in one of the following scenarios:

- You want to test the plugin before publishing it to npm.
- You want to use a plugin, but do not want to publish it to npm.

Before you can add the plugin to the project, create an ESLint configuration for your project using a [flat configuration file](https://eslint.org/docs/latest/use/configure/configuration-files), `eslint.config.js`:

```shell

```

Then, add the following code to `eslint.config.js`:

```javascript

```

Before you can test the rule, you must create a file to test the rule on.

Create a file `example.js`:

```shell

```

Add the following code to `example.js`:

```javascript

```

Now you’re ready to test the custom rule with the locally defined plugin.

Run ESLint on `example.js`:

npmyarnpnpmbun

```shell

```

```shell

```

```shell

```

```shell

```

This produces the following output in the terminal:

```text

```

To publish a plugin containing a rule to npm, you need to configure the `package.json`. Add the following in the corresponding fields:

1. `"name"`: A unique name for the package. No other package on npm can have the same name.
2. `"main"`: The relative path to the plugin file. Following this example, the path is `"eslint-plugin-example.js"`.
3. `"description"`: A description of the package that’s viewable on npm.
4. `"peerDependencies"`: Add `"eslint": ">=10.0.0"` as a peer dependency. Any version greater than or equal to that is necessary to use the plugin. Declaring `eslint` as a peer dependency requires that users add the package to the project separately from the plugin.
5. `"keywords"`: Include the standard keywords `["eslint", "eslintplugin", "eslint-plugin"]` to make the package easy to find. You can add any other keywords that might be relevant to your plugin as well.

A complete annotated example of what a plugin’s `package.json` file should look like:

```javascript

```

To publish the package, run `npm publish` and follow the CLI prompts.

You should see the package live on npm!

Next, you can use the published plugin.

Run the following command in your project to download the package:

npmyarnpnpmbun

```shell

```

```shell

```

```shell

```

```shell

```

Update the `eslint.config.js` to use the packaged version of the plugin:

```javascript

```

Now you’re ready to test the custom rule.

Run ESLint on the `example.js` file you created in step 8, now with the downloaded plugin:

npmyarnpnpmbun

```shell

```

```shell

```

```shell

```

```shell

```

This produces the following output in the terminal:

```text

```

As you can see in the above message, you can actually fix the issue with the `--fix` flag, correcting the variable assignment to be `"bar"`.

Run ESLint again with the `--fix` flag:

npmyarnpnpmbun

```shell

```

```shell

```

```shell

```

```shell

```

There is no error output in the terminal when you run this, but you can see the fix applied in `example.js`. You should see the following:

```javascript

```

In this tutorial, you’ve made a custom rule that requires all `const` variables named `foo` to be assigned the string `"bar"` and suggests replacing any other value assigned to `const foo` with `"bar"`. You’ve also added the rule to a plugin, and published the plugin on npm.

Through doing this, you’ve learned the following practices which you can apply to create other custom rules and plugins:

1. Creating a custom ESLint rule
2. Testing the custom rule
3. Bundling the rule in a plugin
4. Publishing the plugin
5. Using the rule from the plugin

You can view the [annotated source code for the tutorial](https://github.com/eslint/eslint/tree/main/docs/_examples/custom-rule-tutorial-code).

## Table of Contents

© OpenJS Foundation and ESLint contributors, [www.openjsf.org](https://www.openjsf.org/). Content licensed under [MIT License](https://github.com/eslint/eslint/blob/main/LICENSE).

LightSystemDark

Language Switcher

Selecting a language will take you to the ESLint website in that language.

Language

🇺🇸 English (US)
(Latest)

🇨🇳 简体中文
(最新)
