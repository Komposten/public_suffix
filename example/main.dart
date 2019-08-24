import 'package:public_suffix/public_suffix_io.dart';

main(List<String> arguments) async {
  // Load a list of suffix rules from publicsuffix.org.
  await SuffixRulesHelper.initFromUri(
      Uri.parse("https://publicsuffix.org/list/public_suffix_list.dat"));

  // Parse a URL.
  PublicSuffix suffix =
      PublicSuffix(Uri.parse("https://www.komposten.github.io"));

  // Results when matching against ICANN/IANA and private suffixes.
  print(suffix.suffix); // "github.io"
  print(suffix.root); // "komposten"
  print(suffix.domain); // "komposten.github.io"

  // Results when matching against only ICANN/IANA suffixes.
  print(suffix.icannSuffix); // "io"
  print(suffix.icannRoot); // "github"
  print(suffix.icannDomain); // "github.io"

  // punycode decoded results.
  suffix = PublicSuffix(Uri.parse("https://www.xn--6qq79v.cn"));
  print(suffix.domain); // "xn--6qq79v.cn"
  print(suffix.punyDecoded.domain); // "你好.cn"

  // Dispose the list to unload it from memory if you wish.
  // This is probably not needed since the list is relatively small.
  SuffixRules.dispose();
}
