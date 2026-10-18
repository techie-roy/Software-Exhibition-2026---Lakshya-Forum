import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_queue/providers/auth_provider.dart';
import 'package:agri_queue/providers/language_provider.dart';
import 'package:agri_queue/screens/auth_screen.dart';
import 'package:agri_queue/screens/otp_screen.dart';
import 'package:agri_queue/screens/register_screen.dart';
import 'package:agri_queue/services/local_storage_service.dart';
import 'package:agri_queue/services/mock_auth_service.dart';
import 'package:agri_queue/widgets/demo_mode_banner.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget wrap(Widget child) {
    final storage = LocalStorageService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(MockAuthService(), storage),
        ),
        ChangeNotifierProvider(create: (_) => LanguageProvider(storage)),
      ],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('login screen clearly labels simulated demo auth', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const AuthScreen()));
    await tester.pump();

    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.textContaining('Authentication is simulated'), findsOneWidget);
  });

  testWidgets('OTP screen clearly labels simulated demo auth', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const OtpScreen(mobileNumber: '9876543210')));
    await tester.pump();

    expect(find.text('Demo mode'), findsOneWidget);
  });

  testWidgets('registration screen clearly labels simulated demo auth', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const RegisterScreen()));
    await tester.pump();

    expect(find.text('Demo mode'), findsOneWidget);
  });

  // Regression: the disclosure must not be hidden by Firebase being
  // configured. Rendering it with NO AuthProvider at all proves it can no
  // longer be gated on isDemoMode/isFirebaseAvailable.
  testWidgets('demo disclosure renders without any AuthProvider', (
    WidgetTester tester,
  ) async {
    final storage = LocalStorageService();
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LanguageProvider(storage),
        child: const MaterialApp(home: Scaffold(body: DemoModeBanner())),
      ),
    );
    await tester.pump();

    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.textContaining('Authentication is simulated'), findsOneWidget);
    // The disclosure names the paths that are actually simulated.
    expect(find.textContaining('OTP sign-in'), findsOneWidget);
  });
}
