#public_suffix
**A library for getting the public suffix of a URL**

public_suffix finds the public suffix (as defined in the [Public Suffix List](https://publicsuffix.org/)) of URLs.

## Usage
1) Import `public_suffix_io.dart` or `public_suffix_html.dart` (for web apps).
2) Initialise the Public Suffix List.
3) Create a new instance of `PublicSuffix()` based on a URL.

```dart
import 'public_suffix_io.dart';

main() {
  PublicSuffixList.initFromUri(Uri.parse("https://publicsuffix.org/list/public_suffix_list.dat"));
  PublicSuffix suffix = getPublicSuffix(Uri.parse("https://publicsuffix.org"));
  
  print(suffix.suffix); // "org"
  print(suffix.rootDomain); // "publicsuffix"
}
```

## License
public_suffix is licensed under the MIT license. See [LICENSE](LICENSE) for the full license text.