enum PriceTrend { up, down, stable }

class MarketPrice {
  final String id;
  final String cropName;
  final String category; // Cereals, Oilseeds, Vegetables, Cash Crops
  final double currentPrice;
  final double minPrice;
  final double maxPrice;
  final double changePercentage;
  final PriceTrend trend;
  final double mspPrice;
  final String unit; // 'Quintal', 'Kg'
  final String mandiName;
  final DateTime lastUpdated;

  const MarketPrice({
    required this.id,
    required this.cropName,
    required this.category,
    required this.currentPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.changePercentage,
    required this.trend,
    required this.mspPrice,
    this.unit = 'Quintal',
    required this.mandiName,
    required this.lastUpdated,
  });

  bool get isUp => trend == PriceTrend.up;
  bool get isDown => trend == PriceTrend.down;
}
