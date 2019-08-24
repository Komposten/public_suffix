/*
 * Copyright 2019 Jakob Hjelm (Komposten)
 *
 * This file is part of public_suffix.
 *
 * public_suffix is a free Dart library: you can use, redistribute it and/or modify
 * it under the terms of the MIT license as written in the LICENSE file in the root
 * of this project.
 */

import 'package:punycode/punycode.dart';

import 'suffix_rules.dart';

/// A description of the public suffix, root domain and registrable domain for a URI.
class PublicSuffix {
  final Uri sourceUri;

  bool _sourcePunycoded = false;
  String _root;
  String _suffix;
  String _domain;
  String _icannRoot;
  String _icannSuffix;
  String _icannDomain;

  PublicSuffix _punyDecoded;

  /// Returns the registrable domain part of the URI, based on both ICANN/IANA and private rules.
  ///
  /// The registrable domain is the public suffix and one preceding label.
  /// For example, `images.google.co.uk` has the registrable domain `google.co.uk`.
  String get domain => _domain;

  /// Returns the root domain part of the URI, based on both ICANN/IANA and private rules.
  ///
  /// The root domain is the label that precedes the public suffix.
  /// For example, `images.google.co.uk` has the root domain `google`.
  String get root => _root;

  /// Returns the public suffix part of the URI, based on both ICANN/IANA and private rules.
  ///
  /// The public suffix is the labels at the end of the URL which are not controlled
  /// by the registrant of the domain.
  /// For example, `images.google.co.uk` has the public suffix `co.uk`.
  String get suffix => _suffix;

  /// Returns the registrable domain part of the URI, based on ICANN/IANA rules.
  ///
  /// The registrable domain is the public suffix and one preceding label.
  /// For example, `images.google.co.uk` has the registrable domain `google.co.uk`.
  String get icannDomain => _icannDomain;

  /// Returns the root domain part of the URI, based on ICANN/IANA rules.
  ///
  /// The root domain is the label that precedes the public suffix.
  /// For example, `images.google.co.uk` has the root domain `google`.
  String get icannRoot => _icannRoot;

  /// Returns the public suffix part of the URI, based on ICANN/IANA rules.
  ///
  /// The public suffix is the labels at the end of the URL which are not controlled
  /// by the registrant of the domain.
  /// For example, `images.google.co.uk` has the public suffix `co.uk`.
  String get icannSuffix => _icannSuffix;

  /// Returns a punycode decoded version of this object.
  PublicSuffix get punyDecoded => _punyDecoded;

  /// Checks if the URI was matched with a private rule rather than an ICANN/IANA rule.
  ///
  /// If [true], then [root], [suffix] and [domain] will be different from the
  /// `icann`-prefixed getters.
  bool isPrivateSuffix() => icannSuffix != _suffix;

  PublicSuffix._(this.sourceUri, this._root, this._suffix, this._icannRoot,
      this._icannSuffix) {
    _domain = _buildRegistrableDomain(_root, _suffix);
    _icannDomain = _buildRegistrableDomain(_icannRoot, _icannSuffix);
  }

  /// Creates a new instance based on the specified [sourceUri].
  ///
  /// Throws a [StateError] if [SuffixRules] has not been initialised.
  ///
  /// Throws an [ArgumentError] if [sourceUri] is missing the authority component
  /// (e.g. if no protocol is specified).
  PublicSuffix(this.sourceUri) {
    if (!SuffixRules.hasInitialised()) {
      throw StateError('PublicSuffixList has not been initialised!');
    }
    if (!sourceUri.hasAuthority) {
      throw ArgumentError(
          "The URI is missing the authority component: $sourceUri");
    }

    _parseUri(sourceUri, SuffixRules.rules);
  }

  void _parseUri(Uri uri, List<Rule> suffixList) {
    var host = _decodeHost(uri);
    var matchingRules = _findMatchingRules(host, suffixList);
    var prevailingIcannRule = _getPrevailingRule(matchingRules['icann']);
    var prevailingAllRule = _getPrevailingRule(matchingRules['all']);

    if (prevailingIcannRule.isException) {
      prevailingIcannRule = _trimExceptionRule(prevailingIcannRule);
    }

    if (prevailingAllRule.isException) {
      prevailingAllRule = _trimExceptionRule(prevailingAllRule);
    }

    var allData = _applyRule(host, prevailingAllRule);
    var icannData = _applyRule(host, prevailingIcannRule);

    _suffix = allData['suffix'];
    _root = allData['root'];
    _domain = allData['registrable'];
    _icannSuffix = icannData['suffix'];
    _icannRoot = icannData['root'];
    _icannDomain = icannData['registrable'];

    var puny = allData['puny'];
    var icannPuny = icannData['puny'];

    _punyDecoded = PublicSuffix._(sourceUri, puny['root'], puny['suffix'],
        icannPuny['root'], icannPuny['suffix']);
  }

