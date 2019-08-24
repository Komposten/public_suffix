# public_suffix
**A domain parser based on the [Public Suffix List](https://publicsuffix.org/)**

public_suffix identifies the public suffixes, root domains and registrable parts of URLs.

## Usage
1) Import `public_suffix_io.dart` or `public_suffix_browser.dart`.
2) Initialise `SuffixRules` from a file/uri containing suffix rules.
3) Create a new instance of `PublicSuffix` to parse a URL.

```dart
import 'public_suffix_io.dart';

main() {
  SuffixRulesHelper.initFromUri(Uri.parse("https://publicsuffix.org/list/public_suffix_list.dat"));
  PublicSuffix suffix = PublicSuffix(Uri.parse("https://www.publicsuffix.org"));
  
  print(suffix.publicTld); // "org"
  print(suffix.rootDomain); // "publicsuffix"
  print(suffix.registrableDomain); // "publicsuffix.org"
}
```

## License
public_suffix is licensed under the MIT license. See [LICENSE](LICENSE) for the full license text.