## 2.0.1
### Additions
- Add [example/example.md](example/example.md) to make the new examples show up on pub.dev. 

## 2.0.0
### API changes
- `SuffixRules` is no longer static.
    - Multiple instances can be created with different rule lists.
    - `DefaultSuffixRules` has been added to provide a statically accessible rules list with a similar API to the old `SuffixRules`.
    - `PublicSuffix` now takes an optional argument when created to specify the `SuffixRules` to use. If unspecified, `DefaultSuffixRules` is used (similar to previous version). 
- Move `SuffixRules.process` and `SuffixRules.validate` to a new class, `SuffixRulesParser`.
- The default constructor in `PublicSuffix` now takes either a String or a URL.
- Add factory methods `PublicSuffix.fromString` and fromUrl with adjustable leniency for invalid URLs ([fixes #4](https://github.com/Komposten/public_suffix/issues/4)).
    - These allow creation of `PublicSuffix` instances without getting exceptions thrown if the URL is null/empty/invalid. See the documentation for full details.
- Rename `PublicSuffix.sourceUri` to `PublicSuffix.sourceUrl`.
- Remove export of `public_suffix.dart` from the helper files.
- Rename `public_suffix_io.dart` and `public_suffix_browser.dart` to `io_helper.dart` and `browser_helper.dart`.

### Additions
- `END PRIVATE` is now respected when loading a suffix list. This means that a list can contain the private section anywhere in the list or even have multiple private sections.
- `SuffixRules.hasRules` - checks if at least one rule exists.
- `SuffixRules.fromRules` - creates a `SuffixRules` instance from an existing list of `Rule` objects.

### Fixes
- Fix rule matching not working for rules with wildcards not in the first position (e.g. `a.*.c`).
- Allow null lists when creating `SuffixRules` objects (treated as empty lists).

## 1.2.1
- Improved the suffix list format documentation in `SuffixRules` and the `SuffixRulesHelper`s.
- Improved documentation of `DomainUtils`.
- Fixed `DomainUtils.isKnownSuffix` not throwing if `SuffixRules` hasn't been initialised.
- Removed the `test_coverage` dev dependency (doesn't work for browser tests).
- Updated README.md to better explain how to initialise `SuffixRules`.

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
