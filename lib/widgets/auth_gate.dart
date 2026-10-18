import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/routes.dart';
import '../providers/auth_provider.dart';

/// Guards protected screens using Firebase Auth state changes combined
/// with the legacy mock session.
///
/// Waits for the persisted session restore ([AuthProvider.ready]) before
/// judging, so a cold-started signed-in user is never bounced to login by
/// an initialization race.
///
/// Authenticated (Firebase user OR mock farmer) -> [child].
/// Unauthenticated -> redirected to Login with the back stack cleared,
/// so protected screens cannot be reached via back navigation after logout.
class AuthGate extends StatelessWidget {
  final Widget child;

  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return FutureBuilder<void>(
      future: auth.ready,
      builder: (context, readySnapshot) {
        if (readySnapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return StreamBuilder(
          stream: auth.authStateChanges(),
          builder: (context, snapshot) {
            // Provider already re-notifies on Firebase changes; snapshot keeps
            // us subscribed to the Firebase stream itself.
            final signedIn = auth.isLoggedIn;
            if (!signedIn) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return child;
          },
        );
      },
    );
  }
}
