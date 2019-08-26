@TestOn("vm")
import 'package:test/test.dart';
import 'package:public_suffix/public_suffix_io.dart';
import 'io_test_utils.dart';

void main() {
  tearDown(() => SuffixRules.dispose());

  test('initPublicSuffixList_crossDomainUrl_initList', () async {
    await SuffixRulesHelper.initFromUri(Uri.parse(
        'https://raw.githubusercontent.com/Komposten/public_suffix/master/test/res/public_suffix_list.dat'));
    expect(SuffixRules.hasInitialised(), isTrue);
    expect(SuffixRules.rules, isNotEmpty);
  });

  test('initPublicSuffixList_invalidUrl_throwException', () async {
    expect(
        SuffixRulesHelper.initFromUri(Uri.parse('http://127.0.0.2/list.dat')),
        throwsException);
    expect(SuffixRules.hasInitialised(), isFalse);
  });

  test('initPublicSuffixList_validFileUri_initList', () async {
    await SuffixRulesHelper.initFromUri(getSuffixListFileUri());
    expect(SuffixRules.hasInitialised(), isTrue);
    expect(SuffixRules.rules, isNotEmpty);
  });
}
