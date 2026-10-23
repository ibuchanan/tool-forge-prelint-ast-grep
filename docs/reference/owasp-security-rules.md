# OWASP security rules

Forge Prelint's source-level security checks extend its OWASP instrumentation
with rules for cryptography, credentials, configuration, and input-sensitive
operations. The families below carry `metadata.owasp` and `metadata.cwe` using
OWASP Top 10 **2021** categories. Other security rules may reference the 2025
edition; category numbers are edition-specific.

These families are included by the `strict`, `atlassian`, and `ecosol` tiers,
not `recommended`. Each has a TypeScript base rule, a `-tsx` companion, and a
`-js` JavaScript/JSX companion. Companion rules share severity and metadata.
The checks run locally without a registry or network access once ast-grep is
installed.

## Rule coverage

| OWASP 2021 category                            | Rule                           | Severity | Detection boundary                                                                                                                                                                                                  |
| ---------------------------------------------- | ------------------------------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| A01 Broken Access Control                      | `review-input-filesystem-path` | warning  | Direct input syntax in the path argument of `fs.readFile`, `readFileSync`, `writeFile`, `writeFileSync`, `appendFile`, `appendFileSync`, `createReadStream`, and `createWriteStream`; no path-containment analysis. |
| A01 Broken Access Control                      | `review-input-redirect`        | warning  | Direct input syntax in the first redirect argument; status-code-first signatures are not covered.                                                                                                                   |
| A02 Cryptographic Failures                     | `no-weak-hash`                 | warning  | Literal MD5/SHA-1 first arguments to `createHash` calls or methods, case-insensitively; imports and purpose are not resolved.                                                                                       |
| A02 Cryptographic Failures                     | `no-insecure-randomness`       | warning  | `Math.random()` inside declaration, assignment, or object-property values with security-sensitive name suffixes.                                                                                                    |
| A02 Cryptographic Failures                     | `no-jwt-none-algorithm`        | warning  | Object pairs with `algorithm`/`algorithms` and literal `none`, including array entries; assumes JWT configuration.                                                                                                  |
| A03 Injection                                  | `review-input-sql`             | warning  | Direct input syntax in the first argument of `.query`, `.execute`, or `.raw`; bound values in later arguments are not matched.                                                                                      |
| A03 Injection                                  | `review-input-shell-command`   | warning  | Direct input syntax in the first argument of `.exec`, `.execSync`, `.spawn`, `.spawnSync`, or bare `exec`/`execSync`; argument arrays and `shell: true` are not analyzed.                                           |
| A03 Injection                                  | `no-dynamic-code-evaluation`   | error    | Direct `eval`/`Function` calls and literal string timer callbacks; visible shadowing is conservatively excluded.                                                                                                    |
| A03 Injection                                  | `review-raw-html-sink`         | warning  | Raw-HTML sinks, including literal and sanitized HTML; not proof of XSS.                                                                                                                                             |
| A05 Security Misconfiguration                  | `no-disabled-tls-verification` | error    | Literal environment bypass and imported Node HTTPS/TLS/undici inline options; arbitrary `rejectUnauthorized` objects are not matched.                                                                               |
| A05 Security Misconfiguration                  | `no-wildcard-cors-origin`      | warning  | Literal wildcard object headers and subscript assignments; public endpoints may intentionally allow non-credentialed browser access.                                                                                |
| A07 Identification and Authentication Failures | `review-hardcoded-secret`      | warning  | Secret-like binding/key names with strings or static templates; placeholders can match, interpolated templates are excluded.                                                                                        |
| A08 Software and Data Integrity Failures       | `review-input-module-load`     | warning  | Direct input syntax in `require`/dynamic `import` module arguments.                                                                                                                                                 |
| A10 Server-Side Request Forgery                | `review-input-fetch-url`       | warning  | Direct input syntax in `fetch`/`.fetch` URL arguments; URL structure and runtime environment are not inferred.                                                                                                      |

The `review-dynamic-forge-sql` family separately checks interpolated or
concatenated `prepare`/`executeRaw` calls on imported `@forge/sql` clients.
The Atlassian-token detector and the name-only hardcoded-secret heuristic are
separate advisory warning checks. Their precision differs; neither reaches the
reviewed matrix's high/high blocking threshold.

