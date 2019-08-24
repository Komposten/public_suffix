# public_suffix
[![Build Status](https://travis-ci.com/Komposten/public_suffix.svg?branch=master)](https://travis-ci.com/Komposten/public_suffix)

**A domain parser based on the [Public Suffix List](https://publicsuffix.org/)**

public_suffix is a dart library for identifying the public suffixes (or TLDs), root domains and registrable parts of URLs.

## Usage
1) Import `public_suffix_io.dart` or `public_suffix_browser.dart`.
2) Initialise `SuffixRules` from a file/uri containing suffix rules.
3) Create a new instance of `PublicSuffix` to parse a URL.
4) Access the different components through the `PublicSuffix` object.

**Note:** Don't overload publicsuffix.org's servers by repeatedly retrieving the suffix list from them. Cache a copy somewhere instead, and update that copy only when the master copy is updated.

```dart
import 'package:public_suffix/public_suffix_io.dart';

main(List<String> arguments) async {
  await SuffixRulesHelper.initFromUri(
      Uri.parse("https://publicsuffix.org/list/public_suffix_list.dat"));
  PublicSuffix suffix =
      PublicSuffix(Uri.parse("https://www.komposten.github.io"));

  //Results when matching against ICANN/IANA and private suffixes.
  print(suffix.suffix); // "github.io"
  print(suffix.root); // "komposten"
  print(suffix.domain); // "komposten.github.io"

  //Results when matching against only ICANN/IANA suffixes.
  print(suffix.icannSuffix); // "io"
  print(suffix.icannRoot); // "github"
  print(suffix.icannDomain); // "github.io"

  //punycode decoded results.
  suffix = PublicSuffix(Uri.parse("https://www.xn--6qq79v.cn"));
  print(suffix.domain); // "xn--6qq79v.cn"
  print(suffix.punyDecoded.domain); // "你好.cn"
}
```

## License
public_suffix is licensed under the MIT license. See [LICENSE](https://github.com/Komposten/public_suffix/blob/master/LICENSE) for the full license text.
