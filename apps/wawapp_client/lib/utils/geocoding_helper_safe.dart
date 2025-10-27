import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeocodingHelper {
  // استخدم مفتاح API من متغيرات البيئة أو ملف منفصل
  static const String _apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY',
      defaultValue: 'YOUR_API_KEY_HERE');

  static Future<String> reverseGeocode(LatLng position) async {
    if (_apiKey == 'YOUR_API_KEY_HERE') {
      // إرجاع عنوان افتراضي إذا لم يتم تعيين المفتاح
      return 'نواكشوط، موريتانيا (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
    }

    try {
      final url = 'https://maps.googleapis.com/maps/api/geocode/json'
          '?latlng=${position.latitude},${position.longitude}'
          '&key=$_apiKey'
          '&language=ar';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'] ?? 'موقع غير محدد';
        }
      }
      return 'فشل في جلب العنوان، تحقق من الاتصال بالإنترنت';
    } catch (e) {
      return 'فشل في جلب العنوان، تحقق من الاتصال بالإنترنت';
    }
  }
}
