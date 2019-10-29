@TestOn('vm')
import 'package:public_suffix/io_helper.dart';
import 'package:public_suffix/public_suffix.dart';
import 'package:test/test.dart';

import 'io_test_utils.dart';

void main() {
  group('SuffixRules initialised', () {
    setUpAll(() async {
      await SuffixRulesHelper.initFromUri(getSuffixListFileUri());
    });

    tearDownAll(() {
      SuffixRules.dispose();
    });

    group('isSubdomainOf_', () {
      void testSubdomainOf(String domain1, String domain2,
          {bool icann = false}) {
        var uri1 = Uri.parse(domain1);
        var uri2 = Uri.parse(domain2);
        var publicSuffix1 = PublicSuffix(uri1);
        var publicSuffix2 = PublicSuffix(uri2);

        expect(DomainUtils.isSubdomainOf(uri1, uri2, icann: icann),
            equals(publicSuffix1.isSubdomainOf(publicSuffix2, icann: icann)));
      }

      test('variousSituations_sameResultAsPublicSuffixIsSubdomain', () {
        testSubdomainOf('http://images.google.co.uk', 'http://google.co.uk');
        testSubdomainOf(
            'http://deeper.images.google.co.uk', 'http://images.google.co.uk');
        testSubdomainOf(
            'http://images.google.co.uk', 'http://photos.google.co.uk');
        testSubdomainOf('http://deeper.images.google.co.uk',
            'http://deeper.images.photos.google.co.uk');
        testSubdomainOf('http://google.co.uk', 'http://google.co.uk');
        testSubdomainOf('http://images.google.co.uk', 'http://google.com');
        testSubdomainOf('http://images.google.co.uk', 'http://googol.co.uk');
        testSubdomainOf('http://komposten.github.io', 'http://github.io',
            icann: false);
        testSubdomainOf('http://komposten.github.io', 'http://github.io',
            icann: true);
      });
    });

    group('isSubdomain', () {
      test('rootDomain_false', () {
        expect(
            DomainUtils.isSubdomain(Uri.parse('http://google.co.uk')), isFalse);
      });

      test('subdomains_true', () {
        expect(DomainUtils.isSubdomain(Uri.parse('http://images.google.co.uk')),
            isTrue);
        expect(
            DomainUtils.isSubdomain(
                Uri.parse('http://deeper.images.google.co.uk')),
            isTrue);
      });

      test('icann', () {
        expect(
            DomainUtils.isSubdomain(Uri.parse('http://komposten.github.io'),
                icann: false),
            isFalse);
        expect(
            DomainUtils.isSubdomain(Uri.parse('http://komposten.github.io'),
                icann: true),
            isTrue);
      });
    });

    group('isKnownSuffix', () {
      test('knownSuffixes_true', () {
        // Exact matches
        expect(DomainUtils.isKnownSuffix('co.uk'), isTrue);
        expect(DomainUtils.isKnownSuffix('github.io'), isTrue);
        // Wildcard matches
        expect(DomainUtils.isKnownSuffix('cat.moonscale.io'), isTrue);
      });

      test('unknownSuffixes_false', () {
        expect(DomainUtils.isKnownSuffix('example'), isFalse);
        expect(DomainUtils.isKnownSuffix('hamster.io'), isFalse);
      });
    });

    group('hasValidDomain_', () {
      void testValidDomain(String domain,
          {bool icann = false, bool defaultRule = true}) {
        var uri = Uri.parse(domain);
        var publicSuffix1 = PublicSuffix(uri);

        expect(
            DomainUtils.hasValidDomain(uri,
                icann: icann, acceptDefaultRule: defaultRule),
            equals(publicSuffix1.hasValidDomain(
                icann: icann, acceptDefaultRule: defaultRule)));
      }

      test('variousSituations_sameResultAsPublicSuffiHasValidDomain', () {
        testValidDomain('http://google.co.uk');
        testValidDomain('http://komposten.github.io');
        testValidDomain('http://co.uk');
        testValidDomain('http://github.io');
        testValidDomain('http://github.io', icann: true);
        testValidDomain('http://example.example', defaultRule: false);
      });
    });
  });

  group('SuffixRules uninitialised', () {
    test('suffixRulesNotInitialised_throwStateError', () {
      expect(() => DomainUtils.isKnownSuffix('example'), throwsStateError);
    });
  });
}
