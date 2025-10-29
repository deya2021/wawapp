// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `واو أب`
  String get appTitle {
    return Intl.message('واو أب', name: 'appTitle', desc: '', args: []);
  }

  /// `موقع الاستلام`
  String get pickup {
    return Intl.message('موقع الاستلام', name: 'pickup', desc: '', args: []);
  }

  /// `موقع التسليم`
  String get dropoff {
    return Intl.message('موقع التسليم', name: 'dropoff', desc: '', args: []);
  }

  /// `احسب السعر`
  String get get_quote {
    return Intl.message('احسب السعر', name: 'get_quote', desc: '', args: []);
  }

  /// `اطلب الآن`
  String get request_now {
    return Intl.message('اطلب الآن', name: 'request_now', desc: '', args: []);
  }

  /// `تتبع`
  String get track {
    return Intl.message('تتبع', name: 'track', desc: '', args: []);
  }

  /// `أوقية`
  String get currency {
    return Intl.message('أوقية', name: 'currency', desc: '', args: []);
  }

  /// `السعر المقدر`
  String get estimated_price {
    return Intl.message(
      'السعر المقدر',
      name: 'estimated_price',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
