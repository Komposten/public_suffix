@TestOn("vm")
import 'package:test/test.dart';
import 'package:public_suffix/public_suffix.dart';
import 'package:public_suffix/io_helper.dart';
import 'io_test_utils.dart';

void main() {
  tearDown(() => DefaultSuffixRules.dispose());

  group('initDefaultListFromUri', () {
    test('crossDomainUrl_initList', () async {
      await SuffixRulesHelper.initDefaultListFromUri(Uri.parse(
          'https://raw.githubusercontent.com/Komposten/public_suffix/master/test/res/public_suffix_list.dat'));
      expect(DefaultSuffixRules.hasInitialised(), isTrue);
      expect(DefaultSuffixRules.rules.rules, isNotEmpty);
    });

    test('resourceDoesNotExist_fail', () async {
      var uri = Uri.parse(
          "https://raw.githubusercontent.com/Komposten/public_suffix/master/test/res/i_dont_exist.dat");
      expect(SuffixRulesHelper.initDefaultListFromUri(uri), throwsException);
    });

    test('invalidUrl_throwException', () async {
      expect(
          SuffixRulesHelper.initDefaultListFromUri(Uri.parse('http://127.0.0.2/list.dat')),
          throwsException);
    });

    test('validFileUri_initList', () async {
      await SuffixRulesHelper.initDefaultListFromUri(getSuffixListFileUri());
      expect(DefaultSuffixRules.hasInitialised(), isTrue);
      expect(DefaultSuffixRules.rules.rules, isNotEmpty);
    });
  });

  group('createListFromUri', () {
    test('crossDomainUrl_initList', () async {
      var rules = await SuffixRulesHelper.createListFromUri(Uri.parse(
          'https://raw.githubusercontent.com/Komposten/public_suffix/master/test/res/public_suffix_list.dat'));
      expect(rules.rules, isNotEmpty);
    });

    test('resourceDoesNotExist_fail', () async {
      var uri = Uri.parse(
          "https://raw.githubusercontent.com/Komposten/public_suffix/master/test/res/i_dont_exist.dat");
      expect(SuffixRulesHelper.createListFromUri(uri), throwsException);
    });

    test('invalidUrl_throwException', () async {
      expect(
          SuffixRulesHelper.createListFromUri(Uri.parse('http://127.0.0.2/list.dat')),
          throwsException);
    });

    test('validFileUri_initList', () async {
      var rules = await SuffixRulesHelper.createListFromUri(getSuffixListFileUri());
      expect(rules.rules, isNotEmpty);
    });
  });
}
