import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/language_provider.dart';
import '../providers/queue_provider.dart';
import '../screens/auth_screen.dart';
import '../screens/booking_confirmation_screen.dart';
import '../screens/language_screen.dart';
import '../screens/main_navigation_shell.dart';
import '../screens/market_price_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/procurement_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/queue_tracking_screen.dart';
import '../models/registration_data.dart';
import '../screens/register_screen.dart';
import '../screens/slot_booking_screen.dart';
import '../screens/voice_booking_screen.dart';
import '../services/firebase_auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/mock_auth_service.dart';
import '../services/mock_data_service.dart';
import '../widgets/auth_gate.dart';
import 'routes.dart';
import 'theme.dart';

class AgriQueueApp extends StatelessWidget {
  final LocalStorageService localStorageService;
  final MockAuthService mockAuthService;
  final MockDataService mockDataService;
  final FirebaseAuthService firebaseAuthService;
  final GoogleAuthService? googleAuthService;

  /// True once a language has been chosen before (read from storage by
  /// `main()`). First launch (false) always shows the language screen;
  /// later launches skip it so language selection is first-launch-only.
  final bool savedLanguageExists;

  /// Whether a session flag was found at startup. Combined with
  /// [savedLanguageExists] so a returning signed-in user resumes the app
  /// instead of being sent back through login every launch. AuthGate
  /// re-validates this against the restored session.
  final bool sessionWasLoggedIn;

  const AgriQueueApp({
    super.key,
    required this.localStorageService,
    required this.mockAuthService,
    required this.mockDataService,
    FirebaseAuthService? firebaseAuthService,
    this.googleAuthService,
    this.savedLanguageExists = false,
    this.sessionWasLoggedIn = false,
  }) : firebaseAuthService =
           firebaseAuthService ?? const _UnconfiguredFirebaseAuthService();

  /// First launch: language selection. Later launches: straight into the
  /// session (AuthGate redirects to login when the session turns out to be
  /// invalid), or to login when no session flag was found.
  String get _initialRoute {
    if (!savedLanguageExists) return AppRoutes.language;
    return sessionWasLoggedIn ? AppRoutes.main : AppRoutes.login;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(localStorageService),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            mockAuthService,
            localStorageService,
            firebaseAuthService: firebaseAuthService,
            googleAuthService: googleAuthService,
          ),
        ),
        ChangeNotifierProvider(create: (_) => BookingProvider(mockDataService)),
        ChangeNotifierProvider(create: (_) => QueueProvider(mockDataService)),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, langProvider, _) {
          return MaterialApp(
            title: 'AgriQueue',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: _initialRoute,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case AppRoutes.language:
                  return MaterialPageRoute(
                    builder: (_) => const LanguageScreen(),
                  );
                case AppRoutes.login:
                  return MaterialPageRoute(builder: (_) => const AuthScreen());
                case AppRoutes.register:
                  final initialPhone = settings.arguments as String?;
                  return MaterialPageRoute(
                    builder: (_) => RegisterScreen(initialMobile: initialPhone),
                  );
                case AppRoutes.otp:
                  final args = settings.arguments;
                  if (args is RegistrationData) {
                    return MaterialPageRoute(
                      builder: (_) => OtpScreen(
                        mobileNumber: args.mobile,
                        registrationData: args,
                      ),
                    );
                  }
                  final phone = (args as String?) ?? '';
                  return MaterialPageRoute(
                    builder: (_) => OtpScreen(mobileNumber: phone),
                  );
                case AppRoutes.main:
                  final initialTab = (settings.arguments as int?) ?? 0;
                  return MaterialPageRoute(
                    builder: (_) => AuthGate(
                      child: MainNavigationShell(initialTab: initialTab),
                    ),
                  );
                case AppRoutes.slotBooking:
                  return MaterialPageRoute(
                    builder: (_) => const AuthGate(child: SlotBookingScreen()),
                  );
                case AppRoutes.bookingConfirmation:
                  final booking = settings.arguments as Booking;
                  return MaterialPageRoute(
                    builder: (_) => AuthGate(
                      child: BookingConfirmationScreen(booking: booking),
                    ),
                  );
                case AppRoutes.queueTracking:
                  return MaterialPageRoute(
                    builder: (_) =>
                        const AuthGate(child: QueueTrackingScreen()),
                  );
                case AppRoutes.marketPrices:
                  return MaterialPageRoute(
                    builder: (_) => const AuthGate(child: MarketPriceScreen()),
                  );
                case AppRoutes.procurement:
                  return MaterialPageRoute(
                    builder: (_) => const AuthGate(child: ProcurementScreen()),
                  );
                case AppRoutes.profile:
                  return MaterialPageRoute(
                    builder: (_) => const AuthGate(child: ProfileScreen()),
                  );
                case AppRoutes.voiceBooking:
                  return MaterialPageRoute(
                    builder: (_) => const AuthGate(child: VoiceBookingScreen()),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (_) => const LanguageScreen(),
                  );
              }
            },
          );
        },
      ),
    );
  }
}

/// Default when no Firebase service is injected (e.g. older tests).
/// Reports itself as unavailable so the app falls back to mock/OTP auth.
class _UnconfiguredFirebaseAuthService extends FirebaseAuthService {
  const _UnconfiguredFirebaseAuthService() : super(auth: null);
}
