// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WawApp Client';

  @override
  String get pickup => 'موقع الاستلام';

  @override
  String get dropoff => 'موقع التسليم';

  @override
  String get get_quote => 'احسب السعر';

  @override
  String get request_now => 'اطلب الآن';

  @override
  String get track => 'تتبع';

  @override
  String get currency => 'أوقية';

  @override
  String get estimated_price => 'السعر المقدر';
}
