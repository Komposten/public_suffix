@TestOn('vm')
import 'package:public_suffix/public_suffix_io.dart';
import 'package:test/test.dart';
import 'io_test_utils.dart';

void main() {
  setUpAll(() async {
    await SuffixRulesHelper.initFromUri(getSuffixListFileUri());
  });

  tearDownAll(() {
    SuffixRules.dispose();
  });

  group('isSubdomainOf_', () {
    test('subdomainOfRoot_true', () {
      expect(
          DomainUtils.isSubdomainOf(Uri.parse('http://images.google.co.uk'),
              Uri.parse('http://google.co.uk')),
          isTrue);
    });

    test('subdomainOfSubdomain_true', () {
      expect(
          DomainUtils.isSubdomainOf(
              Uri.parse('http://deeper.images.google.co.uk'),
              Uri.parse('http://images.google.co.uk')),
          isTrue);
    });

    test('differentSubdomains_false', () {
      expect(
          DomainUtils.isSubdomainOf(Uri.parse('http://images.google.co.uk'),
              Uri.parse('http://photos.google.co.uk')),
          isFalse);
      expect(
          DomainUtils.isSubdomainOf(
              Uri.parse('http://deeper.images.google.co.uk'),
              Uri.parse('http://deeper.images.photos.google.co.uk')),
          isFalse);
    });

    test('noSubdomain_false', () {
      expect(
          DomainUtils.isSubdomainOf(Uri.parse('http://google.co.uk'),
              Uri.parse('http://google.co.uk')),
          isFalse);
    });

    test('differentDomains_false', () {
      expect(
          DomainUtils.isSubdomainOf(Uri.parse('http://images.google.co.uk'),
              Uri.parse('http://google.com')),
          isFalse);
      expect(
          DomainUtils.isSubdomainOf(Uri.parse('http://images.google.co.uk'),
              Uri.parse('http://googol.co.uk')),
          isFalse);
    });

    test('icann', () {
      expect(
          DomainUtils.isSubdomainOf(Uri.parse('http://komposten.github.io'),
              Uri.parse('http://github.io'),
              icann: false),
          isFalse);
      expect(
          DomainUtils.isSubdomainOf(Uri.parse('http://komposten.github.io'),
              Uri.parse('http://github.io'),
              icann: true),
          isTrue);
    });
  });
}
