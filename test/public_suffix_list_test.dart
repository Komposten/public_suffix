import 'package:public_suffix/src/public_suffix_list.dart';
import 'package:test/test.dart';

void main() {
  group('validate_', () {
    test('validRules_dontThrow', () {
      var lines = <String>[
        "br",
        "!br",
        "*",
        "!*",
        "mp.br",
        "!mp.br",
        "*.br",
        "!*.br",
        "mp.nom.br",
        "!mp.nom.br",
        "*.nom.br",
        "!*.nom.br",
        "*.*",
        "!*.*",
        "*.nom.*",
        "!*.nom.*",
        "br and a comment",
        "br and a co**ent"
      ];

      PublicSuffixList.validate(lines);
    });

    test('commentsAndEmptyLines_dontThrow', () {
      var lines = <String>[
        "//br",
        "//**",
        "//.**",
        "//!!.**",
        "",
        " ",
        " \t \t \t \t ",
      ];

      PublicSuffixList.validate(lines);
    });

    test('invalidRules_throw', () {
      expect(() => PublicSuffixList.validate([".br"]), throwsFormatException);
      expect(() => PublicSuffixList.validate(["br."]), throwsFormatException);
      expect(() => PublicSuffixList.validate(["**"]), throwsFormatException);
      expect(() => PublicSuffixList.validate(["!!"]), throwsFormatException);
      expect(() => PublicSuffixList.validate(["b..r"]), throwsFormatException);
    });
  });

  group('hasInitialised_', ()
  {
    tearDown(() => PublicSuffixList.dispose());

    test('initialiseFirst_true', () {
      PublicSuffixList.initFromList(["br"]);
      expect(PublicSuffixList.hasInitialised(), isTrue);
    });

    test('uninitialised_false', () {
      expect(PublicSuffixList.hasInitialised(), isFalse);
    });
  });

  test('dispose_initialiseFirst_uninitialise', () {
    PublicSuffixList.initFromList(["br"]);
    PublicSuffixList.dispose();
    expect(PublicSuffixList.hasInitialised(), isFalse);
  });

  group('suffixList_', () {
    tearDown(() => PublicSuffixList.dispose());

    test('afterInitialising_returnList', () {
      PublicSuffixList.initFromList(["br", "nom.br"]);
      expect(PublicSuffixList.suffixList, isNotNull);
      expect(PublicSuffixList.suffixList, hasLength(2));
      expect(PublicSuffixList.suffixList, containsAllInOrder(["br", "nom.br"]));
    });

    test('beforeInitialising_returnNull', () {
      expect(PublicSuffixList.suffixList, isNull);
    });

    test('modifyList_exception', () {
      PublicSuffixList.initFromList(["br", "nom.br"]);
      expect(() => PublicSuffixList.suffixList.add("!br"), throwsUnsupportedError);
      expect(() => PublicSuffixList.suffixList.removeLast(), throwsUnsupportedError);
      expect(() => PublicSuffixList.suffixList[0] = "!br", throwsUnsupportedError);
    });
  });
}