  String _decodeHost(Uri uri) {
    var host = uri.host.replaceAll(RegExp(r'\.+$'), '').toLowerCase();
    host = Uri.decodeComponent(host);

    var punycodes = RegExp(r'xn--[a-z0-9-]+').allMatches(host);

    if (punycodes.isNotEmpty) {
      _sourcePunycoded = true;
      int offset = 0;
      punycodes.forEach((match) {
        var decoded = punycodeDecode(match.group(0).substring(4));
        host = host.replaceRange(
            match.start - offset, match.end - offset, decoded);
        offset += (match.end - match.start) - decoded.length;
      });
    }

    return host;
  }

  Map<String, List<Rule>> _findMatchingRules(
      String host, List<Rule> suffixList) {
    var icannMatches = <Rule>[];
    var allMatches = <Rule>[];

    for (var rule in suffixList) {
      if (_ruleMatches(rule, host)) {
        allMatches.add(rule);

        if (rule.isIcann) {
          icannMatches.add(rule);
        }
      }
    }

    return {'icann': icannMatches, 'all': allMatches};
  }

  bool _ruleMatches(Rule rule, String host) {
    var hostParts = host.split('.');
    var ruleParts = rule.labels.split('.');

    hostParts.removeWhere((e) => e.isEmpty);

    var matches = true;

    if (ruleParts.length <= hostParts.length) {
      int r = ruleParts.length - 1;
      int h = hostParts.length - 1;

      while (r >= 0) {
        var rulePart = ruleParts[r];
        var hostPart = hostParts[h];

        if (rulePart != '*' && rulePart != hostPart) {
          matches = false;
          break;
        }

        r--;
        h--;
      }
    } else {
      matches = false;
    }

    return matches;
  }

  Rule _getPrevailingRule(List<Rule> matchingRules) {
    Rule prevailing;
    int longestLength = 0;

    for (Rule rule in matchingRules) {
      if (rule.isException) {
        prevailing = rule;
        break;
      } else {
        var ruleLength = '.'.allMatches(rule.labels).length + 1;
        if (ruleLength > longestLength) {
          longestLength = ruleLength;
          prevailing = rule;
        }
      }
    }

    return prevailing ?? Rule('*', isIcann: true);
  }

  Rule _trimExceptionRule(Rule prevailingRule) {
    var labels = prevailingRule.labels;
    labels = labels.substring(labels.indexOf('.') + 1);

    return Rule(labels, isIcann: prevailingRule.isIcann);
  }

  Map<String, dynamic> _applyRule(String host, Rule rule) {
    var suffix = _getPublicSuffix(host, rule);
    var root = _getDomainRoot(host, suffix);
    var puny = {'root': root, 'suffix': suffix};

    if (_sourcePunycoded) {
      suffix = _punyEncode(suffix);
      root = _punyEncode(root);
    }

    var registrable = _buildRegistrableDomain(root, suffix);

    return {
      'suffix': suffix,
      'root': root,
      'puny': puny,
      'registrable': registrable
    };
  }

  String _getPublicSuffix(String host, Rule prevailingRule) {
    var ruleLength = '.'.allMatches(prevailingRule.labels).length + 1;

    var index = host.length;
    for (int i = 0; i < ruleLength; i++) {
      index = host.lastIndexOf('.', index - 1);
    }

    if (index == -1) {
      return host;
    } else {
      return host.substring(index + 1);
    }
  }

  String _getDomainRoot(String host, String publicSuffix) {
    var domainRoot = host.substring(0, host.lastIndexOf(publicSuffix));

    if (domainRoot == '.' || domainRoot.isEmpty) {
      domainRoot = '';
    } else {
      domainRoot = domainRoot.substring(
          domainRoot.lastIndexOf('.', domainRoot.length - 2) + 1,
          domainRoot.length - 1);
    }

    return domainRoot;
  }

  String _punyEncode(String input) {
    return input.split('.').map((part) {
      var puny = punycodeEncode(part);

      if (puny != "$part-" && puny != part) {
        return "xn--$puny";
      } else {
        return part;
      }
    }).join('.');
  }

  String _buildRegistrableDomain(String root, String suffix) {
    return (root.isNotEmpty ? "$root.$suffix" : null);
  }
}
