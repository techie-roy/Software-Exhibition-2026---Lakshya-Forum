import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_queue/app/routes.dart';
import 'package:agri_queue/models/language.dart';
import 'package:agri_queue/providers/auth_provider.dart';
import 'package:agri_queue/providers/language_provider.dart';
import 'package:agri_queue/screens/auth_screen.dart';
import 'package:agri_queue/screens/language_screen.dart';
import 'package:agri_queue/services/local_storage_service.dart';
import 'package:agri_queue/services/mock_auth_service.dart';

void main() {
  testWidgets('LanguageScreen renders all 8 languages and switching language updates the UI',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = LocalStorageService();
    final langProvider = LanguageProvider(storageService);
    final authProvider = AuthProvider(MockAuthService(), storageService);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: langProvider),
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: MaterialApp(
          initialRoute: AppRoutes.language,
          routes: {
            AppRoutes.language: (context) => const LanguageScreen(),
            AppRoutes.login: (context) => const AuthScreen(),
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify branding and title
    expect(find.text('AgriQueue'), findsOneWidget);
    expect(find.text('Smart Mandi Queue & Procurement System'), findsOneWidget);

    // Verify language options appear
    expect(find.text('English'), findsWidgets);
    expect(find.text('हिन्दी'), findsOneWidget);
    expect(find.text('తెలుగు'), findsOneWidget);
    expect(find.text('தமிழ்'), findsOneWidget);

    // Tap Hindi and continue
    await tester.tap(find.text('हिन्दी'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Language is persisted in the provider
    expect(langProvider.currentLanguage.code, 'hi');

    // The login screen now renders in Hindi
    expect(find.text('वापसी पर स्वागत है'), findsOneWidget);
    expect(find.text('मोबाइल नंबर'), findsOneWidget);
  });

  testWidgets('LanguageProvider persists selected language', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = LocalStorageService();
    final langProvider = LanguageProvider(storageService);

    await langProvider.setLanguage(AppLanguage.supportedLanguages[1]);

    final restored = LanguageProvider(storageService);
    await tester.pump();
    expect(restored.currentLanguage.code, 'hi');
  });
}