import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_queue/app/routes.dart';
import 'package:agri_queue/providers/auth_provider.dart';
import 'package:agri_queue/providers/language_provider.dart';
import 'package:agri_queue/screens/register_screen.dart';
import 'package:agri_queue/services/local_storage_service.dart';
import 'package:agri_queue/services/mock_auth_service.dart';
import 'package:agri_queue/utils/aadhaar_validator.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createRegisterScreen({AuthProvider? provider}) {
    final storage = LocalStorageService();
    final authService = MockAuthService();
    final authProvider = provider ?? AuthProvider(authService, storage);
    final languageProvider = LanguageProvider(storage);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: languageProvider),
      ],
      child: MaterialApp(
        initialRoute: AppRoutes.register,
        routes: {
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.otp: (context) => const Scaffold(body: Text('OTP Screen')),
          AppRoutes.login: (context) => const Scaffold(body: Text('Login Screen')),
          AppRoutes.main: (context) => const Scaffold(body: Text('Main Screen')),
        },
      ),
    );
  }

  testWidgets('RegisterScreen renders all required fields including Aadhaar, DOB, and Email',
      (WidgetTester tester) async {
    await tester.pumpWidget(createRegisterScreen());
    await tester.pump();

    // Verify Aadhaar header, field, and badges exist
    expect(find.text('Aadhaar Number'), findsOneWidget);
    expect(find.text('On-Device OCR'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.byIcon(Icons.badge_outlined), findsOneWidget);

    // Verify privacy note is displayed
    expect(
      find.textContaining('Your Aadhaar image is processed securely and is not stored by the app.'),
      findsOneWidget,
    );

    // Verify all fields exist in the correct order
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('Mobile Number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Email (Optional)'), findsOneWidget);

    // Verify buttons exist
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Continue with OTP'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Validates Aadhaar format and displays error for invalid format',
      (WidgetTester tester) async {
    await tester.pumpWidget(createRegisterScreen());
    await tester.pump();

    // 6 TextFormFields: Aadhaar, Name, DOB, Mobile, Password, Email
    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(6));

    await tester.enterText(textFields.at(0), '12345'); // Invalid Aadhaar
    await tester.enterText(textFields.at(1), 'Ramesh Patel');
    await tester.enterText(textFields.at(2), '12/05/1985');
    await tester.enterText(textFields.at(3), '9812345678');
    await tester.enterText(textFields.at(4), 'password123');
    await tester.enterText(textFields.at(5), 'test@example.com');

    // Scroll to Next and tap
    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Aadhaar number must be exactly 12 digits'), findsOneWidget);
  });

  testWidgets('Tapping Next with valid fields navigates to OTP screen',
      (WidgetTester tester) async {
    String validAadhaar = '';
    for (int d = 0; d <= 9; d++) {
      final candidate = '24893758194$d';
      if (AadhaarValidator.validateVerhoeff(candidate)) {
        validAadhaar = candidate;
        break;
      }
    }
    expect(validAadhaar.isNotEmpty, isTrue);

    await tester.pumpWidget(createRegisterScreen());
    await tester.pump();

    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), validAadhaar);
    await tester.enterText(textFields.at(1), 'Vikram Singh');
    await tester.enterText(textFields.at(2), '15/08/1990');
    await tester.enterText(textFields.at(3), '9822334455');
    await tester.enterText(textFields.at(4), 'pass1234');
    await tester.enterText(textFields.at(5), 'test@example.com');

    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Should navigate to OTP screen (which shows 'OTP Screen' in our test routes)
    expect(find.text('OTP Screen'), findsOneWidget);
  });

  testWidgets('Continue with OTP still navigates without breaking existing flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(createRegisterScreen());
    await tester.pump();

    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(3), '9812345678');

    await tester.ensureVisible(find.text('Continue with OTP'));
    await tester.tap(find.text('Continue with OTP'));
    await tester.pumpAndSettle();

    expect(find.text('OTP Screen'), findsOneWidget);
  });

  testWidgets('DOB field validates correct format',
      (WidgetTester tester) async {
    await tester.pumpWidget(createRegisterScreen());
    await tester.pump();

    final textFields = find.byType(TextFormField);

    // Enter valid Aadhaar
    String validAadhaar = '';
    for (int d = 0; d <= 9; d++) {
      final candidate = '24893758194$d';
      if (AadhaarValidator.validateVerhoeff(candidate)) {
        validAadhaar = candidate;
        break;
      }
    }
    await tester.enterText(textFields.at(0), validAadhaar);
    await tester.enterText(textFields.at(1), 'Test User');
    await tester.enterText(textFields.at(2), 'invalid-date');
    await tester.enterText(textFields.at(3), '9822334455');
    await tester.enterText(textFields.at(4), 'pass1234');

    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Use DD/MM/YYYY format'), findsOneWidget);
  });

  testWidgets('Email field is optional and validates format when entered',
      (WidgetTester tester) async {
    await tester.pumpWidget(createRegisterScreen());
    await tester.pump();

    final textFields = find.byType(TextFormField);

    // Enter valid Aadhaar
    String validAadhaar = '';
    for (int d = 0; d <= 9; d++) {
      final candidate = '24893758194$d';
      if (AadhaarValidator.validateVerhoeff(candidate)) {
        validAadhaar = candidate;
        break;
      }
    }
    await tester.enterText(textFields.at(0), validAadhaar);
    await tester.enterText(textFields.at(1), 'Test User');
    await tester.enterText(textFields.at(2), '15/08/1990');
    await tester.enterText(textFields.at(3), '9822334455');
    await tester.enterText(textFields.at(4), 'pass1234');
    await tester.enterText(textFields.at(5), 'not-an-email');

    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Please enter a valid email address'), findsOneWidget);
  });
}
