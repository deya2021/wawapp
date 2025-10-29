class Eta {
  /// سرعة افتراضية داخل المدينة ~ 18 كم/س
  static double minutesFromKm(double distanceKm, {double speedKmPerHour = 18}) {
    if (distanceKm <= 0 || speedKmPerHour <= 0) return 0;
    final hours = distanceKm / speedKmPerHour;
    return (hours * 60);
  }
}
