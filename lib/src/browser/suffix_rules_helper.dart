/*
 * Copyright 2019 Jakob Hjelm (Komposten)
 *
 * This file is part of public_suffix.
 *
 * public_suffix is a free Dart library: you can use, redistribute it and/or modify
 * it under the terms of the MIT license as written in the LICENSE file in the root
 * of this project.
 */
import 'dart:html';

import 'package:public_suffix/public_suffix.dart';

import '../suffix_rules.dart';

/// A static helper class for initialising [DefaultSuffixRules] or
/// creating [SuffixRules] instances from resources over http.
class SuffixRulesHelper {
  SuffixRulesHelper._();

  /// Initialises [DefaultSuffixRules] using a suffix list resource obtained from a URI.
  ///
  /// See [SuffixRules.fromString] for the expected format of the suffix list.
  ///
  /// [HttpRequest.request] is used to retrieve the resource, and the optional
  /// parameters can be used to tweak this request. If more fine-grained control
  /// over the request is needed, consider obtaining the suffix list using custom
  /// code first and then passing it to [DefaultSuffixRules.initFromString].
  ///
  /// An [Exception] is thrown if the request fails.
  static Future<void> initDefaultListFromUri(Uri uri,
      {bool? withCredentials,
      Map<String, String>? requestHeaders,
      dynamic sendData,
      void Function(ProgressEvent)? onProgress}) async {
    DefaultSuffixRules.initFromString(await _getUri(uri,
        withCredentials: withCredentials,
        requestHeaders: requestHeaders,
        sendData: sendData,
        onProgress: onProgress));
  }

  /// Creates a [SuffixRules] object using a suffix list resource obtained from a URI.
  ///
  /// See [SuffixRules.fromString] for the expected format of the suffix list.
  ///
  /// [HttpRequest.request] is used to retrieve the resource, and the optional
  /// parameters can be used to tweak this request. If more fine-grained control
  /// over the request is needed, consider obtaining the suffix list using custom
  /// code first and then passing it to [SuffixRules.fromString].
  ///
  /// An [Exception] is thrown if the request fails.
  static Future<SuffixRules> createListFromUri(Uri uri,
      {bool? withCredentials,
      Map<String, String>? requestHeaders,
      dynamic sendData,
      void Function(ProgressEvent)? onProgress}) async {
    return SuffixRules.fromString(await _getUri(uri,
        withCredentials: withCredentials,
        requestHeaders: requestHeaders,
        sendData: sendData,
        onProgress: onProgress));
  }

  static Future<String?> _getUri(Uri uri,
      {bool? withCredentials,
      Map<String, String>? requestHeaders,
      dynamic sendData,
      void Function(ProgressEvent)? onProgress}) async {
    try {
      var request = await HttpRequest.request(uri.toString(),
          withCredentials: withCredentials,
          requestHeaders: requestHeaders,
          sendData: sendData,
          onProgress: onProgress);

      switch (request.status) {
        case 200:
          return request.responseText;
        default:
          throw request;
      }
    } catch (e) {
      var object = e;

      if (e is ProgressEvent) {
        throw Exception('Request for public suffix list failed: ${e.target}');
      }

      if (object is HttpRequest) {
        throw Exception(
            'Request for public suffix list failed: [${object.status}] ${object.statusText}');
      } else {
        throw Exception('Request for public suffix list failed: $object');
      }
    }
  }
}
