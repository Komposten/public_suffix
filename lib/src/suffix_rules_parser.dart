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

/// Tools for parsing and validating a list of suffix rules.
class SuffixRulesParser {
  /// Converts a list of strings into a list of rules.
  ///
  /// Lines that contain comments (start with `//`) or are empty (i.e. zero-length
  /// or only contain whitespace characters) are removed completely.
  ///
  /// Since [publicsuffix.org](https://publicsuffix.org/list/) defines rules as
  /// the part of a line _before_ the first whitespace character, any text that
  /// follows after this is also removed.
  ///
  /// Finally, all lines are changed to lower case to ease case-insensitive
  /// comparisons later.
  ///
  /// The resulting list is returned as a list of [Rule]s. Comments containing
  /// `BEGIN PRIVATE` and `END PRIVATE` can be used to indicate a section of rules
  /// that should be marked as `isIcann = false` ("private rules").
  List<Rule> process(List<String> rules) {
    var isIcann = true;
    var newList = <Rule>[];

    for (var line in rules) {
      if (_isComment(line)) {
        if (line.contains('BEGIN PRIVATE')) {
          isIcann = false;
        } else if (line.contains('END PRIVATE')) {
          isIcann = true;
        }
      } else if (!_isComment(line) && !_isEmpty(line)) {
        var firstSpace = line.indexOf(' ');

        if (firstSpace != -1) {
          line = line.substring(0, firstSpace).trim();
        }

        newList.add(Rule(line.toLowerCase(), isIcann: isIcann));
      }
    }

    return newList;
  }

  /// Validates the format of the provided rules.
  ///
  /// The content of [rules] is validated against the expected format
  /// as described on [publicsuffix.org](https://publicsuffix.org/list/).
  /// [rules] is expected to first have been passed through [process].
  ///
  /// In brief:
  ///
  /// * Rules should not start with a period (.)
  /// * Rules may contain asterisks (*) as wildcards
  ///     * Wildcards must be surrounded by periods or the line start/end
  ///     * Example: `*.uk` is valid, `c*.uk` is not
  /// * Rules that start with exclamation marks (!) mark exceptions to previous rules
  ///     * Example: `!co.uk` would exclude `co.uk` from `*.uk`
  ///
  /// If at least one rule in the list is invalid, a [FormatException] is thrown
  /// containing information about the amount of invalid lines in the message.
  void validate(List<Rule> rules) {
    var invalidRules = 0;

    for (var rule in rules) {
      if (_isComment(rule.labels) ||
          _isEmpty(rule.labels) ||
          !_isValidRule(rule.labels)) {
        invalidRules++;
      }
    }

    if (invalidRules > 0) {
      throw FormatException(
          'Invalid suffix list: $invalidRules/${rules.length} lines are not formatted properly!');
    }
  }

  bool _isEmpty(String line) => RegExp(r'^\s*$').hasMatch(line);

  bool _isComment(String line) => line.trimLeft().startsWith('//');

  bool _isValidRule(String line) =>
      RegExp(r'^(?:\*|[^*.!\s][^*.!\s]*)(?:\.(?:[*]|[^*.\s]+))*$')
          .hasMatch(line);
}
