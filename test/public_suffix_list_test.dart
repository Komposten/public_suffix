import 'package:public_suffix/src/public_suffix_list.dart';
import 'package:test/test.dart';

void main() {
  group('process_', () {
    test('comments_remove', () {
      var lines = <String>['//some comment', '//another comment'];

      expect(PublicSuffixList.process(lines), hasLength(0));
    });

    test('emptyLines_remove', () {
      var lines = <String>['', ' ', ' \t \t \t \t '];

      expect(PublicSuffixList.process(lines), hasLength(0));
    });

    test('rules_dontRemove', () {
      var lines = <String>['br', 'nom.br', '*.br', '!br'];

      expect(PublicSuffixList.process(lines), hasLength(4));
    });

    test('mixedCaseRules_changeToLowerCase', () {
      var lines = <String>['bR', 'NOM.br', '*.br', '!BR'];

      expect(PublicSuffixList.process(lines),
          containsAll(['br', 'nom.br', '*.br', '!br']));
    });

    test('rules_removeTextAfterSpace', () {
      var lines = <String>['br', 'nom.br', 'br2 and a comment', '*.br', '!br'];

      expect(PublicSuffixList.process(lines),
          containsAll(['br', 'nom.br', 'br2', '*.br', '!br']));
    });

    test('mixed_removeCommentsEmptyAndTrailingText', () {
      var lines = <String>[
        '//some comment',
        'br',
        '  ',
        'nom.br and more',
      ];
      var processed = PublicSuffixList.process(lines);

      expect(processed, hasLength(2));
      expect(processed, containsAll(['br', 'nom.br']));
    });

    test('mixed_dontAlterInputList', () {
      var lines = <String>[
        '//some comment',
        'br',
        'nom.br',
        '//another comment'
      ];

      PublicSuffixList.process(lines);
      expect(lines, hasLength(4));
    });
  });

  group('validate_', () {
    test('validRules_dontThrow', () {
      var lines = <String>[
        'br',
        '!br',
        '*',
        '!*',
        'mp.br',
        '!mp.br',
        '*.br',
        '!*.br',
        'mp.nom.br',
        '!mp.nom.br',
        '*.nom.br',
        '!*.nom.br',
        '*.*',
        '!*.*',
        '*.nom.*',
        '!*.nom.*'
      ];

      PublicSuffixList.validate(lines);
    });

    test('comments_throw', () {
      expect(() => PublicSuffixList.validate(['br', '//br']),
          throwsFormatException);
    });

    test('emptyLines_throw', () {
      expect(
          () => PublicSuffixList.validate(['br', '']), throwsFormatException);
      expect(
          () => PublicSuffixList.validate(['br', ' ']), throwsFormatException);
      expect(() => PublicSuffixList.validate(['br', ' \t \t \t \t ']),
          throwsFormatException);
    });

    test('rulesWithTrailingText_throw', () {
      expect(() => PublicSuffixList.validate(['br', 'br and more']),
          throwsFormatException);
    });

    test('invalidRules_throw', () {
      expect(() => PublicSuffixList.validate(['.br']), throwsFormatException);
      expect(() => PublicSuffixList.validate(['br.']), throwsFormatException);
      expect(() => PublicSuffixList.validate(['**']), throwsFormatException);
      expect(() => PublicSuffixList.validate(['!!']), throwsFormatException);
      expect(() => PublicSuffixList.validate(['b..r']), throwsFormatException);
    });
  });

  group('hasInitialised_', () {
    tearDown(() => PublicSuffixList.dispose());

    test('initialiseFirst_true', () {
      PublicSuffixList.initFromList(['br']);
      expect(PublicSuffixList.hasInitialised(), isTrue);
    });

    test('uninitialised_false', () {
      expect(PublicSuffixList.hasInitialised(), isFalse);
    });
  });

  test('dispose_initialiseFirst_uninitialise', () {
    PublicSuffixList.initFromList(['br']);
    PublicSuffixList.dispose();
    expect(PublicSuffixList.hasInitialised(), isFalse);
  });

  group('suffixList_', () {
    tearDown(() => PublicSuffixList.dispose());

    test('afterInitialising_returnList', () {
      PublicSuffixList.initFromList(['br', 'nom.br']);
      expect(PublicSuffixList.suffixList, isNotNull);
      expect(PublicSuffixList.suffixList, hasLength(2));
      expect(PublicSuffixList.suffixList, containsAllInOrder(['br', 'nom.br']));
    });

    test('beforeInitialising_returnNull', () {
      expect(PublicSuffixList.suffixList, isNull);
    });

    test('modifyList_exception', () {
      PublicSuffixList.initFromList(['br', 'nom.br']);
      expect(
          () => PublicSuffixList.suffixList.add('!br'), throwsUnsupportedError);
      expect(() => PublicSuffixList.suffixList.removeLast(),
          throwsUnsupportedError);
      expect(
          () => PublicSuffixList.suffixList[0] = '!br', throwsUnsupportedError);
    });
  });

  group('initFromList_', () {
    test('listWithComments_commentsRemoved', () {
      var lines = <String>['br', '//comment', 'nom.br'];

      PublicSuffixList.initFromList(lines);
      expect(PublicSuffixList.suffixList, hasLength(2));
      expect(PublicSuffixList.suffixList, containsAll(['br', 'nom.br']));
    });

    test('listWithEmptyLines_emptyLinesRemoved', () {
      var lines = <String>['br', '', 'nom.br', ' ', ' \t \t \t '];

      PublicSuffixList.initFromList(lines);
      expect(PublicSuffixList.suffixList, hasLength(2));
      expect(PublicSuffixList.suffixList, containsAll(['br', 'nom.br']));
    });

    test('listWithRulesWithTrailingText_trailingTextRemoved', () {
      var lines = <String>['br', 'nom.br and more'];

      PublicSuffixList.initFromList(lines);
      expect(PublicSuffixList.suffixList, hasLength(2));
      expect(PublicSuffixList.suffixList, containsAll(['br', 'nom.br']));
    });

    test('listWithInvalidRules_throw', () {
      expect(
          () => PublicSuffixList.initFromList(['.br']), throwsFormatException);
    });
  });

  test('initFromString_mixedList_success', () {
    var list = 'br\nnom.br\n//comment\n*.com and such\n';

    PublicSuffixList.initFromString(list);
    expect(PublicSuffixList.suffixList, hasLength(3));
    expect(PublicSuffixList.suffixList, containsAll(['br', 'nom.br', '*.com']));
  });
}
