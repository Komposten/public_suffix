# public_suffix
[![pub package](https://img.shields.io/pub/v/public_suffix.svg)](https://pub.dev/packages/public_suffix)
[![Build Status](https://travis-ci.com/Komposten/public_suffix.svg?branch=master)](https://travis-ci.com/Komposten/public_suffix)

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
1) Import `public_suffix.dart`.
2) [Initialise `SuffixRules`](#initialising-suffixrules) from a suffix rule list.
3) Create instances of `PublicSuffix` to parse URLs.
4) Access the different URL components through the `PublicSuffix` objects.

### Short example
```dart
import 'package:public_suffix/public_suffix.dart';

main() {
  // Load a list of suffix rules from publicsuffix.org.
  String suffixListString = 'load the list into this string';
  SuffixRules.initFromString(suffixListString);
	  
  // Parse a URL.
  PublicSuffix parsedUrl =
      PublicSuffix.fromString('https://www.komposten.github.io');
	  
  // Obtain information using the many getters, for example:
  print(parsedUrl.suffix);      // github.io
  print(parsedUrl.root);        // komposten
  print(parsedUrl.domain);      // komposten.github.io
  print(parsedUrl.icannDomain); // github.io

  // public_suffix also supports punycoded URLs:
  parsedUrl = PublicSuffix.fromString('https://www.xn--6qq79v.cn');
  print(parsedUrl.domain);             // xn--6qq79v.cn
  print(parsedUrl.punyDecoded.domain); // 你好.cn
}
```

### Initialising SuffixRules
public_suffix requires a list of suffix rules to work. There is no list bundled by default as these lists are updated frequently.
Instead you'll have to load a list on your own and pass that list to `SuffixRules`. There are two ways of doing this:
1) Load the list using your own code and pass it to `SuffixRules.initFromString()`:
   ```dart
   //Example using Flutter
   import 'package:flutter/services.dart';
   import 'package:public_suffix/public_suffix.dart';
   
   main() {
       var suffixList = rootBundle.loadString('assets/public_suffix_list.dat');
       SuffixRules.initFromString(suffixList);
   }
   ```
2) Import either the `dart:io` or the `dart:html`-based helper and load the list from a URI:
   ```dart
   //Example using dart:io; for dart:html use public_suffix_browser.dart instead.
   import 'package:public_suffix/public_suffix_io.dart';
   
   main() async {
     Uri uri = Uri.parse('https://publicsuffix.org/list/public_suffix_list.dat');
     await SuffixRulesHelper.initFromUri(listUri);
   }
   ```

**Note:** Don't overload publicsuffix.org's servers by repeatedly retrieving the suffix list from them. Cache a copy somewhere instead, and update that copy only when the master copy is updated.

## Utility functions
Several utility functions can be found in the `DomainUtils` class (imported from `public_suffix.dart`). These currently include:
- `isSubdomainOf`: Checks if a given URL is a subdomain of another domain.
- `isSubdomain`: Checks if a given URL has a subdomain part.
- `isKnownSuffix`: Checks if a given suffix (e.g. `co.uk`) is listed in the suffix rule list.
- `hasValidDomain`: Checks if a given URL contains a registrable domain part.

Most of these create PublicSuffix objects internally. If you are already working with PublicSuffix objects, there are similar methods you can call directly on those to avoid creating new ones.

## License
public_suffix is licensed under the MIT license. See [LICENSE](https://github.com/Komposten/public_suffix/blob/master/LICENSE) for the full license text.
