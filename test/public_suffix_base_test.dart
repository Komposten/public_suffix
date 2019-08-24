@TestOn('vm')
import 'package:public_suffix/public_suffix_io.dart';
import 'package:test/test.dart';

void main() {
  test('PublicSuffix_PublicSuffixListNotInitialised_throwStateError', () {
    expect(
        () => PublicSuffix(Uri.parse('http://www.pub.dev')), throwsStateError);
  });

  test('PublicSuffix_uriWithoutAuthority_throwArgumentError', () async {
    SuffixRules.initFromString("");
    expect(() => PublicSuffix(Uri.parse('www.pub.dev')), throwsArgumentError);
  });

  group('PublicSuffix_', () {
    setUpAll(() async {
      await SuffixRulesHelper.initFromUri(Uri.parse(
          'file:///G:/Projects/Dart/public_suffix/test/res/public_suffix_list.dat'));
    });

    void testPublicSuffix(String url, String expectedRoot, String expectedTld) {
      if (!url.startsWith("http")) {
        url = "http://" + url;
      }
      var suffix = PublicSuffix(Uri.parse(url));
      expect(suffix.rootDomain, equals(expectedRoot));
      expect(suffix.publicTld, equals(expectedTld));
    }

    test('mixedCaseUrl_treatAsLowerCase', () {
      var suffix = PublicSuffix(Uri.parse('http://www.PuB.dEV'));
      expect(suffix.registrableDomain, equals('pub.dev'));
    });

    test('trailingDots_ignoreTrailingDots', () {
      var suffix = PublicSuffix(Uri.parse('http://www.pub.dev...'));
      expect(suffix.registrableDomain, equals('pub.dev'));
    });

    test('urlWithRegistrableDomain_correctRegistrableDomain', () {
      var suffix = PublicSuffix(Uri.parse('http://www.pub.dev'));
      expect(suffix.registrableDomain,
          equals("${suffix.rootDomain}.${suffix.publicTld}"));
    });

    test('urlWithoutRegistrableDomain_registrableDomainIsNull', () {
      var suffix = PublicSuffix(Uri.parse('http://dev'));

      expect(suffix.rootDomain, isEmpty);
      expect(suffix.publicTld, equals('dev'));
      expect(suffix.registrableDomain, isNull);
    });

    test('basicUrls_correctlyIdentifyRootAndTld', () {
      testPublicSuffix('www.pub.dev', 'pub', 'dev');
      testPublicSuffix('www.images.google.co.uk', 'google', 'co.uk');
    });

    test('exceptedUrls_correctlyIdentifyRootAndTld', () {
      //'city.yokohama.jp' is an exception from the '*.yokohama.jp' rule.
      testPublicSuffix('www.me.city.yokohama.jp', 'city', 'yokohama.jp');

      //'town.yokohama.jp' is not excepted, hence it's identified as the TLD.
      testPublicSuffix('www.me.town.yokohama.jp', 'me', 'town.yokohama.jp');
    });

    test('manyUrls_correctlyIdentifyRootAndTld', () {
      // Based on https://raw.githubusercontent.com/publicsuffix/list/master/tests/test_psl.txt

      // null input.
      expect(() => PublicSuffix(null), throwsNoSuchMethodError);
      // Mixed case.
      testPublicSuffix('COM', '', 'com');
      testPublicSuffix('example.COM', 'example', 'com');
      testPublicSuffix('WwW.example.COM', 'example', 'com');
      // Leading dot.
      testPublicSuffix('.com', '', 'com');
      testPublicSuffix('.example', '', 'example');
      testPublicSuffix('.example.com', 'example', 'com');
      testPublicSuffix('.example.example', 'example', 'example');
      // Unlisted TLD.
      testPublicSuffix('example', '', 'example');
      testPublicSuffix('example.example', 'example', 'example');
      testPublicSuffix('b.example.example', 'example', 'example');
      testPublicSuffix('a.b.example.example', 'example', 'example');
      // TLD with only 1 rule.
      testPublicSuffix('biz', '', 'biz');
      testPublicSuffix('domain.biz', 'domain', 'biz');
      testPublicSuffix('b.domain.biz', 'domain', 'biz');
      testPublicSuffix('a.b.domain.biz', 'domain', 'biz');
      // TLD with some 2-level rules.
      testPublicSuffix('com', '', 'com');
      testPublicSuffix('example.com', 'example', 'com');
      testPublicSuffix('b.example.com', 'example', 'com');
      testPublicSuffix('a.b.example.com', 'example', 'com');
      testPublicSuffix('uk.com', '', 'uk.com');
      testPublicSuffix('example.uk.com', 'example', 'uk.com');
      testPublicSuffix('b.example.uk.com', 'example', 'uk.com');
      testPublicSuffix('a.b.example.uk.com', 'example', 'uk.com');
      testPublicSuffix('test.ac', 'test', 'ac');
      // TLD with only 1 (wildcard) rule.
      testPublicSuffix('mm', '', 'mm');
      testPublicSuffix('c.mm', '', 'c.mm');
      testPublicSuffix('b.c.mm', 'b', 'c.mm');
      testPublicSuffix('a.b.c.mm', 'b', 'c.mm');
      // More complex TLD.
      testPublicSuffix('jp', '', 'jp');
      testPublicSuffix('test.jp', 'test', 'jp');
      testPublicSuffix('www.test.jp', 'test', 'jp');
      testPublicSuffix('ac.jp', '', 'ac.jp');
      testPublicSuffix('test.ac.jp', 'test', 'ac.jp');
      testPublicSuffix('www.test.ac.jp', 'test', 'ac.jp');
      testPublicSuffix('kyoto.jp', '', 'kyoto.jp');
      testPublicSuffix('test.kyoto.jp', 'test', 'kyoto.jp');
      testPublicSuffix('ide.kyoto.jp', '', 'ide.kyoto.jp');
      testPublicSuffix('b.ide.kyoto.jp', 'b', 'ide.kyoto.jp');
      testPublicSuffix('a.b.ide.kyoto.jp', 'b', 'ide.kyoto.jp');
      testPublicSuffix('c.kobe.jp', '', 'c.kobe.jp');
      testPublicSuffix('b.c.kobe.jp', 'b', 'c.kobe.jp');
      testPublicSuffix('a.b.c.kobe.jp', 'b', 'c.kobe.jp');
      testPublicSuffix('city.kobe.jp', 'city', 'kobe.jp');
      testPublicSuffix('www.city.kobe.jp', 'city', 'kobe.jp');
      // TLD with a wildcard rule and exceptions.
      testPublicSuffix('ck', '', 'ck');
      testPublicSuffix('test.ck', '', 'test.ck');
      testPublicSuffix('b.test.ck', 'b', 'test.ck');
      testPublicSuffix('a.b.test.ck', 'b', 'test.ck');
      testPublicSuffix('www.ck', 'www', 'ck');
      testPublicSuffix('www.www.ck', 'www', 'ck');
      // US K12.
      testPublicSuffix('us', '', 'us');
      testPublicSuffix('test.us', 'test', 'us');
      testPublicSuffix('www.test.us', 'test', 'us');
      testPublicSuffix('ak.us', '', 'ak.us');
      testPublicSuffix('test.ak.us', 'test', 'ak.us');
      testPublicSuffix('www.test.ak.us', 'test', 'ak.us');
      testPublicSuffix('k12.ak.us', '', 'k12.ak.us');
      testPublicSuffix('test.k12.ak.us', 'test', 'k12.ak.us');
      testPublicSuffix('www.test.k12.ak.us', 'test', 'k12.ak.us');
      // IDN labels.
      testPublicSuffix('食狮.com.cn', '食狮', 'com.cn');
      testPublicSuffix('食狮.公司.cn', '食狮', '公司.cn');
      testPublicSuffix('www.食狮.公司.cn', '食狮', '公司.cn');
      testPublicSuffix('shishi.公司.cn', 'shishi', '公司.cn');
      testPublicSuffix('公司.cn', '', '公司.cn');
      testPublicSuffix('食狮.中国', '食狮', '中国');
      testPublicSuffix('www.食狮.中国', '食狮', '中国');
      testPublicSuffix('shishi.中国', 'shishi', '中国');
      testPublicSuffix('中国', '', '中国');
      // Same as above, but punycoded.
      testPublicSuffix('xn--85x722f.com.cn', 'xn--85x722f', 'com.cn');
      testPublicSuffix(
          'xn--85x722f.xn--55qx5d.cn', 'xn--85x722f', 'xn--55qx5d.cn');
      testPublicSuffix(
          'www.xn--85x722f.xn--55qx5d.cn', 'xn--85x722f', 'xn--55qx5d.cn');
      testPublicSuffix('shishi.xn--55qx5d.cn', 'shishi', 'xn--55qx5d.cn');
      testPublicSuffix('xn--55qx5d.cn', '', 'xn--55qx5d.cn');
      testPublicSuffix('xn--85x722f.xn--fiqs8s', 'xn--85x722f', 'xn--fiqs8s');
      testPublicSuffix(
          'www.xn--85x722f.xn--fiqs8s', 'xn--85x722f', 'xn--fiqs8s');
      testPublicSuffix('shishi.xn--fiqs8s', 'shishi', 'xn--fiqs8s');
      testPublicSuffix('xn--fiqs8s', '', 'xn--fiqs8s');
    });

    test('punycodedUrl_punydecodedInstanceHasDecodedData', () {
      var suffix = PublicSuffix(Uri.parse('http://xn--85x722f.xn--55qx5d.cn'));
      expect(suffix.rootDomain, equals('xn--85x722f'));
      expect(suffix.publicTld, equals('xn--55qx5d.cn'));
      expect(suffix.punyDecoded.rootDomain, equals('食狮'));
      expect(suffix.punyDecoded.publicTld, equals('公司.cn'));
    });

    test('notPunycodedUrl_punydecodedInstanceHasSameData', () {
      var suffix = PublicSuffix(Uri.parse('http://google.co.uk'));
      expect(suffix.rootDomain, equals('google'));
      expect(suffix.publicTld, equals('co.uk'));
      expect(suffix.punyDecoded.rootDomain, equals('google'));
      expect(suffix.punyDecoded.publicTld, equals('co.uk'));
    });

    tearDownAll(() => SuffixRules.dispose());
  });
}
