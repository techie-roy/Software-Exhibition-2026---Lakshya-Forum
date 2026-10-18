import 'dart:convert';

import 'package:agri_queue/utils/password_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasswordHasher NIST SHA-256 validation', () {
    test('SHA-256 matches empty string standard vector', () {
      expect(
        PasswordHasher.sha256Hex(utf8.encode('')),
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    });

    test('SHA-256 matches "abc" standard vector', () {
      expect(
        PasswordHasher.sha256Hex(utf8.encode('abc')),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('hashes password consistently with salt', () {
      final h1 = PasswordHasher.hashPassword('Secret123', '9876543210');
      final h2 = PasswordHasher.hashPassword('Secret123', '9876543210');
      expect(h1, equals(h2));
      expect(h1.length, equals(64));
    });

    test('different salts yield different hashes', () {
      final h1 = PasswordHasher.hashPassword('Secret123', '9876543210');
      final h2 = PasswordHasher.hashPassword('Secret123', '9812345678');
      expect(h1, isNot(equals(h2)));
    });

    test('different passwords yield different hashes', () {
      final h1 = PasswordHasher.hashPassword('Secret123', '9876543210');
      final h2 = PasswordHasher.hashPassword('Secret124', '9876543210');
      expect(h1, isNot(equals(h2)));
    });

    test('verifyPassword confirms matching password and rejects wrong', () {
      final hash = PasswordHasher.hashPassword('CorrectPassword', '9876543210');
      expect(
        PasswordHasher.verifyPassword(
          password: 'CorrectPassword',
          salt: '9876543210',
          expectedHash: hash,
        ),
        isTrue,
      );
      expect(
        PasswordHasher.verifyPassword(
          password: 'WrongPassword',
          salt: '9876543210',
          expectedHash: hash,
        ),
        isFalse,
      );
    });
  });
}
