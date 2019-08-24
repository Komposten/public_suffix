@TestOn("browser")

import 'package:public_suffix/public_suffix_browser.dart';
import 'package:public_suffix/src/public_suffix_list.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() => PublicSuffixList.dispose());

  test('initPublicSuffixList_crossDomainUrl_initList', () async {
    await PublicSuffixListHelper.initFromUri(
        Uri.parse('https://publicsuffix.org/list/public_suffix_list.dat'));
    expect(PublicSuffixList.hasInitialised(), isTrue);
    expect(PublicSuffixList.suffixList, isNotEmpty);
  });

  test('initPublicSuffixList_fileAccessDenied_fail', () async {
    var file = Uri.file("/public_suffix_list.dat");

    expect(PublicSuffixListHelper.initFromUri(file), throwsException);
  });

  test('initPublicSuffixList_invalidUrl_throwException', () async {
    expect(
        PublicSuffixListHelper.initFromUri(Uri.parse('127.0.0.2/list.dat')), throwsException);
    expect(PublicSuffixList.hasInitialised(), isFalse);
  });
}