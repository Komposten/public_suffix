/*
 * Copyright 2019 Jakob Hjelm (Komposten)
 *
 * This file is part of public_suffix.
 *
 * public_suffix is a free Dart library: you can use, redistribute it and/or modify
 * it under the terms of the MIT license as written in the LICENSE file in the root
 * of this project.
 */

import 'public_suffix_list.dart';

class PublicSuffix {
  final Uri sourceUri;
  String _rootDomain;
  String _publicTld;
  String _registrableDomain;

  String get registrableDomain => _registrableDomain;

  String get rootDomain => _rootDomain;

  String get publicTld => _publicTld;

  PublicSuffix(this.sourceUri) {
    if (!PublicSuffixList.hasInitialised()) {
      throw StateError("PublicSuffixList has not been initialised!");
    }

    _parseUri(sourceUri, PublicSuffixList.suffixList);
  }

  void _parseUri(Uri uri, List<String> suffixList) {
    var host = uri.host.replaceAll(RegExp(r'\.+$'), '').toLowerCase();
    var matchingRules = _findMatchingRules(host, suffixList);
    var prevailingRule = _getPrevailingRule(matchingRules);

    if (prevailingRule.startsWith('!')) {
      prevailingRule = _trimExceptionRule(prevailingRule);
    }

    _publicTld = _getPublicSuffix(host, prevailingRule);
    _rootDomain = _getDomainRoot(uri, _publicTld);

    if (_rootDomain.isNotEmpty) {
      _registrableDomain = "$_rootDomain.$_publicTld";
    }

    print("[$rootDomain]:[$publicTld] => [$registrableDomain]");
  }

  _findMatchingRules(String host, List<String> suffixList) {
    var matches = <String>[];

    for (var rule in suffixList) {
      if (_ruleMatches(rule, host)) {
        matches.add(rule);
      }
    }

    return matches;
  }

  bool _ruleMatches(String rule, String host) {
    var hostParts = host.split(".");
    var ruleParts = rule.split(".");

    hostParts.removeWhere((e) => e.isEmpty);

    var matches = true;

    if (ruleParts.length <= hostParts.length) {
      int r = ruleParts.length - 1;
      int h = hostParts.length - 1;

      while (r >= 0) {
        var rulePart = ruleParts[r];
        var hostPart = hostParts[h];

        if (rulePart != '*' &&
            rulePart != hostPart &&
            rulePart != "!$hostPart") {
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

  String _getPrevailingRule(List<String> matchingRules) {
    String prevailing;
    int longestLength = 0;

    for (String rule in matchingRules) {
      if (rule.startsWith('!')) {
        prevailing = rule;
        break;
      } else {
        var ruleLength = '.'.allMatches(rule).length + 1;
        if (ruleLength > longestLength) {
          longestLength = ruleLength;
          prevailing = rule;
        }
      }
    }

    return prevailing ?? '*';
  }

  String _trimExceptionRule(String prevailingRule) {
    return prevailingRule.substring(prevailingRule.indexOf('.') + 1);
  }

  String _getPublicSuffix(String host, String prevailingRule) {
    var ruleLength = '.'.allMatches(prevailingRule).length + 1;

    var index = host.length;
    for (int i = 0; i < ruleLength; i++) {
      index = host.lastIndexOf('.', index-1);
    }

    if (index == -1) {
      return host;
    } else {
      return host.substring(index + 1);
    }
  }

  String _getDomainRoot(Uri uri, String publicSuffix) {
    var domainRoot = uri.host.substring(0, uri.host.lastIndexOf(publicSuffix));

    if (domainRoot == '.' || domainRoot.isEmpty) {
      domainRoot = '';
    } else {
      domainRoot = domainRoot.substring(
          domainRoot.lastIndexOf('.', domainRoot.length - 2) + 1,
          domainRoot.length - 1);
    }

    return domainRoot;
  }
}
