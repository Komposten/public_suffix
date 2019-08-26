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

import '../suffix_rules.dart';

/// A static helper class for initialising [SuffixRules].
///
/// This class provides simple functions for initialising [SuffixRules]
/// from resources obtained from files or using http requests.
///
/// To initialise directly from strings instead, use [SuffixRules.initFromString].
class SuffixRulesHelper {
  SuffixRulesHelper._();

  /// Initialises [SuffixRules] using a suffix list resource obtained from a URI.
  ///
  /// If [uri] is a `file:///` URI, the file is loaded using
  /// [File.readAsString]. For other schemes, the resource is fetched using
  /// an http request created using a simple [HttpClient].
  ///
  /// If more fine-grained control over the request is needed, consider obtaining
  /// the suffix list using custom code first and then passing it to
  /// [SuffixRules.initFromString].
  static Future<void> initFromUri(Uri uri) async {
    if (uri.isScheme('file')) {
      await _initFromFile(uri);
    } else {
      await _initFromUrl(uri);
    }
  }

  static Future<void> _initFromFile(Uri fileUri) async {
    File file = File.fromUri(fileUri);
    var data = await file.readAsString();

    SuffixRules.initFromString(data);
  }

  static Future<void> _initFromUrl(Uri uri) async {
    var request = await HttpClient().getUrl(uri);
    var response = await request.close();

    switch (response.statusCode) {
      case 200:
        var data = await response.transform(Utf8Decoder()).join();
        SuffixRules.initFromString(data);
        break;
      default:
        throw Exception(
            "Request for public suffix list failed: [${response.statusCode}]");
    }
  }
}
