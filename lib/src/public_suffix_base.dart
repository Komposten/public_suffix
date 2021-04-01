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
import 'package:punycode/punycode.dart';

import 'suffix_rules.dart';

/// A description of the public suffix, root domain and registrable domain for a URL.
class PublicSuffix {
  late final Uri _sourceUrl;

  bool _sourcePunycoded = false;
  late final bool _hasKnownSuffix;
  late final String _root;
  late final String _suffix;
  String? _domain;
  String? _subdomain;

  late final String _icannRoot;
  late final String _icannSuffix;
  String? _icannDomain;
  String? _icannSubdomain;

  late final PublicSuffix _punyDecoded;

  Uri get sourceUrl => _sourceUrl;

  /// Returns the registrable domain part of the URL, based on both ICANN/IANA and private rules.
  ///
  /// The registrable domain is the public suffix and one preceding label.
  /// For example, `images.google.co.uk` has the registrable domain `google.co.uk`.
  String? get domain => _domain;

  /// Returns the subdomain part of the URL, based on both ICANN/IANA and private rules.
  ///
  /// The subdomain is the part of the host that precedes the registrable domain
  /// (see [domain]).
  /// For example, `images.google.co.uk` has the subdomain `images`.
  String? get subdomain => _subdomain;

  /// Returns the root domain part of the URL, based on both ICANN/IANA and private rules.
  ///
  /// The root domain is the label that precedes the public suffix.
  /// For example, `images.google.co.uk` has the root domain `google`.
  String get root => _root;

  /// Returns the public suffix part of the URL, based on both ICANN/IANA and private rules.
  ///
  /// The public suffix is the labels at the end of the URL which are not controlled
  /// by the registrant of the domain.
  /// For example, `images.google.co.uk` has the public suffix `co.uk`.
  String get suffix => _suffix;

  /// Returns the registrable domain part of the URL, based on ICANN/IANA rules.
  ///
  /// The registrable domain is the public suffix and one preceding label.
  /// For example, `images.google.co.uk` has the registrable domain `google.co.uk`.
  String? get icannDomain => _icannDomain;

  /// Returns the subdomain part of the URL, based on ICANN/IANA rules.
  ///
  /// The subdomain is the part of the host that precedes the registrable domain
  /// (see [domain]).
  /// For example, `images.google.co.uk` has the subdomain `images`.
  String? get icannSubdomain => _icannSubdomain;

  /// Returns the root domain part of the URL, based on ICANN/IANA rules.
  ///
  /// The root domain is the label that precedes the public suffix.
  /// For example, `images.google.co.uk` has the root domain `google`.
  String get icannRoot => _icannRoot;

  /// Returns the public suffix part of the URL, based on ICANN/IANA rules.
  ///
  /// The public suffix is the labels at the end of the URL which are not controlled
  /// by the registrant of the domain.
  /// For example, `images.google.co.uk` has the public suffix `co.uk`.
  String get icannSuffix => _icannSuffix;

  /// Returns a punycode decoded version of this object.
  PublicSuffix get punyDecoded => _punyDecoded;

  /// Checks if the URL was matched with a private rule rather than an ICANN/IANA rule.
  ///
  /// If `true`, then [root], [suffix] and [domain] will be different from the
  /// `icann`-prefixed getters.
  bool isPrivateSuffix() => icannSuffix != _suffix;

  /// Whether the [suffix] is a known suffix or not.
  ///
  /// A known suffix is one which has a rule in the suffix rule list.
  bool hasKnownSuffix() => _hasKnownSuffix;

  /// Checks if the registrable domain is valid.
  ///
  /// If [icann] is `true` the check will be based on [icannDomain], otherwise
  /// [domain] is used.
  /// If [acceptDefaultRule] is `false` URLs with suffixes only matching the
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
  /// this object represents a subdomain of [other]. If [icann] is `true`,
  /// comparison will be based on only the ICANN/IANA rules.
  ///
  /// For example, `http://images.google.co.uk` is a subdomain of `http://google.co.uk`.
  ///
  /// If [other] has a subdomain and this object represents a subdomain of that,
  /// `true` is still returned.
  bool isSubdomainOf(PublicSuffix other, {bool icann = false}) {
    if (icann) {
      return icannDomain == other.icannDomain &&
          icannSubdomain != null &&
          (other.icannSubdomain == null ||
              icannSubdomain!.endsWith(other.icannSubdomain!));
    } else {
      return domain == other.domain &&
          subdomain != null &&
          (other.subdomain == null || subdomain!.endsWith(other.subdomain!));
    }
  }

  /// An alternative to the default constructor with adjustable
  /// leniency for invalid URLs.
  ///
  /// [leniency] specifies how an invalid URL should be handled. An
  /// invalid URL is a URL that is null, empty, missing the authority
  /// component or not formatted as a URI format. The default is
  /// [Leniency.allowEmptyUrl].
  ///
  /// - [Leniency.strict]: All invalid URLs will throw either an
  /// [ArgumentError] (if the URL is null, empty or missing the
  /// authority component) or a [FormatException] (if the URI has
  /// an invalid format). This is the same as using the default
  /// constructor.
  /// - [Leniency.allowEmptyUrl]: `null` is returned if the URL is null
  /// or empty. Other invalid URLs will still throw.
  /// - [Leniency.allowAll]: `null` is returned if the URL is in any
  /// way invalid.
  ///
  /// [suffixRules] can be used to specify the rules to be used when
  /// parsing the URL. If not specified, [DefaultSuffixRules.rules] will
  /// be used.
  static PublicSuffix? fromString(String? url,
      {SuffixRules? suffixRules, Leniency leniency = Leniency.allowEmptyUrl}) {
    try {
      return PublicSuffix(urlString: url, suffixRules: suffixRules);
    } catch (e) {
      if (leniency == Leniency.allowAll ||
          (leniency == Leniency.allowEmptyUrl &&
              (url == null || url.isEmpty))) {
        return null;
      }

      rethrow;
    }
  }

