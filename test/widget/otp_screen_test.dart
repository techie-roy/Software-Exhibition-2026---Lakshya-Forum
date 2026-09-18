import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_queue/providers/auth_provider.dart';
import 'package:agri_queue/providers/language_provider.dart';
import 'package:agri_queue/screens/otp_screen.dart';
import 'package:agri_queue/services/local_storage_service.dart';
import 'package:agri_queue/services/mock_auth_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget wrap(Widget child) {
    final storage = LocalStorageService();
    final authService = MockAuthService();
    final authProvider = AuthProvider(authService, storage);
    final languageProvider = LanguageProvider(storage);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: languageProvider),
      ],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('OtpScreen renders verification flow for registered mobile', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrap(const OtpScreen(mobileNumber: '9876543210')),
    );

    await tester.pump();

    expect(find.text('Verify your mobile number'), findsOneWidget);
    expect(find.textContaining('+91 98765 43210'), findsOneWidget);
    expect(find.text('Verify & Continue'), findsOneWidget);
  });

  testWidgets('OtpScreen renders 10-second countdown for unregistered mobile', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrap(const OtpScreen(mobileNumber: '9111111111')),
    );

    await tester.pump();

    // Verify warning header
    expect(find.text('Mobile number not registered'), findsOneWidget);
    expect(find.textContaining('Please register first to continue.'), findsOneWidget);

    // Verify countdown text and register now CTA
    expect(find.textContaining('Redirecting to registration in 10 seconds...'), findsOneWidget);
    expect(find.text('Register Now'), findsOneWidget);

    // Advance timer 1 second
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('Redirecting to registration in 9 seconds...'), findsOneWidget);
  });
}
