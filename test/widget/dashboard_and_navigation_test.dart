import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_queue/providers/auth_provider.dart';
import 'package:agri_queue/providers/booking_provider.dart';
import 'package:agri_queue/providers/language_provider.dart';
import 'package:agri_queue/providers/queue_provider.dart';
import 'package:agri_queue/screens/main_navigation_shell.dart';
import 'package:agri_queue/services/local_storage_service.dart';
import 'package:agri_queue/services/mock_auth_service.dart';
import 'package:agri_queue/services/mock_data_service.dart';

class _NoStretchScrollBehavior extends MaterialScrollBehavior {
  const _NoStretchScrollBehavior();
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

Future<void> pumpFrames(
  WidgetTester tester, [
  Duration duration = const Duration(milliseconds: 400),
]) async {
  await tester.pump();
  await tester.pump(duration);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('MainNavigationShell renders Home tab and switches tabs', (
    WidgetTester tester,
  ) async {
    final storage = LocalStorageService();
    final authService = MockAuthService();
    final dataService = MockDataService();

    final langProvider = LanguageProvider(storage);
    final authProvider = AuthProvider(authService, storage);
    final bookingProvider = BookingProvider(dataService);
    final queueProvider = QueueProvider(dataService);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: langProvider),
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider.value(value: bookingProvider),
          ChangeNotifierProvider.value(value: queueProvider),
        ],
        child: MaterialApp(
          scrollBehavior: const _NoStretchScrollBehavior(),
          home: const MainNavigationShell(),
        ),
      ),
    );

    await pumpFrames(tester);

    // Verify Home elements
    expect(find.text('Rajesh Kumar'), findsOneWidget);
    expect(find.text('Lucknow Central Mandi'), findsWidgets);
    expect(find.text('A-125'), findsOneWidget);
    expect(find.text('Book Your Slot Now'), findsOneWidget);

    // Switch to Live Queue tab
    await tester.tap(find.text('Live Queue'));
    await pumpFrames(tester);

    expect(find.text('Live Mandi Queue'), findsOneWidget);
    expect(find.text('Farmers Ahead'), findsOneWidget);
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.textContaining('Refreshing in'), findsOneWidget);
    expect(find.text('Gate 2'), findsWidgets);

    // Switch to Price tab
    await tester.tap(find.text('Price'));
    await pumpFrames(tester);

    expect(find.text('Mandi Crop Prices'), findsOneWidget);
    expect(find.text('Wheat'), findsOneWidget);
    expect(find.text('Cereals'), findsWidgets);

    // Switch to Profile tab
    await tester.tap(find.text('Profile'));
    await pumpFrames(tester);

    expect(find.text('Farmer Profile'), findsOneWidget);
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });
}
