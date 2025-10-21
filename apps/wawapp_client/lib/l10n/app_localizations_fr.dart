// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get title => 'WawApp';

  @override
  String get pickup => 'Lieu de ramassage';

  @override
  String get dropoff => 'Lieu de dépôt';

  @override
  String get get_quote => 'Calculer le prix';

  @override
  String get request_now => 'Commander maintenant';

  @override
  String get track => 'Suivre';
}
