import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_queue/providers/auth_provider.dart';
import 'package:agri_queue/providers/booking_provider.dart';
import 'package:agri_queue/providers/language_provider.dart';
import 'package:agri_queue/providers/queue_provider.dart';
import 'package:agri_queue/screens/home_screen.dart';
import 'package:agri_queue/screens/procurement_screen.dart';
import 'package:agri_queue/screens/queue_tracking_screen.dart';
import 'package:agri_queue/services/local_storage_service.dart';
import 'package:agri_queue/services/mock_auth_service.dart';
import 'package:agri_queue/services/mock_data_service.dart';

Future<void> pumpFrames(
  WidgetTester tester, [
  Duration duration = const Duration(milliseconds: 400),
]) async {
  await tester.pump();
  await tester.pump(duration);
}

Widget _wrap(MockDataService dataService, Widget child) {
  final storage = LocalStorageService();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: LanguageProvider(storage)),
      ChangeNotifierProvider.value(
        value: AuthProvider(MockAuthService(), storage),
      ),
      ChangeNotifierProvider.value(value: BookingProvider(dataService)),
      ChangeNotifierProvider.value(value: QueueProvider(dataService)),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('queue screen discloses simulated data instead of a live feed', (
    WidgetTester tester,
  ) async {
    final data = MockDataService();
    await tester.pumpWidget(_wrap(data, const QueueTrackingScreen()));
    await pumpFrames(tester);

    expect(find.text('SIMULATED DATA'), findsOneWidget);
    expect(find.textContaining('simulated demo values'), findsOneWidget);
    // The old production-sounding "LIVE" badge is no longer shown.
    expect(find.text('LIVE'), findsNothing);
    expect(find.text('DEMO'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('payment tab discloses simulated transactions and UTR values', (
    WidgetTester tester,
  ) async {
    final data = MockDataService();
    await tester.pumpWidget(_wrap(data, const ProcurementScreen()));
    await pumpFrames(tester);

    // Mandi Bookings opens first; Payment History is the second tab.
    await tester.tap(find.text('Payment History'));
    await pumpFrames(tester);

    expect(find.textContaining('Sample transactions'), findsOneWidget);
    expect(find.textContaining('not real bank settlements'), findsOneWidget);

    // Open the slip for a transaction whose stored UTR is a placeholder token.
    final sentinel = find.textContaining('TXN-994980');
    await tester.ensureVisible(sentinel);
    await pumpFrames(tester);
    await tester.tap(sentinel);
    await pumpFrames(tester);

    // The raw placeholder token is replaced with a human, honest label.
    expect(find.text('PENDING_BANK_CLEARANCE'), findsNothing);
    expect(find.text('Awaiting bank clearance (demo)'), findsOneWidget);

    // The action no longer claims a completed file download.
    expect(find.text('Preview E-Slip (Demo)'), findsOneWidget);
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Preview E-Slip (Demo)'),
    );
    await pumpFrames(tester);
    expect(find.textContaining('no PDF file is downloaded'), findsOneWidget);
  });

  testWidgets(
    'home gate-crowd section and notifications disclose simulated data',
    (WidgetTester tester) async {
      final data = MockDataService();
      await tester.pumpWidget(_wrap(data, const HomeScreen()));
      await pumpFrames(tester);

      // Gate crowd telemetry notice is rendered inline on the dashboard.
      expect(
        find.textContaining('Gate crowd numbers are simulated'),
        findsOneWidget,
      );

      // Notifications bottom sheet discloses that nothing is delivered.
      await tester.tap(find.byIcon(Icons.notifications_none_rounded));
      await pumpFrames(tester);
      expect(
        find.textContaining('Nothing is delivered to your device'),
        findsOneWidget,
      );
    },
  );
}
