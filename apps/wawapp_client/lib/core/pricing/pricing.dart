class PricingConfig {
  static const double baseFare = 60; // MRU
  static const double perKm = 20; // MRU/km
  static const double minFare = 60; // minimum fare
}

double computePrice(double distanceKm) {
  final p = PricingConfig.baseFare + (distanceKm * PricingConfig.perKm);
  return p < PricingConfig.minFare ? PricingConfig.minFare : p;
}
