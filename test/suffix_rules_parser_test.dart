import 'package:public_suffix/public_suffix.dart';
import 'package:test/test.dart';

void main() {
  var parser;

  setUp(() {
    parser = SuffixRulesParser();
  });

  group('process_', () {
    test('comments_remove', () {
      var lines = <String>['//some comment', '//another comment'];

      expect(parser.process(lines), hasLength(0));
    });

    test('emptyLines_remove', () {
      var lines = <String>['', ' ', ' \t \t \t \t '];

      expect(parser.process(lines), hasLength(0));
    });

    test('rules_dontRemove', () {
      var lines = <String>['br', 'nom.br', '*.br', '!br'];

      expect(parser.process(lines), hasLength(4));
    });

    test('mixedCaseRules_changeToLowerCase', () {
      var lines = <String>['bR', 'NOM.br', '*.br', '!BR'];

      expect(parser.process(lines),
          containsAll([Rule('br'), Rule('nom.br'), Rule('*.br'), Rule('!br')]));
    });

    test('rules_removeTextAfterSpace', () {
      var lines = <String>['br', 'nom.br', 'br2 and a comment', '*.br', '!br'];

      expect(
          parser.process(lines),
          containsAll([
            Rule('br'),
            Rule('nom.br'),
            Rule('br2'),
            Rule('*.br'),
            Rule('!br')
          ]));
    });

    test('mixed_removeCommentsEmptyAndTrailingText', () {
      var lines = <String>[
        '//some comment',
        'br',
        '  ',
        'nom.br and more',
      ];
      var processed = parser.process(lines);

      expect(processed, hasLength(2));
      expect(processed, containsAll([Rule('br'), Rule('nom.br')]));
    });

    test('mixed_dontAlterInputList', () {
      var lines = <String>[
        '//some comment',
        'br',
        'nom.br',
        '//another comment'
      ];

      parser.process(lines);
      expect(lines, hasLength(4));
    });

    test('withPrivateBlock_markPrivateAsNotIcann', () {
      var lines = <String>['br', 'nom.br', '//BEGIN PRIVATE', 'pr', 'nom.pr'];

      var processed = parser.process(lines);
      expect(processed, hasLength(4));
      expect(
          processed,
          containsAll([
            Rule('br'),
            Rule('nom.br'),
            Rule('pr', isIcann: false),
            Rule('nom.pr', isIcann: false)
          ]));
    });

    test('withPrivateBlock_respectBlockEndComment', () {
      var lines = <String>[
        'br',
        '//BEGIN PRIVATE',
        'nom.br',
        '//END PRIVATE',
        'pr',
        'nom.pr'
      ];

      var processed = parser.process(lines);
      expect(processed, hasLength(4));
      expect(
          processed,
          containsAll([
            Rule('br'),
            Rule('nom.br', isIcann: false),
            Rule('pr'),
            Rule('nom.pr')
          ]));
    });
  });

  group('validate_', () {
    test('validRules_dontThrow', () {
      var lines = <Rule>[
        Rule('br'),
        Rule('!br'),
        Rule('*'),
        Rule('!*'),
        Rule('mp.br'),
        Rule('!mp.br'),
        Rule('*.br'),
        Rule('!*.br'),
        Rule('mp.nom.br'),
        Rule('!mp.nom.br'),
        Rule('*.nom.br'),
        Rule('!*.nom.br'),
        Rule('*.*'),
        Rule('!*.*'),
        Rule('*.nom.*'),
        Rule('!*.nom.*')
      ];

      parser.validate(lines);
    });

    test('comments_throw', () {
      expect(() => parser.validate([Rule('br'), Rule('//br')]),
          throwsFormatException);
    });

    test('emptyLines_throw', () {
      expect(
          () => parser.validate([Rule('br'), Rule('')]), throwsFormatException);
      expect(() => parser.validate([Rule('br'), Rule(' ')]),
          throwsFormatException);
      expect(() => parser.validate([Rule('br'), Rule(' \t \t \t \t ')]),
          throwsFormatException);
    });

    test('rulesWithTrailingText_throw', () {
      expect(() => parser.validate([Rule('br'), Rule('br and more')]),
          throwsFormatException);
    });

    test('invalidRules_throw', () {
      expect(() => parser.validate([Rule('.br')]), throwsFormatException);
      expect(() => parser.validate([Rule('br.')]), throwsFormatException);
      expect(() => parser.validate([Rule('**')]), throwsFormatException);
      expect(() => parser.validate([Rule('!!')]), throwsFormatException);
      expect(() => parser.validate([Rule('b..r')]), throwsFormatException);
    });
  });
}
