/*
 * Copyright 2019 Jakob Hjelm (Komposten)
 *
 * This file is part of public_suffix.
 *
 * public_suffix is a free Dart library: you can use, redistribute it and/or modify
 * it under the terms of the MIT license as written in the LICENSE file in the root
 * of this project.
 */

/// A wrapper for a static list containing rules for public suffixes.
///
/// After initialisation the rules can be accessed using [rules]. The list
/// can be disposed of using [dispose] if it is no longer needed.
class SuffixRules {
  static List<String> _rules;

  /// Returns an unmodifiable list containing the current rules.
  ///
  /// [null] is returned if the list has not been initialised.
  static List<String> get rules =>
      _rules != null ? List.unmodifiable(_rules) : null;

  /// Checks if the rule list has been initialised.
  static bool hasInitialised() => _rules != null;

  /// Initialises the rule list.
  ///
  /// [rules] is expected to contain the contents of a suffix list with one rule per line,
  /// like the file at [publicsuffix.org](https://publicsuffix.org/list/public_suffix_list.dat).
  static void initFromString(String rules) {
    initFromList(rules.split(RegExp(r'[\r\n]+')));
  }

  /// Initialises the rule list.
  ///
  /// [rules] is expected to contain the contents of a suffix list with one rule per element.
  /// See [publicsuffix.org](https://publicsuffix.org/list/public_suffix_list.dat)
  /// for the rule format.
  static void initFromList(List<String> rules) {
    rules = process(rules);
    validate(rules);
    _rules = rules;
  }

  /// Removes text from the list that is not related to any rules.
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
  /// The resulting list is returned as a new instance, so that the original
  /// list [rules] remains untouched.
  static List<String> process(List<String> rules) {
    var newList = <String>[];

    for (var line in rules) {
      if (!_isComment(line) && !_isEmpty(line)) {
        var firstSpace = line.indexOf(' ');

        if (firstSpace != -1) {
          line = line.substring(0, firstSpace).trim();
        }

        newList.add(line.toLowerCase());
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
  static void validate(List<String> rules) {
    int invalidLines = 0;

    for (var line in rules) {
      if (_isComment(line) || _isEmpty(line) || !_isValidRule(line)) {
        invalidLines++;
      }
    }

    if (invalidLines > 0) {
      throw FormatException(
          "Invalid suffix list: $invalidLines/${rules.length} lines are not formatted properly!");
    }
  }

  static bool _isEmpty(String line) => RegExp(r'^\s*$').hasMatch(line);

  static bool _isComment(String line) => line.trimLeft().startsWith('//');

  static bool _isValidRule(String line) =>
      RegExp(r'^!?(?:\*|[^*.!\s][^*.!\s]*)(?:\.(?:[*]|[^*.\s]+))*$')
          .hasMatch(line);

  /// Disposes of the suffix list.
  ///
  /// [hasInitialised] will return [false] after this has been called.
  static void dispose() {
    _rules = null;
  }
}
