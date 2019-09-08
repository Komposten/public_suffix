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

/// Various utility functions for domains and suffixes.
///
/// This class holds utility functions to perform certain checks on domains and
/// suffixes without having to first create [PublicSuffix] objects. Most of these
/// functions create [PublicSuffix] objects internally, so if you already have
/// such objects consider using the equivalent methods within [PublicSuffix] instead.
class DomainUtils {
  DomainUtils._();

  /// Checks if a URL is a subdomain of another.
  ///
  /// Both URLs are parsed to [PublicSuffix] objects, which are then compared
  /// using [PublicSuffix.isSubdomainOf()].
  ///
  /// Throws a [StateError] if [SuffixRules] has not been initialised.
  static bool isSubdomainOf(Uri potentialSub, Uri root, {bool icann = false}) {
    var parsedUrl = PublicSuffix(potentialSub);
    var parsedRoot = PublicSuffix(root);

    return parsedUrl.isSubdomainOf(parsedRoot, icann: icann);
  }

  /// Checks if a URL is a subdomain or a root domain.
  ///
  /// [potentialSub] is parsed to a [PublicSuffix] object. It is a subdomain if
  /// the [subdomain] property of the object is [null].
  ///
  /// If [icann] is [true], [icannSubdomain] is checked instead.
  ///
  /// Throws a [StateError] if [SuffixRules] has not been initialised.
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
  ///
  /// Throws a [StateError] if [SuffixRules] has not been initialised.
  static bool isKnownSuffix(String suffix) {
    if (!SuffixRules.hasInitialised()) {
      throw StateError('PublicSuffixList has not been initialised!');
    }

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

  /// Checks if the URL contains a registrable domain part.
  ///
  /// If [icann] is [true] the check will be based on only the ICANN/IANA rules.
  /// If [acceptDefaultRule] is [false] URLs with suffixes only matching the
  /// default rule (`*`) will be seen as invalid.
  ///
  /// Throws a [StateError] if [SuffixRules] has not been initialised.
  static bool hasValidDomain(Uri domain,
      {bool icann = false, bool acceptDefaultRule = true}) {
    return PublicSuffix(domain)
        .hasValidDomain(icann: icann, acceptDefaultRule: acceptDefaultRule);
  }
}
