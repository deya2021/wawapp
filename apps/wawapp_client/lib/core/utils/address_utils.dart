import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressUtils {
  /// يُفضّل استبدال هذه الدالة لاحقاً بـ geocoding فعلي.
  /// حالياً: يختار userInput إن وجد، وإلا plusCode إن وجد، وإلا lat,lng بشكل مختصر.
  static String friendly({
    String? userInput,
    String? plusCode,
    LatLng? latLng,
  }) {
    if (userInput != null && userInput.trim().isNotEmpty) {
      return userInput.trim();
    }
    if (plusCode != null && plusCode.trim().isNotEmpty) {
      return plusCode.trim();
    }
    if (latLng != null) {
      String d(double v) => v.toStringAsFixed(5);
      return '(${d(latLng.latitude)}, ${d(latLng.longitude)})';
    }
    return 'عنوان غير معروف';
  }
}