  /// An alternative to the default constructor with adjustable
  /// leniency for invalid URLs.
  ///
  /// [leniency] specifies how an invalid URL should be handled. An
  /// invalid URL is a URL that is null, empty, missing the authority
  /// component or not formatted as a URI format.
  ///
  /// - [Leniency.strict]: All invalid URLs will throw either an
  /// [ArgumentError] (if the URL is null, empty or missing the
  /// authority component) or a [FormatException] (if the URI has
  /// an invalid format). This is the same as using the default
  /// constructor.
  /// - [Leniency.allowEmptyUrl]: `null` is returned if the URL is null
  /// or empty. Other invalid URLs will still throw.
  /// - [Leniency.allowAll]: `null` is returned if the URL is in any
  /// way invalid.
  ///
  /// [suffixRules] can be used to specify the rules to be used when
  /// parsing the URL. If not specified, [DefaultSuffixRules.rules] will
  /// be used.
  static PublicSuffix? fromUrl(Uri? url,
      {SuffixRules? suffixRules, Leniency leniency = Leniency.allowEmptyUrl}) {
    try {
      return PublicSuffix(url: url, suffixRules: suffixRules);
    } catch (e) {
      if (leniency == Leniency.allowAll ||
          (leniency == Leniency.allowEmptyUrl &&
              (url == null || url.toString().isEmpty))) {
        return null;
      }

      rethrow;
    }
  }

  PublicSuffix._(this._sourceUrl, String host, this._root, this._suffix,
      this._icannRoot, this._icannSuffix,
      {required bool hasKnownSuffix})
      : _hasKnownSuffix = hasKnownSuffix {
    _domain = _buildRegistrableDomain(_root, _suffix);
    _icannDomain = _buildRegistrableDomain(_icannRoot, _icannSuffix);
    _subdomain = _getSubdomain(host, _domain);
    _icannSubdomain = _getSubdomain(host, _icannDomain);

    _punyDecoded = this;
  }

  /// Creates a new instance from a URL.
  ///
  /// Either [url] or [urlString] must be specified.
  ///
  /// [suffixRules] can be used to specify the rules to be used when
  /// parsing the URL. If not specified, [DefaultSuffixRules.rules] will
  /// be used.
  ///
  /// Throws a [StateError] if [suffixRules] is null and [DefaultSuffixRules]
  /// has not been initialised.
  ///
  /// Throws an [ArgumentError] if [sourceUrl] is missing the authority component
  /// (e.g. if no protocol is specified).
  PublicSuffix({Uri? url, String? urlString, SuffixRules? suffixRules}) {
    if (url == null && urlString == null) {
      throw ArgumentError('Either url or urlString must be specified!');
    }

    _sourceUrl = url ?? Uri.parse(urlString!);
    if (!sourceUrl.hasAuthority) {
      throw ArgumentError(
          'The URL is missing the authority component: $sourceUrl');
    }

    suffixRules ??= DefaultSuffixRules.rulesOrThrow();
    _parseUrl(sourceUrl, suffixRules.ruleMap);
  }

  void _parseUrl(Uri url, Map<String, Iterable<Rule>> suffixMap) {
    var host = _decodeHost(url);
    var matchingRules = _findMatchingRules(host, suffixMap);
    var prevailingIcannRule = _getPrevailingRule(matchingRules['icann']!);
    var prevailingAllRule = _getPrevailingRule(matchingRules['all']!);

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
    _hasKnownSuffix = (prevailingAllRule.labels != '*');

    var puny = allData['puny'];
    var icannPuny = icannData['puny'];

    _punyDecoded = PublicSuffix._(sourceUrl, host, puny['root'], puny['suffix'],
        icannPuny['root'], icannPuny['suffix'],
        hasKnownSuffix: _hasKnownSuffix);
  }

  String _decodeHost(Uri url) {
    var host = url.host.replaceAll(RegExp(r'\.+$'), '').toLowerCase();
    host = Uri.decodeComponent(host);

    var punycodes = RegExp(r'xn--[a-z0-9-]+').allMatches(host);

    if (punycodes.isNotEmpty) {
      _sourcePunycoded = true;
      var offset = 0;
      punycodes.forEach((match) {
        var decoded = punycodeDecode(match.group(0)!.substring(4));
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
    Rule? prevailing;
    var longestLength = 0;

    for (var rule in matchingRules) {
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
    for (var i = 0; i < ruleLength; i++) {
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

      if (puny != '$part-' && puny != part) {
        return 'xn--$puny';
      } else {
        return part;
      }
    }).join('.');
  }

  String? _buildRegistrableDomain(String root, String? suffix) {
    return (root.isNotEmpty ? '$root.$suffix' : null);
  }

  String? _getSubdomain(String host, String? registrableDomain) {
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

enum Leniency { strict, allowEmptyUrl, allowAll }
