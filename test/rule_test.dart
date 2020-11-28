import 'package:public_suffix/src/suffix_rules.dart';
import 'package:test/test.dart';

void main() {
  group('Rule_', () {
    test('exceptionRule_detectedProperly', () {
      var rule = Rule('!a.b');
      expect(rule.isException, equals(true));
      expect(rule.labels, equals('a.b'));
    });
  });

  group('matches_', () {
    test('fixedRuleAndMatchingHosts_true', () {
      var rule = Rule('ab.cd');
      expect(rule.matches('ab.cd'), equals(true));
      expect(rule.matches('ef.ab.cd'), equals(true));
    });

    test('wildRuleAndMatchingHosts_true', () {
      var rule = Rule('*.cd');
      expect(rule.matches('ab.cd'), equals(true));
      expect(rule.matches('ef.ab.cd'), equals(true));

      rule = Rule('*.a.*.b');
      expect(rule.matches('d.a.c.b'), equals(true));
      expect(rule.matches('z.a.q.b'), equals(true));
      expect(rule.matches('e.d.a.c.b'), equals(true));
    });

    test('fixedRuleAndNonmatchingHosts_false', () {
      var rule = Rule('ab.cd');
      expect(rule.matches('ac.cb'), equals(false));
      expect(rule.matches('a.c'), equals(false));
      expect(rule.matches('cd.ab'), equals(false));
    });

    test('wildRuleAndNonmatchingHosts_false', () {
      var rule = Rule('*.cd');
      expect(rule.matches('ab.dc'), equals(false));

      rule = Rule('*.a.*.b');
      expect(rule.matches('a.b.c.d'), equals(false));
      expect(rule.matches('a.b.c.b'), equals(false));
      expect(rule.matches('a.a.c.d'), equals(false));
    });

    test('hostsShorterThanRule_false', () {
      var rule = Rule('a.b.c.d');
      expect(rule.matches('b.c.d'), equals(false));

      rule = Rule('*.b.*.d');
      expect(rule.matches('b.c.d'), equals(false));
    });

    test('exceptionRuleAndMatchingHosts_true', () {
      var rule = Rule('!ab.cd');
      expect(rule.matches('ab.cd'), equals(true));
      expect(rule.matches('ef.ab.cd'), equals(true));
    });
  });

  group('equals_', () {
    test('compareWithSelf_true', () {
      var rule = Rule('ab.cd');
      expect(rule == rule, equals(true));
    });

    test('compareWithNull_false', () {
      var rule = Rule('ab.cd');
      expect(rule == null, equals(false));
    });

    test('otherClass_false', () {
      // ignore: unrelated_type_equality_checks
      expect(Rule('ab.cd') == 'ab.cd', equals(false));
    });

    test('differentLabels_false', () {
      expect(Rule('ab.cd') == Rule('ab.ce'), equals(false));
    });

    test('exceptionVsNonException_false', () {
      expect(Rule('!ab.cd') == Rule('ab.cd'), equals(false));
      expect(Rule('ab.cd') == Rule('!ab.cd'), equals(false));
    });

    test('icannVsNonIcann_false', () {
      expect(Rule('ab.cd') == Rule('ab.cd', isIcann: false), equals(false));
      expect(Rule('ab.cd', isIcann: false) == Rule('ab.cd'), equals(false));
    });

    test('identicalRules_true', () {
      expect(Rule('ab.cd') == Rule('ab.cd'), equals(true));
      expect(Rule('!ab.cd', isIcann: false) == Rule('!ab.cd', isIcann: false),
          equals(true));
    });
  });

  group('lessThan_', () {
    test('identical_false', () {
      expect(Rule('ab.cd') < Rule('ab.cd'), equals(false));
    });

    test('firstLessThanSecond_true', () {
      expect(Rule('aa.cd') < Rule('ab.cd'), equals(true));
    });

    test('secondLessThanFirst_false', () {
      expect(Rule('ab.cd') < Rule('aa.cd'), equals(false));
    });

    test('compareInReverse', () {
      expect(Rule('ab.cd') < Rule('bb.cc'), equals(false));
      expect(Rule('bb.cc') < Rule('ab.cd'), equals(true));
    });
  });

  group('greaterThan_', () {
    test('identical_false', () {
      expect(Rule('ab.cd') > Rule('ab.cd'), equals(false));
    });

    test('firstGreaterThanSecond_true', () {
      expect(Rule('ab.cd') > Rule('aa.cd'), equals(true));
    });

    test('secondGreaterThanFirst_false', () {
      expect(Rule('aa.cd') > Rule('ab.cd'), equals(false));
    });

    test('compareInReverse', () {
      expect(Rule('ab.cd') > Rule('bb.cc'), equals(true));
      expect(Rule('bb.cc') > Rule('ab.cd'), equals(false));
    });
  });

  group('lessThanEqualTo_', () {
    test('identical_true', () {
      expect(Rule('ab.cd') <= Rule('ab.cd'), equals(true));
    });

    test('firstLessThanSecond_true', () {
      expect(Rule('aa.cd') <= Rule('ab.cd'), equals(true));
    });

    test('secondLessThanFirst_false', () {
      expect(Rule('ab.cd') <= Rule('aa.cd'), equals(false));
    });

    test('compareInReverse', () {
      expect(Rule('ab.cd') <= Rule('bb.cc'), equals(false));
      expect(Rule('bb.cc') <= Rule('ab.cd'), equals(true));
    });
  });

  group('greaterThanEqualTo_', () {
    test('identical_true', () {
      expect(Rule('ab.cd') >= Rule('ab.cd'), equals(true));
    });

    test('firstGreaterThanSecond_true', () {
      expect(Rule('ab.cd') >= Rule('aa.cd'), equals(true));
    });

    test('secondGreaterThanFirst_false', () {
      expect(Rule('aa.cd') >= Rule('ab.cd'), equals(false));
    });

    test('compareInReverse', () {
      expect(Rule('ab.cd') >= Rule('bb.cc'), equals(true));
      expect(Rule('bb.cc') >= Rule('ab.cd'), equals(false));
    });
  });
}
