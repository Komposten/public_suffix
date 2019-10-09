import 'package:public_suffix/public_suffix.dart';
import 'package:public_suffix/public_suffix_io.dart';

Future<void> main() async {
  // Load a list of suffix rules from publicsuffix.org.
  await SuffixRulesHelper.initFromUri(
      Uri.parse('https://publicsuffix.org/list/public_suffix_list.dat'));

  // Parse a URL.
  PublicSuffix parsedUrl =
      PublicSuffix.fromString('https://www.komposten.github.io');

  // Results when matching against both ICANN/IANA and private suffixes.
  print(parsedUrl.suffix); // github.io
  print(parsedUrl.root); // komposten
  print(parsedUrl.domain); // komposten.github.io

  // Results when matching against only ICANN/IANA suffixes.
  print(parsedUrl.icannSuffix); // io
  print(parsedUrl.icannRoot); // github
  print(parsedUrl.icannDomain); // github.io

  // Punycode decoded results.
  parsedUrl = PublicSuffix.fromString('https://www.xn--6qq79v.cn');
  print(parsedUrl.domain); // xn--6qq79v.cn
  print(parsedUrl.punyDecoded.domain); // 你好.cn

  // Dispose the list to unload it from memory if you wish.
  // This is probably not needed since the list is relatively small.
  SuffixRules.dispose();
}
