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

import 'package:public_suffix/public_suffix.dart';

import '../suffix_rules.dart';

/// A static helper class for initialising [DefaultSuffixRules] or
/// creating [SuffixRules] instances from resources over http or files.
class SuffixRulesHelper {
  SuffixRulesHelper._();

  /// Initialises [DefaultSuffixRules] using a suffix list resource obtained from a URI.
  ///
  /// See [SuffixRules.fromString] for the expected format of the suffix list.
  ///
  /// If [uri] is a `file:///` URI, the file is loaded using
  /// [File.readAsString]. For other schemes, the resource is fetched using
  /// an http request created using a simple [HttpClient].
  ///
  /// If more fine-grained control over the request is needed, consider obtaining
  /// the suffix list using custom code first and then passing it to
  /// [DefaultSuffixRules.initFromString].
  static Future<void> initDefaultListFromUri(Uri uri) async {
    if (uri.isScheme('file')) {
      DefaultSuffixRules.initFromString(await _getFile(uri));
    } else {
      DefaultSuffixRules.initFromString(await _getUrl(uri));
    }
  }

  /// Creates a [SuffixRules] object using a suffix list resource obtained from a URI.
  ///
  /// See [SuffixRules.fromString] for the expected format of the suffix list.
  ///
  /// If [uri] is a `file:///` URI, the file is loaded using
  /// [File.readAsString]. For other schemes, the resource is fetched using
  /// an http request created using a simple [HttpClient].
  ///
  /// If more fine-grained control over the request is needed, consider obtaining
  /// the suffix list using custom code first and then passing it to
  /// [SuffixRules.fromString].
  static Future<SuffixRules> createListFromUri(Uri uri) async {
    if (uri.isScheme('file')) {
      return SuffixRules.fromString(await _getFile(uri));
    } else {
      return SuffixRules.fromString(await _getUrl(uri));
    }
  }

  static Future<String> _getFile(Uri fileUri) async {
    File file = File.fromUri(fileUri);
    return await file.readAsString();
  }

  static Future<String> _getUrl(Uri uri) async {
    var request = await HttpClient().getUrl(uri);
    var response = await request.close();

    switch (response.statusCode) {
      case 200:
        return await response.transform(Utf8Decoder()).join();
        break;
      default:
        throw Exception(
            "Request for public suffix list failed: [${response.statusCode}]");
    }
  }
}
