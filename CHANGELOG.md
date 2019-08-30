## 1.2.0
- Added a hash map-based `ruleMap` to `SuffixRules` to speed up the performance when matching rules.
- Added `subdomain` and `icannSubdomain` to `PublicSuffix`.
- Added `isSubdomainOf`, `hasKnownSuffix` and `hasValidDomain` to `PublicSuffix`.
- Added `DomainUtils` with the following static functions:
    - `isSubdomainOf`
    - `isSubdomain`
    - `isKnownSuffix`
    - `hasValidDomain`
- Added `PublicSuffix.fromString` as a convenience method for `PublicSuffix(Uri.parse(string))`.
- Updated docs and parameter names to say URL instead of URI, which is more correct (`PublicSuffix.sourceUri` is unchanged to avoid breaking changes).

## 1.1.0
- Added primary library `public_suffix.dart`, which can be used without `dart:io` and `dart:html` (but still requires to be initialised with a suffix list).

## 1.0.0
- Load suffix rule lists from strings or URIs.
- Parse URLs against suffix lists to obtain:
    - public suffix (e.g. `co.uk`)
    - root domain (e.g. `google`)
    - registrable domain (e.g. `google.co.uk`)
- Obtain results with and without private (i.e. non-ICANN/IANA) suffix rules.
- Obtain punycode encoded and decoded results (if a punycoded URL is parsed).
