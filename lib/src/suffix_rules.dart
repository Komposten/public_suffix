/*
 * Copyright 2019 Jakob Hjelm (Komposten)
 *
 * This file is part of public_suffix.
 *
 * public_suffix is a free Dart library: you can use, redistribute it and/or modify
 * it under the terms of the MIT license as written in the LICENSE file in the root
 * of this project.
 */

import 'package:public_suffix/src/suffix_rules_parser.dart';

/// A Dart-representation of a list of public suffix rules.
///
/// Rules are parsed from either a string or a list and can
/// then be accessed using [rules] or [ruleMap].
class SuffixRules {
  List<Rule> _rules;
  Map<String, Iterable<Rule>> _ruleMap;

  /// Returns an unmodifiable list containing the current rules in the original order.
  List<Rule> get rules => List.unmodifiable(_rules);

  /// Returns an unmodifiable map containing the current rules.
  ///
  /// In each pair in the list the key is a label and the value a list of all
  /// rules that end with that label.
  Map<String, Iterable<Rule>> get ruleMap => Map.unmodifiable(_ruleMap);

  /// Checks whether or not at least this object contains at least one rule.
  bool hasRules() => _rules.isNotEmpty;

  /// Creates a new rule list from a multi-rule string.
  ///
  /// [rules] is expected to contain the contents of a suffix list with one rule per line.
  /// The list is expected to follow the same format as the list at
  /// [publicsuffix.org](https://publicsuffix.org/list/public_suffix_list.dat).
  /// This includes the `BEGIN PRIVATE` and `END PRIVATE` tags/comments,
  /// which are used by [process] to separate ICANN/IANA rules from private rules.
  SuffixRules.fromString(String rules): this.fromList(rules.split(RegExp(r'[\r\n]+')));

  /// Creates a new rule list from a list of rule strings.
  ///
  /// [rules] is expected to contain the contents of a suffix list with one rule
  /// or comment per element. This includes the `BEGIN PRIVATE` and `END PRIVATE`
  /// tags/comments, which are used by [process] to separate ICANN/IANA rules
  /// from private rules.
  /// See [publicsuffix.org](https://publicsuffix.org/list/public_suffix_list.dat)
  /// for the rule format.
  SuffixRules.fromList(List<String> rules) {
    var parser = SuffixRulesParser();
    // TODO jhj: use an empty list if rules is null, and same for fromString and fromRules
    var processed = parser.process(rules);
    parser.validate(processed);
    _setRules(processed);
  }

  /// Creates a new rule list from a list of [Rule]s.
  ///
  /// [rules] will be validated using a [SuffixRulesParser]
  /// and a [FormatException] will be thrown if one or more
  /// rules are invalid.
  SuffixRules.fromRules(List<Rule> rules) {
    var parser = SuffixRulesParser();
    parser.validate(rules);
    _setRules(rules);
  }

  void _setRules(List<Rule> rules) {
    _rules = rules;
    _ruleMap = _listToMap(rules);
  }

  Map<String, Iterable<Rule>> _listToMap(List<Rule> rules) {
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

  List<String> _parts;

  Rule(String rule, {this.isIcann = true})
      : isException = rule.startsWith('!'),
        labels = rule.startsWith('!') ? rule.substring(1) : rule {
    _parts = labels.split('.');
  }

  bool matches(String host) {
    var hostParts = host.split('.')..removeWhere((e) => e.isEmpty);

    if (_parts.length <= hostParts.length) {
      hostParts = hostParts.sublist(hostParts.length - _parts.length);

      for (int i = 0; i < hostParts.length; i++) {
        if (_parts[i] != '*' && _parts[i] != hostParts[i]) {
          return false;
        }
      }

      return true;
    } else {
      return false;
    }
  }

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
