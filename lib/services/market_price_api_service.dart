import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/market_price.dart';
import 'mock_data_service.dart';

/// Live mandi prices from the Government of India's open-data platform.
///
/// Source: data.gov.in resource **"Current Daily Price of Various Commodities
/// from Various Markets (Mandi)"** (Ministry of Agriculture and Farmers
/// Welfare) — resource id `9ef84268-d588-465a-a308-a864a43d0070`,
/// https://www.data.gov.in/resource/current-daily-price-various-commodities-various-markets-mandi
///
/// Key handling: no API key is bundled in the repo. The developer's own
/// api.data.gov.in key is read at build time from
/// `--dart-define=DATAGOV_IN_API_KEY=<key>`. Without it [isConfigured] is
/// false, no network call is ever attempted, and the screens keep their
/// clearly labelled sample (demo) rates — the app never substitutes numbers
/// or pretends a fetch happened.
///
/// Honesty rules enforced here:
/// * a row is only returned when a real government record was parsed;
/// * trend/change stay neutral (stable / 0%) because this feed carries no
///   price history to compute a movement from — nothing is invented;
/// * crop category and MSP come from the app's own static crop metadata
///   (labels), never from the feed.
class MarketPriceApiService {
  MarketPriceApiService({http.Client? client})
    : _client = client ?? http.Client();

  /// Build-time dart-define supplied by the developer. Empty in dev/test
  /// builds and in the default debug APK.
  static const String apiKey = String.fromEnvironment('DATAGOV_IN_API_KEY');

  static const String resourceId = '9ef84268-d588-465a-a308-a864a43d0070';

  final http.Client _client;

  bool get isConfigured => apiKey.isNotEmpty;

  /// Successes are cached for the app session; failures are not cached so a
  /// later screen open can retry after a transient network error.
  static Future<List<MarketPrice>?>? _cachedSuccess;

  /// The app's six displayed crops -> commodity spellings used by the feed.
  /// Paddy appears in Agmarknet both as "Paddy" and as "Paddy(Dhan)"-style
  /// names, so each crop may list several filter candidates.
  static const Map<String, List<String>> commodityNameFor = {
    'wheat': ['Wheat'],
    'paddy': ['Paddy', 'Paddy(Dhan)'],
    'maize': ['Maize'],
    'mustard': ['Mustard'],
    'potato': ['Potato'],
    'sugarcane': ['Sugarcane'],
  };

  /// Returns real rows for whichever of the app's crops the feed returned,
  /// or null when the feed is unconfigured, unreachable, empty, or malformed.
  /// Callers must then show labelled sample (demo) data — never a blend.
  Future<List<MarketPrice>?> fetchLivePrices() {
    if (!isConfigured) return Future.value(null);
    final cached = _cachedSuccess;
    if (cached != null) return cached;
    final fetch = _doFetch();
    _cachedSuccess = fetch;
    return fetch.then((rows) {
      if (rows == null && identical(_cachedSuccess, fetch)) {
        _cachedSuccess = null;
      }
      return rows;
    });
  }

  Future<List<MarketPrice>?> _doFetch() async {
    try {
      final demoPrices = MockDataService().marketPrices;
      final metaByCrop = {
        for (final p in demoPrices) p.cropName.toLowerCase(): p,
      };

      final results = await Future.wait(
        commodityNameFor.entries.map(
          (e) => _fetchCrop(e.key, e.value, metaByCrop),
        ),
      );
      final rows = results.whereType<MarketPrice>().toList();
      if (rows.isEmpty) return null;
      final cropOrder = commodityNameFor.keys.toList();
      rows.sort(
        (a, b) => cropOrder
            .indexOf(a.cropName)
            .compareTo(cropOrder.indexOf(b.cropName)),
      );
      return rows;
    } catch (_) {
      return null;
    }
  }

