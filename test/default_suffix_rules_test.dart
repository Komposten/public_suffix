import 'package:public_suffix/public_suffix.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() => DefaultSuffixRules.dispose());

  group('hasInitialised_', () {
    test('initialiseFirst_true', () {
      DefaultSuffixRules.initFromList(['br']);
      expect(DefaultSuffixRules.hasInitialised(), isTrue);
    });

    test('uninitialised_false', () {
      expect(DefaultSuffixRules.hasInitialised(), isFalse);
    });
  });

  test('dispose_initialiseFirst_uninitialised', () {
    DefaultSuffixRules.initFromList(['br']);
    DefaultSuffixRules.dispose();
    expect(DefaultSuffixRules.hasInitialised(), isFalse);
  });

  test('afterInitialising_hasSuffixList', () {
    DefaultSuffixRules.initFromList(['br', 'nom.br']);
    expect(DefaultSuffixRules.rules, isNotNull);
    expect(DefaultSuffixRules.rules.rules, hasLength(2));
    expect(DefaultSuffixRules.rules.rules,
        containsAllInOrder([Rule('br'), Rule('nom.br')]));
  });

  test('beforeInitialising_hasNoSuffixList', () {
    expect(DefaultSuffixRules.rules, isNull);
  });
}
