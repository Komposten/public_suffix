@TestOn("browser")
import 'package:public_suffix/public_suffix_browser.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() => SuffixRules.dispose());

  test('initPublicSuffixList_crossDomainUrl_initList', () async {
    await SuffixRulesHelper.initFromUri(Uri.parse(
        'https://raw.githubusercontent.com/Komposten/public_suffix/master/test/res/public_suffix_list.dat'));
    expect(SuffixRules.hasInitialised(), isTrue);
    expect(SuffixRules.rules, isNotEmpty);
  });

  test('initPublicSuffixList_fileAccessDenied_fail', () async {
    var file = Uri.file("/public_suffix_list.dat");

    expect(SuffixRulesHelper.initFromUri(file), throwsException);
  });

  test('initPublicSuffixList_invalidUrl_throwException', () async {
    expect(SuffixRulesHelper.initFromUri(Uri.parse('127.0.0.2/list.dat')),
        throwsException);
    expect(SuffixRules.hasInitialised(), isFalse);
  });
}
