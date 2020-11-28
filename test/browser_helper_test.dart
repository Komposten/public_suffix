@TestOn("browser")
import 'package:public_suffix/public_suffix.dart';
import 'package:public_suffix/browser_helper.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() => DefaultSuffixRules.dispose());

  group('initDefaultListFromUri_', () {
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

    test('fileAccessDenied_fail', () async {
      var file = Uri.file("/public_suffix_list.dat");

      expect(SuffixRulesHelper.initDefaultListFromUri(file), throwsException);
    });

    test('invalidUrl_throwException', () async {
      expect(SuffixRulesHelper.initDefaultListFromUri(Uri.parse('127.0.0.2/list.dat')),
          throwsException);
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

    test('fileAccessDenied_fail', () async {
      var file = Uri.file("/public_suffix_list.dat");
      expect(SuffixRulesHelper.createListFromUri(file), throwsException);
    });

    test('invalidUrl_throwException', () async {
      expect(SuffixRulesHelper.createListFromUri(Uri.parse('127.0.0.2/list.dat')),
          throwsException);
    });
  });
}
