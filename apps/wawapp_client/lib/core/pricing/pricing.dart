class PricingConfig {
  static const int base = 60;
  static const int perKm = 20;
  static const int minFare = 100;
}

class Pricing {
  static int roundTo5(num v) => (v / 5).round() * 5;

  static ({int total, int base, int distancePart, int rounded, double km})
      compute(double km) {
    const base = PricingConfig.base;
    final distancePart = (PricingConfig.perKm * km).round();
    final total = base + distancePart;
    final withMin =
        total < PricingConfig.minFare ? PricingConfig.minFare : total;
    final rounded = roundTo5(withMin);
    return (
      total: total,
      base: base,
      distancePart: distancePart,
      rounded: rounded,
      km: km
    );
  }
}
