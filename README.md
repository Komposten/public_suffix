# public_suffix
[![pub package](https://img.shields.io/pub/v/public_suffix.svg)](https://pub.dev/packages/public_suffix)
[![Dart CI](https://github.com/Komposten/public_suffix/actions/workflows/dart.yaml/badge.svg)](https://github.com/Komposten/public_suffix/actions/workflows/dart.yaml)
[![codecov](https://codecov.io/gh/Komposten/public_suffix/branch/master/graph/badge.svg)](https://codecov.io/gh/Komposten/public_suffix)

**A domain parser based on the [Public Suffix List](https://publicsuffix.org/)**

public_suffix is a dart library for identifying the public suffixes (or TLDs), root domains and registrable parts of URLs.

## Main features
- Identify suffix, root domain, registrable domain (root + suffix) and subdomain from URLs.
- Provide your own list of suffix rules to keep up to date with the rules you need.
- Get results from matching with only ICANN/IANA rules or also include private ones.
    - For example, a private rule can see the full `github.io` as suffix while ICANN only recognises the `io` part.
- Parse punycode encoded URLs and get both encoded and decoded results.
- Check if URLs are subdomains, have valid domain parts, or end with known suffixes.

## Usage
### Option 1 - Using a statically accessible list
1) Import `public_suffix.dart`.
2) [Initialise `DefaultSuffixRules`](#initialising-defaultsuffixrules) from a suffix rule list.
3) Create instances of `PublicSuffix` to parse URLs.
4) Access the different URL components through the `PublicSuffix` objects.

### Option 2 - Using a non-static list
1) Import `public_suffix.dart`.
2) [Create a `SuffixRules` instance](#creating-suffixrules-instances) from a suffix rule list.
3) Create instances of `PublicSuffix` to parse URLs, passing in the `SuffixRules` instance from step 2.
4) Access the different URL components through the `PublicSuffix` objects.

### Short example using the static list
```dart
import 'package:public_suffix/public_suffix.dart';

main() {
  // Load a list of suffix rules.
  var suffixListString = 'load the list into this string';
  DefaultSuffixRules.initFromString(suffixListString);
  
  // Parse a URL.
  var parsedUrl = PublicSuffix(urlString: 'https://www.komposten.github.io');
  
  // Obtain information using the many getters, for example:
  print(parsedUrl.suffix);      // github.io
  print(parsedUrl.root);        // komposten
  print(parsedUrl.domain);      // komposten.github.io
  print(parsedUrl.icannDomain); // github.io

  // public_suffix also supports punycoded URLs:
  parsedUrl = PublicSuffix(urlString: 'https://www.xn--6qq79v.cn');
  print(parsedUrl.domain);             // xn--6qq79v.cn
  print(parsedUrl.punyDecoded.domain); // 你好.cn
}
```

## Obtaining a suffix list
public_suffix requires a list of suffix rules to work. There is no list bundled by default as these lists are updated frequently.

To use public_suffix you need to first load a list of rules, and then either initialise `DefaultSuffixRules` (for static access) or create
your own instance of `SuffixRules`.

### Initialising DefaultSuffixRules
The easiest way to use public_suffix is to get a list of rules and pass that list to `DefaultSuffixRules`. The `PublicSuffix` class will use this
list by default.

There are two ways of initialising it:
1) Load the list using your own code and pass it to `DefaultSuffixRules.initFromString()`:
   ```dart
   //Example using Flutter
   import 'package:flutter/services.dart';
   import 'package:public_suffix/public_suffix.dart';
   
   main() {
       var suffixList = rootBundle.loadString('assets/public_suffix_list.dat');
       DefaultSuffixRules.initFromString(suffixList);
   }
   ```
2) Import either the `dart:io` or the `dart:html`-based helper and load the list from a URI:
   ```dart
   //Example using dart:io; for dart:html use browser_helper.dart instead.
   import 'package:public_suffix/io_helper.dart';
   
   main() async {
     var listUri = Uri.parse('https://publicsuffix.org/list/public_suffix_list.dat');
     await SuffixRulesHelper.initDefaultListFromUri(listUri);
   }
   ```

### Creating SuffixRules instances
An alternative way to use public_suffix is to manually create an instance of `SuffixRules` and then pass that in when creating `PublicSuffix` objects.

Just like before, there are two ways of doing this:
1) Load the list using your own code and pass it to one of `SuffixRules` constructors:
   ```dart
   //Example using Flutter
   import 'package:flutter/services.dart';
   import 'package:public_suffix/public_suffix.dart';
   
   main() {
       var suffixList = rootBundle.loadString('assets/public_suffix_list.dat');
       var suffixRules = SuffixRules.fromString(suffixList);
   }
   ```
2) Import either the `dart:io` or the `dart:html`-based helper and load the list from a URI:
   ```dart
   //Example using dart:io; for dart:html use browser_helper.dart instead.
   import 'package:public_suffix/io_helper.dart';
   
   main() async {
     var uri = Uri.parse('https://publicsuffix.org/list/public_suffix_list.dat');
     var suffixRules = await SuffixRulesHelper.createListFromUri(listUri);
   }
   ```

**Note:** Don't overload publicsuffix.org's servers by repeatedly retrieving the suffix list from them. Cache a copy somewhere instead, and update that copy when the master copy is updated.

## Utility functions
Several utility functions can be found in the `DomainUtils` class (imported from `public_suffix.dart`). These currently include:
- `isSubdomainOf`: Checks if a given URL is a subdomain of another domain.
- `isSubdomain`: Checks if a given URL has a subdomain part.
- `isKnownSuffix`: Checks if a given suffix (e.g. `co.uk`) is listed in the suffix rule list.
- `hasValidDomain`: Checks if a given URL contains a registrable domain part.

Most of these create PublicSuffix objects internally. If you are already working with PublicSuffix objects, there are similar methods you can call directly on those to avoid creating new ones.

## Contributing
### Git message conventions
public_suffix uses [gitmoji](https://gitmoji.carloscuesta.me) to indicate commit types (bug fix, new feature, re-factor, etc.)

Commit messages should generally follow this format:
```
:emoji: Write a short summary on line one

Put additional information two lines down.
Use imperative forms of verbs. For example "Add", "Fix" and "Move" instead of "Added", "Fixed" and "Moved".
```

## License
public_suffix is licensed under the MIT license. See [LICENSE](https://github.com/Komposten/public_suffix/blob/master/LICENSE) for the full license text.
