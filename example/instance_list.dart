import 'package:public_suffix/io_helper.dart';
import 'package:public_suffix/public_suffix.dart';

// This is an example that creates an instance of SuffixRules
// directly and uses that instead of DefaultSuffixRules.
Future<void> main() async {
  // Create a SuffixRules instance from a list of suffix rules from
  // publicsuffix.org.
  var suffixRules = await SuffixRulesHelper.createListFromUri(
      Uri.parse('https://publicsuffix.org/list/public_suffix_list.dat'));

  // Parse a URL.
  // Specify a rule list to use that instead of DefaultSuffixRules.
  var parsedUrl = PublicSuffix(urlString: 'https://www.komposten.github.io',
      suffixRules: suffixRules);

  // Results when matching against both ICANN/IANA and private suffixes.
  print(parsedUrl.suffix); // github.io
  print(parsedUrl.root); // komposten
  print(parsedUrl.domain); // komposten.github.io

  // Results when matching against only ICANN/IANA suffixes.
  print(parsedUrl.icannSuffix); // io
  print(parsedUrl.icannRoot); // github
  print(parsedUrl.icannDomain); // github.io

  // Punycode decoded results.
  parsedUrl = PublicSuffix(urlString: 'https://www.xn--6qq79v.cn',
      suffixRules: suffixRules);
  print(parsedUrl.domain); // xn--6qq79v.cn
  print(parsedUrl.punyDecoded.domain); // 你好.cn
}