## Input model and analysis limits

The input-sensitive rules inspect syntax, **not taint flows**. They recognize
`payload`, `$X.payload`, `$REQ.queryParameters`, and `$REQ.body` either as the
sink's first argument or nested inside it. Only actual AST expressions count,
not text inside comments or strings. Source and method names are heuristics,
not resolved runtime identities.

| Expression                                             | Direct-input finding                               |
| ------------------------------------------------------ | -------------------------------------------------- |
| `fetch(payload.url)`                                   | Yes                                                |
| `fetch(request.body.url)`                              | Yes                                                |
| ``fetch(`https://example.com/${payload.path}`)``       | Yes; fixed-host interpolation still needs review.  |
| `fetch(validateUrl(payload.url))`                      | Yes; validation and sanitizers are not recognized. |
| `const url = payload.url; fetch(url)`                  | No; variable aliases are not traced.               |
| `const { url } = payload; fetch(url)`                  | No; destructured values are not traced.            |
| `db.query('SELECT ?', [payload.id])`                   | No; the statement is fixed.                        |
| `fetch('https://example.com', { body: payload.body })` | No; the URL is fixed.                              |
| `cp.spawn('tool', [payload.arg])`                      | No; only executable selection is checked.          |

Cross-function/cross-file flows, renamed inputs, computed source properties,
lexical shadowing, imports, sanitizer correctness, authorization and host/path
allowlist correctness are not inferred by these direct-input rules. A no-finding
case is **not** a safety judgment. The randomness rule matches the suffixes
`token`, `secret`, `password`, `passwd`, `key`, `nonce`, `salt`, `otp`, `session`,
and `csrf`: `session` matches, but `sessionId` does not. Timer callbacks stored
in variables or interpolated templates are not checked by the literal timer
branch.

## Severity and scanning

Direct-input, raw-HTML and name-only secret findings are advisory warnings:
syntactic containment alone does not prove exploitability. JWT `none` is also a
warning: its configuration-shape matcher does not resolve library identity.
Dynamic code evaluation and explicit source-level TLS bypasses remain errors;
the package-script TLS check is a warning. Global-mutation and module-scope
mutable-state conventions now produce errors. These levels follow the explicitly
[reviewed severity rollout](rule-severity.md), not a claim of proven exploitation.

With ast-grep 0.51, a blocking pass over the **whole strict tier** is:

```sh
ast-grep scan --config sgconfig.strict.yml --min-severity error <app-src>
```

The all-severity JSON pass is:

```sh
ast-grep scan --config sgconfig.strict.yml --json --include-metadata <app-src>
```

The second command can still exit 1 when errors are present. An advisory runner
can accept finding status 1 while treating scanner/configuration failures as
failures; it must not indiscriminately ignore all exit statuses. `--error`
promotes rules to errors; `--min-severity error` filters the scan to errors.
The strict tier also includes other Forge policies, not only these families.

Source rules exclude `node_modules`, `dist`, `coverage`, `specs`, `*.test.*`,
`*.spec.*`, `__tests__`, `test` and `tests`; `build` remains included after the
[scope normalization](rule-scope-routing.md). Security scanning of test code
needs a separate policy. Unit tests exercise matching even in excluded paths;
real-scanner fixtures cover routing. No security-boundary autofixes are
provided.

## Scope boundaries

These source checks do not establish coverage of A04 Insecure Design, A06
Vulnerable and Outdated Components, or A09 Security Logging and Monitoring
Failures. Architecture review, dependency scanning and operational validation
remain necessary. Other Forge Prelint logging checks are not evidence that
operational monitoring is sufficient. A clean scan is not OWASP compliance or
proof that an app is secure. Taint-capable analysis is needed to assess
source-to-sink flows beyond direct syntax.

References: [OWASP Top 10 (2021)](https://owasp.org/Top10/),
[ast-grep rule model](https://ast-grep.github.io/guide/rule-config.html), and
[ast-grep scan CLI](https://ast-grep.github.io/reference/cli/scan.html).
