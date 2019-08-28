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
  bool _hasKnownSuffix;
  String _root;
  String _suffix;
  String _domain;
  String _subdomain;
  String _icannRoot;
  String _icannSuffix;
  String _icannDomain;
  String _icannSubdomain;

  PublicSuffix _punyDecoded;

  /// Returns the registrable domain part of the URI, based on both ICANN/IANA and private rules.
  ///
  /// The registrable domain is the public suffix and one preceding label.
  /// For example, `images.google.co.uk` has the registrable domain `google.co.uk`.
  String get domain => _domain;

  /// Returns the subdomain part of the URI, based on both ICANN/IANA and private rules.
  ///
  /// The subdomain is the part of the host that precedes the registrable domain
  /// (see [domain]).
  /// For example, `images.google.co.uk` has the subdomain `images`.
  String get subdomain => _subdomain;

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

  /// Returns the subdomain part of the URI, based on ICANN/IANA rules.
  ///
  /// The subdomain is the part of the host that precedes the registrable domain
  /// (see [domain]).
  /// For example, `images.google.co.uk` has the subdomain `images`.
  String get icannSubdomain => _icannSubdomain;

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

  /// Whether the [suffix] is a known suffix or not.
  ///
  /// A known suffix is one which has a rule in the suffix rule list.
  bool hasKnownSuffix() => _hasKnownSuffix;

  /// Checks if the registrable domain is valid.
  ///
  /// If [icann] is [true] the check will be based on [icannDomain], otherwise
  /// [domain] is used.
  /// If [acceptDefaultRule] is [false] URLs with suffixes only matching the
  /// default rule (`*`) will be seen as invalid.
  bool hasValidDomain({bool icann = false, bool acceptDefaultRule = true}) {
    var _domain = (icann ? icannDomain : domain);

    if (acceptDefaultRule || hasKnownSuffix()) {
      return _domain != null;
    } else {
      return false;
    }
  }

  /// Checks if this object represents a subdomain of another.
  ///
  /// The domain and subdomain properties are compared to determine if
  /// this object represents a subdomain of [other]. If [icann] is [true],
  /// comparison will be based on only the ICANN/IANA rules.
  ///
  /// For example, `http://images.google.co.uk` is a subdomain of `http://google.co.uk`.
  ///
  /// If [other] has a subdomain and this object represents a subdomain of that,
  /// [true] is still returned.
  bool isSubdomainOf(PublicSuffix other, {bool icann = false}) {
    if (icann) {
      return icannDomain == other.icannDomain &&
          icannSubdomain != null &&
          (other.icannSubdomain == null ||
              icannSubdomain.endsWith(other.icannSubdomain));
    } else {
      return domain == other.domain &&
          subdomain != null &&
          (other.subdomain == null || subdomain.endsWith(other.subdomain));
    }
  }

  PublicSuffix._(this.sourceUri, String host, this._root, this._suffix,
      this._icannRoot, this._icannSuffix) {
    _domain = _buildRegistrableDomain(_root, _suffix);
    _icannDomain = _buildRegistrableDomain(_icannRoot, _icannSuffix);
    _subdomain = _getSubdomain(host, _domain);
    _icannSubdomain = _getSubdomain(host, _icannDomain);
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

    _parseUri(sourceUri, SuffixRules.ruleMap);
  }

  void _parseUri(Uri uri, Map<String, Iterable<Rule>> suffixMap) {
    var host = _decodeHost(uri);
    var matchingRules = _findMatchingRules(host, suffixMap);
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
    _subdomain = allData['sub'];
    _icannSuffix = icannData['suffix'];
    _icannRoot = icannData['root'];
    _icannDomain = icannData['registrable'];
    _icannSubdomain = icannData['sub'];
    _hasKnownSuffix = (prevailingAllRule.labels != "*");

    var puny = allData['puny'];
    var icannPuny = icannData['puny'];

    _punyDecoded = PublicSuffix._(sourceUri, host, puny['root'], puny['suffix'],
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
      String host, Map<String, Iterable<Rule>> suffixMap) {
    var icannMatches = <Rule>[];
    var allMatches = <Rule>[];

    var lastLabel = host.substring(host.lastIndexOf(('.')) + 1);
    var suffixList = suffixMap[lastLabel];

    if (suffixList != null) {
      for (var rule in suffixList) {
        if (rule.matches(host)) {
          allMatches.add(rule);

          if (rule.isIcann) {
            icannMatches.add(rule);
          }
        }
      }
    }

    return {'icann': icannMatches, 'all': allMatches};
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
      host = _punyEncode(host);
      suffix = _punyEncode(suffix);
      root = _punyEncode(root);
    }

    var registrable = _buildRegistrableDomain(root, suffix);
    var sub = _getSubdomain(host, registrable);

    return {
      'suffix': suffix,
      'root': root,
      'puny': puny,
      'registrable': registrable,
      'sub': sub
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

  String _getSubdomain(String host, String registrableDomain) {
    var sub;

    if (registrableDomain != null) {
      var index = host.lastIndexOf(registrableDomain);

      if (index > 0) {
        sub = host.substring(0, index - 1);
      }
    }

    return sub;
  }
}
