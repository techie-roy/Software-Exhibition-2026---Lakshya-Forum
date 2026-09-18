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
import '../services/local_storage_service.dart';
import '../services/mock_auth_service.dart';
import '../services/mock_data_service.dart';
import 'routes.dart';
import 'theme.dart';

class AgriQueueApp extends StatelessWidget {
  final LocalStorageService localStorageService;
  final MockAuthService mockAuthService;
  final MockDataService mockDataService;

  const AgriQueueApp({
    super.key,
    required this.localStorageService,
    required this.mockAuthService,
    required this.mockDataService,
  });

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
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingProvider(mockDataService),
        ),
        ChangeNotifierProvider(
          create: (_) => QueueProvider(mockDataService),
        ),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, langProvider, _) {
          return MaterialApp(
            title: 'AgriQueue',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.language,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case AppRoutes.language:
                  return MaterialPageRoute(
                    builder: (_) => const LanguageScreen(),
                  );
                case AppRoutes.login:
                  return MaterialPageRoute(
                    builder: (_) => const AuthScreen(),
                  );
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
                  final phone = (args as String?) ?? '9876543210';
                  return MaterialPageRoute(
                    builder: (_) => OtpScreen(mobileNumber: phone),
                  );
                case AppRoutes.main:
                  final initialTab = (settings.arguments as int?) ?? 0;
                  return MaterialPageRoute(
                    builder: (_) => MainNavigationShell(initialTab: initialTab),
                  );
                case AppRoutes.slotBooking:
                  return MaterialPageRoute(
                    builder: (_) => const SlotBookingScreen(),
                  );
                case AppRoutes.bookingConfirmation:
                  final booking = settings.arguments as Booking;
                  return MaterialPageRoute(
                    builder: (_) => BookingConfirmationScreen(booking: booking),
                  );
                case AppRoutes.queueTracking:
                  return MaterialPageRoute(
                    builder: (_) => const QueueTrackingScreen(),
                  );
                case AppRoutes.marketPrices:
                  return MaterialPageRoute(
                    builder: (_) => const MarketPriceScreen(),
                  );
                case AppRoutes.procurement:
                  return MaterialPageRoute(
                    builder: (_) => const ProcurementScreen(),
                  );
                case AppRoutes.profile:
                  return MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  );
                case AppRoutes.voiceBooking:
                  return MaterialPageRoute(
                    builder: (_) => const VoiceBookingScreen(),
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
