import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_queue/models/booking.dart';
import 'package:agri_queue/providers/auth_provider.dart';
import 'package:agri_queue/providers/booking_provider.dart';
import 'package:agri_queue/providers/language_provider.dart';
import 'package:agri_queue/providers/queue_provider.dart';
import 'package:agri_queue/screens/procurement_screen.dart';
import 'package:agri_queue/services/local_storage_service.dart';
import 'package:agri_queue/services/mock_auth_service.dart';
import 'package:agri_queue/services/mock_data_service.dart';
import 'package:agri_queue/widgets/cancel_booking_dialog.dart';

Future<void> pumpFrames(
  WidgetTester tester, [
  Duration duration = const Duration(milliseconds: 400),
]) async {
  await tester.pump();
  await tester.pump(duration);
}

Widget _wrap(Widget child, MockDataService dataService) {
  final storage = LocalStorageService();
  final bookingProvider = BookingProvider(dataService);
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: LanguageProvider(storage)),
      ChangeNotifierProvider.value(
        value: AuthProvider(MockAuthService(), storage),
      ),
      ChangeNotifierProvider.value(value: bookingProvider),
      ChangeNotifierProvider.value(value: QueueProvider(dataService)),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Cancel Booking Dialog', () {
    testWidgets('Shows booking details and confirm/cancel actions', (
      WidgetTester tester,
    ) async {
      final dataService = MockDataService();
      final booking = dataService.activeBooking;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showCancelBookingDialog(context, booking),
                child: const Text('open'),
              ),
            ),
          ),
          dataService,
        ),
      );

      await tester.tap(find.text('open'));
      await pumpFrames(tester);

      expect(find.text('Cancel Booking'), findsWidgets);
      expect(
        find.text('Are you sure you want to cancel this booking?'),
        findsOneWidget,
      );
      expect(find.text('Keep Booking'), findsOneWidget);
      expect(find.text('A-125'), findsOneWidget);
      expect(find.text('Wheat'), findsOneWidget);
      expect(find.text('07:00 AM – 09:00 AM'), findsOneWidget);
    });

    testWidgets('Dismiss on Keep Booking leaves booking active', (
      WidgetTester tester,
    ) async {
      final dataService = MockDataService();
      final booking = dataService.activeBooking;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showCancelBookingDialog(context, booking),
                child: const Text('open'),
              ),
            ),
          ),
          dataService,
        ),
      );

      await tester.tap(find.text('open'));
      await pumpFrames(tester);
      await tester.tap(find.text('Keep Booking'));
      await pumpFrames(tester);

      expect(dataService.activeBooking.status, equals(BookingStatus.inQueue));
    });

    testWidgets('Confirm cancels the booking and returns updated booking', (
      WidgetTester tester,
    ) async {
      final dataService = MockDataService();
      final booking = dataService.activeBooking;
      Booking? dialogResult;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  dialogResult = await showCancelBookingDialog(
                    context,
                    booking,
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
          dataService,
        ),
      );

      await tester.tap(find.text('open'));
      await pumpFrames(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cancel Booking'));
      await pumpFrames(tester);

      expect(dialogResult, isNotNull);
      expect(dialogResult!.status, equals(BookingStatus.cancelled));
      expect(dataService.activeBooking.status, equals(BookingStatus.cancelled));
    });
  });

  group('ProcurementScreen bookings tab cancel action', () {
    testWidgets('Active bookings show a cancel button that cancels the token', (
      WidgetTester tester,
    ) async {
      final dataService = MockDataService();
      final storage = LocalStorageService();
      final bookingProvider = BookingProvider(dataService);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: LanguageProvider(storage)),
            ChangeNotifierProvider.value(
              value: AuthProvider(MockAuthService(), storage),
            ),
            ChangeNotifierProvider.value(value: bookingProvider),
            ChangeNotifierProvider.value(value: QueueProvider(dataService)),
          ],
          child: const MaterialApp(home: ProcurementScreen()),
        ),
      );

      await pumpFrames(tester);

      // Switch to the bookings tab
      await tester.tap(find.text('Mandi Bookings'));
      await pumpFrames(tester);

      expect(find.text('A-125'), findsOneWidget);
      // Cancel action exists on active bookings
      expect(find.text('Cancel Booking'), findsWidgets);

      await tester.tap(find.text('Cancel Booking').first);
      await pumpFrames(tester);

      expect(
        find.text('Are you sure you want to cancel this booking?'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cancel Booking'));
      await pumpFrames(tester);

      expect(dataService.activeBooking.status, equals(BookingStatus.cancelled));
    });
  });
}
