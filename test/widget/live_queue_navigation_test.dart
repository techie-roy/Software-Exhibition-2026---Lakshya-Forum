import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_queue/app/routes.dart';
import 'package:agri_queue/providers/auth_provider.dart';
import 'package:agri_queue/providers/booking_provider.dart';
import 'package:agri_queue/providers/language_provider.dart';
import 'package:agri_queue/providers/queue_provider.dart';
import 'package:agri_queue/screens/main_navigation_shell.dart';
import 'package:agri_queue/screens/queue_tracking_screen.dart';
import 'package:agri_queue/services/local_storage_service.dart';
import 'package:agri_queue/services/mock_auth_service.dart';
import 'package:agri_queue/services/mock_data_service.dart';

class _NoStretchScrollBehavior extends MaterialScrollBehavior {
  const _NoStretchScrollBehavior();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

Future<void> pumpFrames(WidgetTester tester, [Duration duration = const Duration(milliseconds: 400)]) async {
  await tester.pump();
  await tester.pump(duration);
}

Future<void> pumpThroughPop(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

Widget buildApp({required LanguageProvider lang, required MockDataService data}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: lang),
      ChangeNotifierProvider.value(value: AuthProvider(MockAuthService(), LocalStorageService())),
      ChangeNotifierProvider.value(value: BookingProvider(data)),
      ChangeNotifierProvider.value(value: QueueProvider(data)),
    ],
    child: MaterialApp(
      scrollBehavior: const _NoStretchScrollBehavior(),
      home: const MainNavigationShell(),
      routes: {
        AppRoutes.slotBooking: (_) => const Scaffold(body: Center(child: Text('SLOT_ROUTE_MARKER'))),
      },
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Back on a non-home tab returns to Home; back on Home pops pushed routes',
      (WidgetTester tester) async {
    final storage = LocalStorageService();
    final data = MockDataService();
    final lang = LanguageProvider(storage);

    await tester.pumpWidget(buildApp(lang: lang, data: data));
    await pumpFrames(tester);

    // Switch to Profile tab
    await tester.tap(find.text('Profile'));
    await pumpFrames(tester);
    expect(find.text('Farmer Profile'), findsOneWidget);

    // System back behaves like Android back and returns to the Home tab
    final handled = await tester.binding.handlePopRoute();
    expect(handled, isTrue);
    await pumpThroughPop(tester);
    expect(find.text('Farmer Profile'), findsNothing);
    expect(find.text('Book Your Slot Now'), findsOneWidget);

    // Push a route on top of the shell and verify back pops only that route
    await tester.tap(find.widgetWithText(ElevatedButton, 'Book Slot'));
    await pumpFrames(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('SLOT_ROUTE_MARKER'), findsOneWidget);

    final handled2 = await tester.binding.handlePopRoute();
    expect(handled2, isTrue);
    await pumpThroughPop(tester);
    expect(find.text('SLOT_ROUTE_MARKER'), findsNothing);
    expect(find.widgetWithText(ElevatedButton, 'Book Slot'), findsOneWidget);
  });

  testWidgets('Live queue counts down, auto-refreshes at 30s, and disposes its timer',
      (WidgetTester tester) async {
    final data = MockDataService();
    final queueProvider = QueueProvider(data);
    final lang = LanguageProvider(LocalStorageService());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: lang),
          ChangeNotifierProvider.value(value: queueProvider),
        ],
        child: const MaterialApp(
          scrollBehavior: _NoStretchScrollBehavior(),
          home: QueueTrackingScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    // Countdown starts at 30 seconds and LIVE indicator is visible
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.textContaining('LIVE TOKEN'), findsOneWidget);
    expect(find.text('Refreshing in 30s'), findsOneWidget);
    expect(find.textContaining('Last updated:'), findsOneWidget);

    // After one second the countdown ticks down
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Refreshing in 29s'), findsOneWidget);

    // Advance past the 30s window: the auto-refresh must fire
    final firstRefreshCount = queueProvider.refreshCount;
    await tester.pump(const Duration(seconds: 30));
    await tester.pump(const Duration(milliseconds: 100));
    expect(queueProvider.refreshCount, greaterThan(firstRefreshCount));

    // Unmounting the screen disposes the countdown timer and pulse animation
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}