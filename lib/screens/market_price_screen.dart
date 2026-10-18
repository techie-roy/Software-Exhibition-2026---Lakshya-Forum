import 'package:flutter/material.dart';

import '../app/constants.dart';
import '../app/localizations.dart';
import '../models/market_price.dart';
import '../services/market_price_api_service.dart';
import '../services/mock_data_service.dart';
import '../widgets/market_price_card.dart';
import '../widgets/simulated_data_notice.dart';

class MarketPriceScreen extends StatefulWidget {
  const MarketPriceScreen({super.key});

  @override
  State<MarketPriceScreen> createState() => _MarketPriceScreenState();
}

class _MarketPriceScreenState extends State<MarketPriceScreen> {
  final MockDataService _dataService = MockDataService();
  final MarketPriceApiService _priceApi = MarketPriceApiService();
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  /// Real government rows when the data.gov.in fetch succeeded; null keeps
  /// the labelled sample (demo) list. Never mixed: a successful fetch
  /// replaces the demo rows outright.
  List<MarketPrice>? _livePrices;
  bool _fetchAttempted = false;
  bool _fetchDone = false;

  final List<String> _categories = [
    'all',
    'cereals',
    'oilseeds',
    'vegetables',
    'cash_crops',
  ];

  @override
  void initState() {
    super.initState();
    if (_priceApi.isConfigured) {
      _fetchAttempted = true;
      _priceApi.fetchLivePrices().then((rows) {
        if (!mounted) return;
        setState(() {
          _livePrices = (rows != null && rows.isNotEmpty) ? rows : null;
          _fetchDone = true;
        });
      });
    }
  }

  List<MarketPrice> get _prices => _livePrices ?? _dataService.marketPrices;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MarketPrice> _filteredPrices(String localizedCropNames) {
    return _prices.where((price) {
      final matchesCategory =
          _selectedCategory == 'all' || price.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          localizedCropNames.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final searchableText = _prices.map((p) => s.cropName(p.cropName)).join(' ');
    final filteredPrices = _filteredPrices(searchableText);
    final showLive = _livePrices != null;
    // Demo list, or a live feed that failed/returned nothing.
    final showSampleNotice = !showLive && (!_fetchAttempted || _fetchDone);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(s.mandiCropPrices),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: s.searchCrops,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      fillColor: AppColors.scaffoldBackground,
                    ),
                  ),
                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        final catLabel = cat == 'all'
                            ? s.allCrops
                            : s.categoryName(cat);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(catLabel),
                            selected: isSelected,
                            selectedColor: AppColors.primaryGreen,
                            backgroundColor: AppColors.scaffoldBackground,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primaryGreen
                                    : AppColors.borderSubtle,
                              ),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.surfaceSoftMint,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      showLive ? s.priceBannerLive : s.priceBanner,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    s.ratesPerQuintal,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (showLive)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      size: 14,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        s.priceSourceGovt,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            else if (showSampleNotice)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SimulatedDataNotice(
                  margin: EdgeInsets.zero,
                  title: s.simulatedDataLabel,
                  message: _fetchAttempted
                      ? s.livePricesUnavailable
                      : s.simulatedPriceNotice,
                ),
              ),

            Expanded(
              child: filteredPrices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            s.noCropsMatch,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(
                        AppDimensions.paddingMedium,
                      ),
                      itemCount: filteredPrices.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return DetailedMarketPriceCard(
                          price: filteredPrices[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
