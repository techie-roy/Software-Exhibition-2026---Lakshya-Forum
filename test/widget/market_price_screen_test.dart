import 'package:agri_queue/providers/language_provider.dart';
import 'package:agri_queue/screens/market_price_screen.dart';
import 'package:agri_queue/services/local_storage_service.dart';
import 'package:agri_queue/services/mock_data_service.dart';
import 'package:agri_queue/widgets/market_price_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget wrap(Widget child) {
    final storage = LocalStorageService();
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(storage),
      child: MaterialApp(home: child),
    );
  }

  testWidgets('market price screen labels sample rates without a gov key', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const MarketPriceScreen()));
    await tester.pump();

    // No data.gov.in key in the default build: the screen must say the rates
    // are sample data and must not imply a live government feed.
    expect(find.text('Sample Rates • Demo Data'), findsOneWidget);
    expect(find.text('SIMULATED DATA'), findsOneWidget);
    expect(find.text('Live Mandi Rates'), findsNothing);
    expect(find.textContaining('not a live mandi feed'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('dashboard price card discloses its sample rates', (
    WidgetTester tester,
  ) async {
    final price = MockDataService().marketPrices.first;
    await tester.pumpWidget(
      wrap(
        Scaffold(
          body: DashboardMarketPriceCard(price: price, onViewAll: () {}),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('Sample rates (demo data) — not a live mandi feed'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
