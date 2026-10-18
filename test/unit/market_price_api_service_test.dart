import 'package:agri_queue/models/market_price.dart';
import 'package:agri_queue/services/market_price_api_service.dart';
import 'package:agri_queue/services/mock_data_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = MarketPriceApiService();
  final wheatMeta = MockDataService().marketPrices.first;

  Map<String, dynamic> record({
    String commodity = 'Wheat',
    String market = 'Krishi Mandi',
    String district = 'Lucknow',
    String arrivalDate = '12/10/2026',
    num minPrice = 2300,
    num maxPrice = 2500,
    num modalPrice = 2400,
  }) => {
    'state': 'Uttar Pradesh',
    'district': district,
    'market': market,
    'commodity': commodity,
    'variety': 'Other',
    'grade': 'Medium',
    'arrival_date': arrivalDate,
    'min_price': minPrice,
    'max_price': maxPrice,
    'modal_price': modalPrice,
  };

  group('MarketPriceApiService honesty', () {
    test('is not configured by default and never pretends a fetch', () async {
      // No --dart-define=DATAGOV_IN_API_KEY in tests or default builds.
      expect(service.isConfigured, isFalse);
      expect(await service.fetchLivePrices(), isNull);
    });

    test('maps a government record without inventing trend movement', () {
      final price = service.debugPriceFromRecord(record(), 'wheat', wheatMeta);

      expect(price, isNotNull);
      expect(price!.cropName, 'wheat');
      expect(price.currentPrice, 2400);
      expect(price.minPrice, 2300);
      expect(price.maxPrice, 2500);
      expect(price.mandiName, 'Krishi Mandi, Lucknow');
      expect(price.lastUpdated, DateTime(2026, 10, 12));
      // The feed has no price history: neutral, never a fabricated arrow.
      expect(price.trend, PriceTrend.stable);
      expect(price.changePercentage, 0);
      // Labels (category/MSP) come from app metadata, not the feed.
      expect(price.category, wheatMeta.category);
      expect(price.mspPrice, wheatMeta.mspPrice);
    });

    test('keeps the record when modal price is missing or zero', () {
      final price = service.debugPriceFromRecord(
        record(modalPrice: 0),
        'wheat',
        wheatMeta,
      );
      // Falls back to the min/max midpoint instead of showing ₹0.
      expect(price!.currentPrice, 2400);
    });

    test('rejects records without usable prices', () {
      final price = service.debugPriceFromRecord(
        record(minPrice: 0, maxPrice: 0, modalPrice: 0),
        'wheat',
        wheatMeta,
      );
      expect(price, isNull);
    });
  });

  group('MarketPriceApiService record selection', () {
    test('picks the newest arrival date', () {
      final best = service.debugLatestRecord([
        record(arrivalDate: '01/09/2026', market: 'Old Bazaar'),
        record(arrivalDate: '12/10/2026', market: 'New Bazaar'),
        record(arrivalDate: '05/10/2026', market: 'Mid Bazaar'),
      ], 'Wheat');
      expect(best!['market'], 'New Bazaar');
    });

    test('ignores rows for other commodities', () {
      final best = service.debugLatestRecord([
        record(commodity: 'Onion'),
        record(commodity: 'Tomato'),
      ], 'Wheat');
      expect(best, isNull);
    });

    test('matches Agmarknet paddy variants such as Paddy(Dhan)', () {
      final best = service.debugLatestRecord([
        record(commodity: 'Paddy(Dhan)-Common'),
      ], 'Paddy');
      expect(best, isNotNull);
    });

    test('handles an unparseable arrival date without throwing', () {
      final best = service.debugLatestRecord([
        record(arrivalDate: 'not-a-date'),
      ], 'Wheat');
      expect(best, isNotNull);
      final price = service.debugPriceFromRecord(best!, 'wheat', wheatMeta);
      expect(price, isNotNull);
      expect(price!.lastUpdated, isNotNull);
    });
  });
}
