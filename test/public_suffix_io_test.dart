@TestOn("vm")
import 'package:test/test.dart';

import 'dart:io';
import 'package:public_suffix/public_suffix_io.dart';

void main() {
  tearDown(() => SuffixRules.dispose());

  test('initPublicSuffixList_crossDomainUrl_initList', () async {
    await SuffixRulesHelper.initFromUri(
        Uri.parse('https://publicsuffix.org/list/public_suffix_list.dat'));
    expect(SuffixRules.hasInitialised(), isTrue);
    expect(SuffixRules.rules, isNotEmpty);
  });

  test('initPublicSuffixList_invalidUrl_throwException', () async {
    expect(
        SuffixRulesHelper.initFromUri(
            Uri.parse('http://127.0.0.2/list.dat')),
        throwsException);
    expect(SuffixRules.hasInitialised(), isFalse);
  });

  group('initPublicSuffixList_validFileUri_', () {
    Directory path;
    Uri fileUri;
    File file;
    bool deleteAfter = false;

    setUpAll(() async {
      path = Directory('test/res').absolute;
      fileUri = Uri.file("${path.path}/public_suffix_list.dat");
      file = File.fromUri(fileUri);

      if (!await path.exists()) {
        await path.create(recursive: true);
      }

      if (!await file.exists()) {
        var request = await HttpClient().getUrl(
            Uri.parse('https://publicsuffix.org/list/public_suffix_list.dat'));
        var response = await request.close();
        await response.pipe(file.openWrite());

        if (!await file.exists()) {
          fail("Failed to download the test file.");
        } else {
          deleteAfter = true;
        }
      }
    });

    tearDownAll(() async {
      if (deleteAfter) {
        await file.delete();
      }
    });

    test('initList', () async {
      await SuffixRulesHelper.initFromUri(fileUri);
      expect(SuffixRules.hasInitialised(), isTrue);
      expect(SuffixRules.rules, isNotEmpty);
    });
  });
}
