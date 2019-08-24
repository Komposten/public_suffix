import 'package:public_suffix/src/suffix_rules.dart';
import 'package:test/test.dart';

void main() {
  group('process_', () {
    test('comments_remove', () {
      var lines = <String>['//some comment', '//another comment'];

      expect(SuffixRules.process(lines), hasLength(0));
    });

    test('emptyLines_remove', () {
      var lines = <String>['', ' ', ' \t \t \t \t '];

      expect(SuffixRules.process(lines), hasLength(0));
    });

    test('rules_dontRemove', () {
      var lines = <String>['br', 'nom.br', '*.br', '!br'];

      expect(SuffixRules.process(lines), hasLength(4));
    });

    test('mixedCaseRules_changeToLowerCase', () {
      var lines = <String>['bR', 'NOM.br', '*.br', '!BR'];

      expect(SuffixRules.process(lines),
          containsAll(['br', 'nom.br', '*.br', '!br']));
    });

    test('rules_removeTextAfterSpace', () {
      var lines = <String>['br', 'nom.br', 'br2 and a comment', '*.br', '!br'];

      expect(SuffixRules.process(lines),
          containsAll(['br', 'nom.br', 'br2', '*.br', '!br']));
    });

    test('mixed_removeCommentsEmptyAndTrailingText', () {
      var lines = <String>[
        '//some comment',
        'br',
        '  ',
        'nom.br and more',
      ];
      var processed = SuffixRules.process(lines);

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

      SuffixRules.process(lines);
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

      SuffixRules.validate(lines);
    });

    test('comments_throw', () {
      expect(() => SuffixRules.validate(['br', '//br']),
          throwsFormatException);
    });

    test('emptyLines_throw', () {
      expect(
          () => SuffixRules.validate(['br', '']), throwsFormatException);
      expect(
          () => SuffixRules.validate(['br', ' ']), throwsFormatException);
      expect(() => SuffixRules.validate(['br', ' \t \t \t \t ']),
          throwsFormatException);
    });

    test('rulesWithTrailingText_throw', () {
      expect(() => SuffixRules.validate(['br', 'br and more']),
          throwsFormatException);
    });

    test('invalidRules_throw', () {
      expect(() => SuffixRules.validate(['.br']), throwsFormatException);
      expect(() => SuffixRules.validate(['br.']), throwsFormatException);
      expect(() => SuffixRules.validate(['**']), throwsFormatException);
      expect(() => SuffixRules.validate(['!!']), throwsFormatException);
      expect(() => SuffixRules.validate(['b..r']), throwsFormatException);
    });
  });

  group('hasInitialised_', () {
    tearDown(() => SuffixRules.dispose());

    test('initialiseFirst_true', () {
      SuffixRules.initFromList(['br']);
      expect(SuffixRules.hasInitialised(), isTrue);
    });

    test('uninitialised_false', () {
      expect(SuffixRules.hasInitialised(), isFalse);
    });
  });

  test('dispose_initialiseFirst_uninitialise', () {
    SuffixRules.initFromList(['br']);
    SuffixRules.dispose();
    expect(SuffixRules.hasInitialised(), isFalse);
  });

  group('suffixList_', () {
    tearDown(() => SuffixRules.dispose());

    test('afterInitialising_returnList', () {
      SuffixRules.initFromList(['br', 'nom.br']);
      expect(SuffixRules.rules, isNotNull);
      expect(SuffixRules.rules, hasLength(2));
      expect(SuffixRules.rules, containsAllInOrder(['br', 'nom.br']));
    });

    test('beforeInitialising_returnNull', () {
      expect(SuffixRules.rules, isNull);
    });

    test('modifyList_exception', () {
      SuffixRules.initFromList(['br', 'nom.br']);
      expect(
          () => SuffixRules.rules.add('!br'), throwsUnsupportedError);
      expect(() => SuffixRules.rules.removeLast(),
          throwsUnsupportedError);
      expect(
          () => SuffixRules.rules[0] = '!br', throwsUnsupportedError);
    });
  });

  group('initFromList_', () {
    test('listWithComments_commentsRemoved', () {
      var lines = <String>['br', '//comment', 'nom.br'];

      SuffixRules.initFromList(lines);
      expect(SuffixRules.rules, hasLength(2));
      expect(SuffixRules.rules, containsAll(['br', 'nom.br']));
    });

    test('listWithEmptyLines_emptyLinesRemoved', () {
      var lines = <String>['br', '', 'nom.br', ' ', ' \t \t \t '];

      SuffixRules.initFromList(lines);
      expect(SuffixRules.rules, hasLength(2));
      expect(SuffixRules.rules, containsAll(['br', 'nom.br']));
    });

    test('listWithRulesWithTrailingText_trailingTextRemoved', () {
      var lines = <String>['br', 'nom.br and more'];

      SuffixRules.initFromList(lines);
      expect(SuffixRules.rules, hasLength(2));
      expect(SuffixRules.rules, containsAll(['br', 'nom.br']));
    });

    test('listWithInvalidRules_throw', () {
      expect(
          () => SuffixRules.initFromList(['.br']), throwsFormatException);
    });
  });

  test('initFromString_mixedList_success', () {
    var list = 'br\nnom.br\n//comment\n*.com and such\n';

    SuffixRules.initFromString(list);
    expect(SuffixRules.rules, hasLength(3));
    expect(SuffixRules.rules, containsAll(['br', 'nom.br', '*.com']));
  });
}
