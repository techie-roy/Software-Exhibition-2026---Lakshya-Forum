import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agri_queue/app/routes.dart';
import 'package:agri_queue/providers/auth_provider.dart';
import 'package:agri_queue/providers/language_provider.dart';
import 'package:agri_queue/screens/auth_screen.dart';
import 'package:agri_queue/services/google_auth_service.dart';
import 'package:agri_queue/services/local_storage_service.dart';
import 'package:agri_queue/services/mock_auth_service.dart';
import 'package:agri_queue/widgets/google_sign_in_button.dart';

class FakeGoogleAuthService implements GoogleAuthService {
  FakeGoogleAuthService({
    required this.isAvailable,
    this.result = const GoogleAuthResult.canceled(),
  });

  @override
  final bool isAvailable;

  GoogleAuthResult result;
  int signInCalls = 0;

  @override
  Future<GoogleAuthResult> signIn() async {
    signInCalls++;
    return result;
  }

  @override
  Future<void> signOut() async {}
}

/// Records route pushes so a test can prove navigation happened exactly once
/// (guards against duplicate navigation regressions).
class _RecordingObserver extends NavigatorObserver {
  final List<String?> pushed = <String?>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route.settings.name);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    pushed.add(newRoute?.settings.name);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget wrap(
    GoogleAuthService google, {
    NavigatorObserver? observer,
    Route<dynamic>? Function(RouteSettings settings)? onGenerateRoute,
  }) {
    final storage = LocalStorageService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            MockAuthService(),
            storage,
            googleAuthService: google,
          ),
        ),
        ChangeNotifierProvider(create: (_) => LanguageProvider(storage)),
      ],
      child: MaterialApp(
        navigatorObservers: observer == null ? const [] : [observer],
        home: const AuthScreen(),
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }

  Future<void> tapGoogle(WidgetTester tester) async {
    final button = find.text('Continue with Google');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
  }

  testWidgets('renders Continue with Google when the service is available', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(FakeGoogleAuthService(isAvailable: true)));
    await tester.pump();

    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('hides the Google button when the service is unavailable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(FakeGoogleAuthService(isAvailable: false)));
    await tester.pump();

    expect(find.text('Continue with Google'), findsNothing);
  });

  testWidgets('tapping Google invokes the sign-in flow', (
    WidgetTester tester,
  ) async {
    final google = FakeGoogleAuthService(isAvailable: true);
    await tester.pumpWidget(wrap(google));
    await tester.pump();

    await tapGoogle(tester);
    await tester.pump();

    expect(google.signInCalls, 1);
  });

  testWidgets('failure shows an error and clears the loading state', (
    WidgetTester tester,
  ) async {
    final google = FakeGoogleAuthService(
      isAvailable: true,
      result: const GoogleAuthResult.failed(),
    );
    await tester.pumpWidget(wrap(google));
    await tester.pump();

    await tapGoogle(tester);
    // Let the async sign-in complete and the snackbar animate in.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.text('Google sign-in failed. Please try again.'),
      findsOneWidget,
    );
    final button = tester.widget<GoogleSignInButton>(
      find.byType(GoogleSignInButton),
    );
    expect(button.isLoading, isFalse);
    // Still on the login screen: a failure must not navigate away.
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('success navigates to the main route exactly once', (
    WidgetTester tester,
  ) async {
    final google = FakeGoogleAuthService(
      isAvailable: true,
      result: const GoogleAuthResult.success(
        email: 'jane.doe@example.com',
        displayName: 'Jane Doe',
      ),
    );
    final observer = _RecordingObserver();
    await tester.pumpWidget(
      wrap(
        google,
        observer: observer,
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.main) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const Scaffold(body: Text('MAIN_SCREEN')),
            );
          }
          return null;
        },
      ),
    );
    await tester.pump();

    await tapGoogle(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('MAIN_SCREEN'), findsOneWidget);
    expect(
      observer.pushed.where((name) => name == AppRoutes.main).length,
      1,
      reason: 'successful sign-in must navigate exactly once',
    );
  });
}
