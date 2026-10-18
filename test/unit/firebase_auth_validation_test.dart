import 'package:agri_queue/services/auth_error_mapper.dart';
import 'package:agri_queue/services/firebase_auth_service.dart';
import 'package:agri_queue/utils/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Firebase registration/login validation', () {
    test('validateEmailRequired rejects empty, accepts valid', () {
      expect(Validators.validateEmailRequired(null), isNotNull);
      expect(Validators.validateEmailRequired(''), isNotNull);
      expect(Validators.validateEmailRequired('   '), isNotNull);
      expect(Validators.validateEmailRequired('not-an-email'), isNotNull);
      expect(Validators.validateEmailRequired('farmer@gmail.com'), isNull);
    });

    test('optional validateEmail still allows empty (legacy behaviour)', () {
      expect(Validators.validateEmail(null), isNull);
      expect(Validators.validateEmail(''), isNull);
      expect(Validators.validateEmail('bad'), isNotNull);
    });

    test('validateFirebasePassword requires 6+ chars', () {
      expect(Validators.validateFirebasePassword(null), isNotNull);
      expect(Validators.validateFirebasePassword(''), isNotNull);
      expect(Validators.validateFirebasePassword('12345'), isNotNull);
      expect(Validators.validateFirebasePassword('123456'), isNull);
    });

    test('legacy validatePassword still allows 4 chars (unchanged)', () {
      expect(Validators.validatePassword('1234'), isNull);
    });
  });

  group('AuthErrorMapper', () {
    test('maps duplicate email distinctly', () {
      final msg = AuthErrorMapper.messageFor(
        FirebaseAuthException(code: 'email-already-in-use'),
      );
      expect(msg.toLowerCase(), contains('already registered'));
    });

    test('maps invalid credentials without leaking details', () {
      for (final code in [
        'user-not-found',
        'wrong-password',
        'invalid-credential',
      ]) {
        final msg = AuthErrorMapper.messageFor(
          FirebaseAuthException(code: code),
        );
        expect(msg.toLowerCase(), contains('invalid'));
      }
    });

    test('maps network errors', () {
      final msg = AuthErrorMapper.messageFor(
        FirebaseAuthException(code: 'network-request-failed'),
      );
      expect(msg.toLowerCase(), contains('network'));
    });

    test('maps weak password', () {
      final msg = AuthErrorMapper.messageFor(
        FirebaseAuthException(code: 'weak-password'),
      );
      expect(msg, contains('6 characters'));
    });

    test('maps unconfigured Firebase to setup guidance', () {
      final msg = AuthErrorMapper.messageFor(FirebaseNotConfiguredException());
      expect(msg.toLowerCase(), contains('not configured'));
    });

    test('never echoes passwords or tokens', () {
      const secret = 'Sup3rSecretPw123';
      final msg = AuthErrorMapper.messageFor(
        FirebaseAuthException(code: 'invalid-credential'),
      );
      expect(msg, isNot(contains(secret)));
    });
  });

  group('FirebaseAuthService fallback', () {
    test('unavailable service exposes safe fallback behaviour', () async {
      const service = FirebaseAuthService();
      expect(service.isAvailable, isFalse);
      expect(service.currentUser, isNull);
      // Stream always works, emitting null (signed out).
      await expectLater(service.authStateChanges(), emits(null));
      // Mutating calls report setup guidance instead of crashing.
      await expectLater(
        service.signInWithEmail(email: 'a@b.com', password: 'x'),
        throwsA(isA<FirebaseNotConfiguredException>()),
      );
      await expectLater(
        service.createUserWithEmail(email: 'a@b.com', password: 'x'),
        throwsA(isA<FirebaseNotConfiguredException>()),
      );
      await expectLater(
        service.sendPasswordReset(email: 'a@b.com'),
        throwsA(isA<FirebaseNotConfiguredException>()),
      );
      // Sign-out is a safe no-op when unconfigured.
      await service.signOut();
    });
  });
}
