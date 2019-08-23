/*
 * Copyright 2019 Jakob Hjelm (Komposten)
 *
 * This file is part of public_suffix.
 *
 * public_suffix is a free Dart library: you can use, redistribute it and/or modify
 * it under the terms of the MIT license as written in the LICENSE file in the root
 * of this project.
 */
class PublicSuffixList {
  static List<String> _suffixList;

  /// Returns the current suffix list.
  ///
  /// If the list has been initialised, an unmodifiable version is returned.
  /// Otherwise [null] is returned.
  static List<String> get suffixList =>
      _suffixList != null ? List.unmodifiable(_suffixList) : null;

  /// Checks if the suffix list has been initialised.
  static bool hasInitialised() => _suffixList != null;

  /// Initialises the suffix list.
  ///
  /// [suffixListText] is expected to contain the contents of a suffix list across multiple lines,
  /// like the file at [publicsuffix.org](https://publicsuffix.org/list/public_suffix_list.dat).
  static void initFromString(String suffixListText) {
    initFromList(suffixListText.split(RegExp(r"[\r\n]+")));
  }

  /// Initialises the suffix list.
  ///
  /// [suffixListLines] is expected to be the individual lines of a suffix list like the one at
  /// [publicsuffix.org](https://publicsuffix.org/list/public_suffix_list.dat).
  static void initFromList(List<String> suffixListLines) {
    suffixListLines = process(suffixListLines);
    validate(suffixListLines);
    _suffixList = suffixListLines;
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
  /// The resulting list is returned as a new instance, so that the original
  /// [suffixListLines] remains untouched.
  static List<String> process(List<String> suffixListLines) {
    var newList = <String>[];

    for (var line in suffixListLines) {
      if (!_isComment(line) && !_isEmpty(line)) {
        var firstSpace = line.indexOf(' ');

        if (firstSpace != -1) {
          line = line.substring(0, firstSpace).trim();
        }

        newList.add(line);
      }
    }

    return newList;
  }

  /// Validates the format of the provided data.
  ///
  /// The content of [suffixListLines] is validated against the expected format
  /// is described on [publicsuffix.org](https://publicsuffix.org/list/).
  /// [suffixListLines] is expected to first have been passed through [process].
  ///
  /// In brief:
  ///
  /// * Rules should not start with a period (.)
  /// * Rules may contain asterisks (*) as wildcards
  ///     * Wildcards must be surrounded by periods or line start/end
  ///     * Example: `*.uk` is valid, `c*.uk` is not
  /// * Rules that start with exclamation marks (!) mark exceptions to previous rules
  ///     * Example: `!co.uk` would exclude `co.uk` from `*.uk`
  ///
  /// If at least one rule in the list is invalid, a [FormatException] is thrown
  /// containing information about the amount of invalid lines.
  static void validate(List<String> suffixListLines) {
    int invalidLines = 0;

    for (var line in suffixListLines) {
      if (_isComment(line) || _isEmpty(line) || !_isValidRule(line)) {
        invalidLines++;
      }
    }

    if (invalidLines > 0) {
      throw FormatException(
          "Invalid suffix list: $invalidLines/${suffixListLines.length} lines are not formatted properly!");
    }
  }

  static bool _isEmpty(String line) => RegExp(r"^\s*$").hasMatch(line);

  static bool _isComment(String line) => line.trimLeft().startsWith('//');

  static bool _isValidRule(String line) =>
      RegExp(r"^!?(?:\*|[^*.!\s][^*.!\s]*)(?:\.(?:[*]|[^*.\s]+))*$")
          .hasMatch(line);

  /// Disposes of the suffix list.
  ///
  /// [hasInitialised] will return [false] after this has been called.
  static void dispose() {
    _suffixList = null;
  }
}
