/*
 * Copyright 2019 Jakob Hjelm (Komposten)
 *
 * This file is part of public_suffix.
 *
 * public_suffix is a free Dart library: you can use, redistribute it and/or modify
 * it under the terms of the MIT license as written in the LICENSE file in the root
 * of this project.
 */
import 'package:public_suffix/public_suffix.dart';

class DomainUtils {
  DomainUtils._();

  /// Checks if a URI is a subdomain of another.
  ///
  /// Both URIs are parsed to [PublicSuffix] objects, which are then compared
  /// using [PublicSuffix.isSubdomainOf()].
  static bool isSubdomainOf(Uri potentialSub, Uri root, {bool icann = false}) {
    var parsedUri = PublicSuffix(potentialSub);
    var parsedRoot = PublicSuffix(root);

    return parsedUri.isSubdomainOf(parsedRoot, icann: icann);
  }

  /// Checks if a URI is a subdomain or a root domain.
  ///
  /// [potentialSub] is parsed to a [PublicSuffix] object. It is a subdomain if
  /// the [subdomain] property of the object is [null].
  ///
  /// If [icann] is [true], [icannSubdomain] is checked instead.
  static bool isSubdomain(Uri potentialSub, {bool icann = false}) {
    if (icann) {
      return PublicSuffix(potentialSub).icannSubdomain != null;
    } else {
      return PublicSuffix(potentialSub).subdomain != null;
    }
  }

  /// Checks if [suffix] is a known url suffix.
  ///
  /// For example, `co.uk` is known but `example` is not.
  static bool isKnownSuffix(String suffix) {
    var split = suffix.split('.');
    var rules = SuffixRules.ruleMap[split.last] ?? <String>[];
    var isKnown = false;

    for (var rule in rules) {
      if (rule.labels.split('.').length == split.length &&
          rule.matches(suffix)) {
        isKnown = true;
        break;
      }
    }

    return isKnown;
  }
}