  /// Fetches the latest available record for one commodity, preferring
  /// Uttar Pradesh markets (the app's demo mandi is in Lucknow) and falling
  /// back to any Indian market when the state has no matching records.
  Future<MarketPrice?> _fetchCrop(
    String cropKey,
    List<String> commodityCandidates,
    Map<String, MarketPrice> metaByCrop,
  ) async {
    for (final commodity in commodityCandidates) {
      for (final state in const ['Uttar Pradesh', null]) {
        final records = await _query(commodity, state: state);
        final best = _latestRecord(records, commodity);
        if (best != null) {
          final price = _toMarketPrice(cropKey, best, metaByCrop[cropKey]);
          if (price != null) return price;
        }
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _query(
    String commodityName, {
    String? state,
  }) async {
    final params = <String, String>{
      'api-key': apiKey,
      'format': 'json',
      'filters[commodity]': commodityName,
      'filters[state]': ?state,
      'limit': '50',
    };
    final uri = Uri.parse('https://api.data.gov.in/resource/$resourceId')
        .replace(queryParameters: params);
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw StateError('HTTP ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unexpected feed payload');
    }
    final records = decoded['records'];
    if (records is! List) return const [];
    return records.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  /// Picks the record with the newest arrival date whose commodity matches
  /// [commodityName] as a prefix (covers variants like "Paddy(Dhan)-Common").
  Map<String, dynamic>? _latestRecord(
    List<Map<String, dynamic>> records,
    String commodityName,
  ) {
    final want = commodityName.toLowerCase();
    Map<String, dynamic>? best;
    DateTime? bestDate;
    for (final record in records) {
      final normalized = (record['commodity'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      if (!normalized.startsWith(want)) continue;
      final date = _parseArrivalDate(record['arrival_date']?.toString());
      if (best == null ||
          (date != null && (bestDate == null || date.isAfter(bestDate)))) {
        best = record;
        bestDate = date ?? bestDate;
      }
    }
    return best;
  }

  static final DateFormat _arrivalFormat = DateFormat('dd/MM/yyyy');

  static DateTime? _parseArrivalDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return _arrivalFormat.parseStrict(raw.trim());
    } catch (_) {
      return null;
    }
  }

  /// Test seam: newest-record selection exactly as the live fetch uses it.
  @visibleForTesting
  Map<String, dynamic>? debugLatestRecord(
    List<Map<String, dynamic>> records,
    String commodityName,
  ) => _latestRecord(records, commodityName);

  /// Test seam: record-to-row mapping exactly as the live fetch uses it.
  @visibleForTesting
  MarketPrice? debugPriceFromRecord(
    Map<String, dynamic> record,
    String cropKey,
    MarketPrice? meta,
  ) => _toMarketPrice(cropKey, record, meta);

  MarketPrice? _toMarketPrice(
    String cropKey,
    Map<String, dynamic> record,
    MarketPrice? meta,
  ) {
    final minPrice = (record['min_price'] as num?)?.toDouble();
    final maxPrice = (record['max_price'] as num?)?.toDouble();
    final modalPrice = (record['modal_price'] as num?)?.toDouble();
    if (minPrice == null || maxPrice == null) return null;
    if (minPrice <= 0 && maxPrice <= 0) return null;
    final current = (modalPrice != null && modalPrice > 0)
        ? modalPrice
        : (minPrice + maxPrice) / 2;

    final market = (record['market'] ?? '').toString().trim();
    final district = (record['district'] ?? '').toString().trim();
    final mandiLabel = [
      if (market.isNotEmpty) market,
      if (district.isNotEmpty) district,
    ].join(', ');

    return MarketPrice(
      id: 'MP-GOV-${cropKey.toUpperCase()}',
      cropName: cropKey,
      category: meta?.category ?? 'cereals',
      currentPrice: current,
      minPrice: minPrice,
      maxPrice: maxPrice,
      // No history in this feed: neutral movement, never an invented arrow.
      changePercentage: 0,
      trend: PriceTrend.stable,
      mspPrice: meta?.mspPrice ?? 0,
      mandiName: mandiLabel.isEmpty ? 'Government of India feed' : mandiLabel,
      lastUpdated:
          _parseArrivalDate(record['arrival_date']?.toString()) ??
          DateTime.now(),
    );
  }
}
