/*
 * Copyright 2019 Jakob Hjelm (Komposten)
 *
 * This file is part of public_suffix.
 *
 * public_suffix is a free Dart library: you can use, redistribute it and/or modify
 * it under the terms of the MIT license as written in the LICENSE file in the root
 * of this project.
 */
import 'dart:convert';
import 'dart:io';

import '../public_suffix_list.dart';

/// A static helper class for initialising [PublicSuffixList].
///
/// This class provides simple functions for initialising [PublicSuffixList]
/// from resources obtained from files or using http requests.
///
/// To initialise directly from strings instead, use [PublicSuffixList.initFromString].
class PublicSuffixListHelper {
  PublicSuffixListHelper._();

  /// Initialises [PublicSuffixList] using a suffix list resource obtained from a URI.
  ///
  /// If [publicSuffixList] is a `file:///` URI, the file is loaded using
  /// [File.readAsString]. For other schemes, the resource is fetched using
  /// an http request is created using a simple [HttpClient].
  ///
  /// If more fine-grained control over the request is needed, consider obtaining
  /// the suffix list using custom code first and then passing it to
  /// [PublicSuffixList.initFromString].
  static Future<void> initFromUri(Uri publicSuffixList) async {
    if (publicSuffixList.isScheme('file')) {
      await _initFromFile(publicSuffixList);
    } else {
      await _initFromUrl(publicSuffixList);
    }
  }

  static Future<void> _initFromFile(Uri publicSuffixList) async {
    File file = File.fromUri(publicSuffixList);
    var data = await file.readAsString();

    PublicSuffixList.initFromString(data);
  }

  static Future<void> _initFromUrl(Uri publicSuffixList) async {
    try {
      var request = await HttpClient().getUrl(publicSuffixList);
      var response = await request.close();
      var data = await response.transform(Utf8Decoder()).join();

      PublicSuffixList.initFromString(data);
    } catch (e) {
      rethrow;
    }
  }
}
