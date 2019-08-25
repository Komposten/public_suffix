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
  static List<Rule> _rules;
  static Map<String, Iterable<Rule>> _ruleMap;

  SuffixRules._();

  /// Returns an unmodifiable list containing the current rules in the original order.
  ///
  /// [null] is returned if the list has not been initialised.
  static List<Rule> get rules =>
      _rules != null ? List.unmodifiable(_rules) : null;

  /// Returns an unmodifiable map containing the current rules.
  ///
  /// In each pair in the list the key is a label and the value a list of all
  /// rules that end with that label.
  /// [null] is returned if the map has not been initialised.
  static Map<String, Iterable<Rule>> get ruleMap =>
      _ruleMap != null ? Map.unmodifiable(_ruleMap) : null;

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
    var processed = process(rules);
    validate(processed);
    _rules = processed;
    _ruleMap = _listToMap(_rules);
  }

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
  /// The resulting list is returned as a list of [Rule]s. If [rules] contains a
  /// line with a comment and the text `BEGIN PRIVATE`, all rules after that line
  /// are marked as `isIcann = false`.
  static List<Rule> process(List<String> rules) {
    var isIcann = true;
    var newList = <Rule>[];

    for (var line in rules) {
      if (_isComment(line) && line.contains("BEGIN PRIVATE")) {
        isIcann = false;
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
  static void validate(List<Rule> rules) {
    int invalidRules = 0;

    for (var rule in rules) {
      if (_isComment(rule.labels) ||
          _isEmpty(rule.labels) ||
          !_isValidRule(rule.labels)) {
        invalidRules++;
      }
    }

    if (invalidRules > 0) {
      throw FormatException(
          "Invalid suffix list: $invalidRules/${rules.length} lines are not formatted properly!");
    }
  }

  static bool _isEmpty(String line) => RegExp(r'^\s*$').hasMatch(line);

  static bool _isComment(String line) => line.trimLeft().startsWith('//');

  static bool _isValidRule(String line) =>
      RegExp(r'^(?:\*|[^*.!\s][^*.!\s]*)(?:\.(?:[*]|[^*.\s]+))*$')
          .hasMatch(line);

  static Map<String, Iterable<Rule>> _listToMap(List<Rule> rules) {
    var map = <String, List<Rule>>{};
    for (var rule in rules) {
      var lastLabel = rule.labels.substring(rule.labels.lastIndexOf('.') + 1);
      if (map.containsKey(lastLabel)) {
        map[lastLabel].add(rule);
      } else {
        var list = <Rule>[rule];
        map[lastLabel] = list;
      }
    }

    return map;
  }

  /// Disposes of the suffix list.
  ///
  /// [hasInitialised] will return [false] after this has been called.
  static void dispose() {
    _rules = null;
  }
}

/// A description of a suffix rule.
class Rule {
  /// The labels making up the rule. For example, `*.uk`.
  ///
  /// Does not contain the exclamation point (!) that marks exception rules.
  final String labels;

  /// If the rule is an exception rule (preceded by a `!` in the original suffix list).
  final bool isException;

  /// If the rule is an ICANN/IANA rule.
  final bool isIcann;

  Rule(String rule, {this.isIcann = true})
      : isException = rule.startsWith('!'),
        labels = rule.startsWith('!') ? rule.substring(1) : rule;

  @override
  String toString() {
    return (isException ? '!' : '') + labels;
  }

  @override
  int get hashCode {
    int result = 1;

    result = 31 * result + (labels != null ? labels.hashCode : 0);
    result = 31 * result + (isException ? 1231 : 1237);
    result = 31 * result + (isIcann ? 1231 : 1237);

    return result;
  }

  @override
  bool operator ==(other) {
    if (identical(this, other)) {
      return true;
    } else if (other == null) {
      return false;
    } else if (runtimeType != other.runtimeType) {
      return false;
    }

    Rule otherRule = other;
    if (labels != otherRule.labels) {
      return false;
    } else if (isException != otherRule.isException) {
      return false;
    } else if (isIcann != otherRule.isIcann) {
      return false;
    } else {
      return true;
    }
  }

  int _compareTo(Rule other) {
    var itr = RuneIterator.at(labels, labels.length);
    var itr2 = RuneIterator.at(other.labels, other.labels.length);
    var diff = 0;

    while (itr.movePrevious() && itr2.movePrevious()) {
      diff = itr.current - itr2.current;

      if (diff != 0) {
        return diff;
      }
    }

    return 0;
  }

  bool operator <=(Rule other) => _compareTo(other) <= 0;

  bool operator <(Rule other) => _compareTo(other) < 0;

  bool operator >=(Rule other) => _compareTo(other) >= 0;

  bool operator >(Rule other) => _compareTo(other) > 0;
}
