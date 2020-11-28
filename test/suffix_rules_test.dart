import 'package:public_suffix/src/suffix_rules.dart';
import 'package:test/test.dart';

void main() {
  group('suffixList_', () {
    test('modifyList_throwsException', () {
      var rules = SuffixRules.fromList(['br', 'nom.br']);
      expect(() => rules.rules.add(Rule('!br')), throwsUnsupportedError);
      expect(() => rules.rules.removeLast(), throwsUnsupportedError);
      expect(() => rules.rules[0] = Rule('!br'), throwsUnsupportedError);
    });
  });

  group('ruleMap_', () {
    test('_initialisedProperly', () {
      var rules = SuffixRules.fromList(['br', 'br.nom']);
      expect(rules.ruleMap, isNotNull);
      expect(rules.ruleMap, hasLength(2));
      expect(rules.ruleMap, containsPair('br', [Rule('br')]));
    });

    test('multipleRulesFromSameTld_combinedIntoSameList', () {
      var rules = SuffixRules.fromList(['br', 'nom.br', 'nom.mer.br']);
      expect(rules.ruleMap, isNotNull);
      expect(rules.ruleMap, hasLength(1));
      expect(rules.ruleMap,
          containsPair('br', [Rule('br'), Rule('nom.br'), Rule('nom.mer.br')]));
    });

    test('modifyMap_throwsException', () {
      var rules = SuffixRules.fromList(['br', 'nom.br']);
      expect(() => rules.ruleMap['rb'] = [Rule('rb')],
          throwsUnsupportedError);
      expect(() => rules.ruleMap.remove('br'), throwsUnsupportedError);
    });
  });

  group('initFromList_', () {
    test('listWithComments_commentsRemoved', () {
      var lines = <String>['br', '//comment', 'nom.br'];
      var rules = SuffixRules.fromList(lines);

      expect(rules.rules, hasLength(2));
      expect(rules.rules, containsAll([Rule('br'), Rule('nom.br')]));
    });

    test('listWithEmptyLines_emptyLinesRemoved', () {
      var lines = <String>['br', '', 'nom.br', ' ', ' \t \t \t '];
      var rules = SuffixRules.fromList(lines);

      expect(rules.rules, hasLength(2));
      expect(rules.rules, containsAll([Rule('br'), Rule('nom.br')]));
    });

    test('listWithRulesWithTrailingText_trailingTextRemoved', () {
      var lines = <String>['br', 'nom.br and more'];
      var rules = SuffixRules.fromList(lines);

      expect(rules.rules, hasLength(2));
      expect(rules.rules, containsAll([Rule('br'), Rule('nom.br')]));
    });

    test('listWithInvalidRules_throws', () {
      expect(() => SuffixRules.fromList(['.br']), throwsFormatException);
    });
  });

  test('fromString_mixedList_success', () {
    var list = 'br\nnom.br\n//comment\n*.com and such\n';
    var rules = SuffixRules.fromString(list);

    expect(rules.rules, hasLength(3));
    expect(rules.rules,
        containsAll([Rule('br'), Rule('nom.br'), Rule('*.com')]));
  });

  test('hasRules_noRules_false', () {
    var rules = SuffixRules.fromString('');
    expect(rules.hasRules(), isFalse);
  });

  test('hasRules_withRules_true', () {
    var rules = SuffixRules.fromString('*.dev\n*.com');
    expect(rules.hasRules(), isTrue);
  });
}
