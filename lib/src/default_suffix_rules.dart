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

/// A statically accessible [SuffixRules] instance used by
/// [PublicSuffix] as a default list.
///
/// After initialisation the rules can be accessed using [rules].
class DefaultSuffixRules {
  static SuffixRules? _rules;

  /// Returns the default suffix rules.
  ///
  /// `null` is returned if the list has not been initialised.
  static SuffixRules? get rules => _rules;

  /// Returns the default suffix rules or throws if they haven't
  /// been initialised.
  static SuffixRules rulesOrThrow() {
    if (hasInitialised()) {
      return rules!;
    } else {
      throw StateError('DefaultSuffixRules has not been initialised!');
    }
  }

  /// Checks if the rule list has been initialised.
  static bool hasInitialised() => _rules != null;

  DefaultSuffixRules._();

  /// Initialises the default rule list from a multi-rule string.
  ///
  /// See [SuffixRules.fromString] for details.
  static void initFromString(String? rules) {
    _rules = SuffixRules.fromString(rules);
  }

  /// Initialises the default rule list from a list of rule strings.
  ///
  /// See [SuffixRules.fromString] for details.
  static void initFromList(List<String> rules) {
    _rules = SuffixRules.fromList(rules);
  }

  /// Initialises the default rule list from a list of [Rule]s.
  ///
  /// See [SuffixRules.fromString] for details.
  static void initFromRules(List<Rule> rules) {
    _rules = SuffixRules.fromRules(rules);
  }

  /// Disposes of the default rule list.
  ///
  /// [hasInitialised] will return `false` after this has been called.
  static void dispose() {
    _rules = null;
  }
}
