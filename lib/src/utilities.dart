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

class DomainUtils {
  DomainUtils._();

  /// Checks if a URI is a subdomain of another.
  ///
  /// Both URIs are parsed to [PublicSuffix] objects, whose domain and subdomain
  /// properties are then compared to determine if [potentialSub] is a subdomain
  /// of [root]. If [icann] is [true], comparison will be based on only the
  /// ICANN/IANA rules.
  ///
  /// For example, `http://images.google.co.uk` is a subdomain of `http://google.co.uk`.
  ///
  /// If [root] has a subdomain and [potentialSub] is a subdomain of that, [true]
  /// is still returned.
  static bool isSubdomainOf(Uri potentialSub, Uri root, {bool icann = false}) {
    var parsedUri = PublicSuffix(potentialSub);
    var parsedRoot = PublicSuffix(root);

    if (icann) {
      return parsedUri.icannDomain == parsedRoot.icannDomain &&
          parsedUri.icannSubdomain != null &&
          (parsedRoot.icannSubdomain == null ||
              parsedUri.icannSubdomain.endsWith(parsedRoot.icannSubdomain));
    } else {
      return parsedUri.domain == parsedRoot.domain &&
          parsedUri.subdomain != null &&
          (parsedRoot.subdomain == null ||
              parsedUri.subdomain.endsWith(parsedRoot.subdomain));
    }
  }

  /// Checks if a URI is a subdomain or a root domain.
  ///
  /// [potentialSub] is parsed to a [PublicSuffix] object. It is a subdomain if
  /// the [subdomain] property of the object is [null].
  ///
  /// If [icann] is [true], [icannSubdomain] is checked instead.
  static bool isSubdomain(Uri potentialSub, {bool icann = false}) {
    if (icann) {
      return PublicSuffix(potentialSub).icannSubdomain != null;
    } else {
      return PublicSuffix(potentialSub).subdomain != null;
    }
  }
}
