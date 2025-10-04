import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'password_dialog.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String _passwordVerifiedKey = 'password_verified';
  static const String _decryptedTokenKey = 'decrypted_token';

  static String? _cachedToken;
  static String? _cachedPassword;
  static Future<String?>? _authenticationFuture;

  // These are embedded in the app at build time via environment variables
  static const String _distributedEncryptedToken = String.fromEnvironment(
    "TURSO_AUTH_TOKEN_ENCRYPTED",
  );
  static const String _distributedSalt = String.fromEnvironment(
    "TURSO_AUTH_TOKEN_SALT",
  );

  static Future<String?> getDecryptedToken(BuildContext context) async {
    // Check cache first
    if (_cachedToken != null) {
      return _cachedToken;
    }

    // Check stored token
    final storedToken = await _storage.read(key: _decryptedTokenKey);
    if (storedToken != null && _isValidJWT(storedToken)) {
      _cachedToken = storedToken;
      return storedToken;
    } else if (storedToken != null) {
      // Invalid JWT found in storage, clear it
      await _storage.delete(key: _decryptedTokenKey);
    }

    // If already authenticating, wait for the existing future
    if (_authenticationFuture != null) {
      return await _authenticationFuture!;
    }

    // Start new authentication process
    _authenticationFuture = _promptForPasswordAndDecrypt(context);

    try {
      final result = await _authenticationFuture!;
      return result;
    } finally {
      _authenticationFuture = null;
    }
  }

  static Future<void> clearPasswordVerification() async {
    await _storage.delete(key: _passwordVerifiedKey);
    await _storage.delete(key: _decryptedTokenKey);
    _cachedToken = null;
    _cachedPassword = null;
    _authenticationFuture = null;
  }

  static Future<String?> _promptForPasswordAndDecrypt(
    BuildContext context,
  ) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PasswordDialog(),
    );

    if (result != null) {
      final password = result['password']!;
      final token = await _decryptDistributedToken(password);

      if (token != null) {
        return token;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid password. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return await _promptForPasswordAndDecrypt(context);
      }
    }
    return null;
  }

  static Future<String?> _decryptDistributedToken(String password) async {
    if (_cachedToken != null && _cachedPassword == password) {
      return _cachedToken;
    }

    try {
      final encryptedToken = base64Decode(_distributedEncryptedToken);
      final salt = base64Decode(_distributedSalt);
      final key = _deriveKey(password, salt);
      final token = _decrypt(encryptedToken, key);

      // Validate that the decrypted value looks like a JWT
      if (!_isValidJWT(token)) {
        return null; // Invalid JWT format, likely wrong password
      }

      _cachedToken = token;
      _cachedPassword = password;
      await _storage.write(key: _decryptedTokenKey, value: token);
      await _storage.write(key: _passwordVerifiedKey, value: 'true');
      return token;
    } catch (e) {
      return null;
    }
  }

  static bool _isValidJWT(String token) {
    // Basic JWT structure validation: should have 3 parts separated by dots
    final parts = token.split('.');
    if (parts.length != 3) {
      return false;
    }

    // Each part should be non-empty and contain valid base64url characters
    for (final part in parts) {
      if (part.isEmpty) {
        return false;
      }
      // Check for basic base64url characters (A-Z, a-z, 0-9, -, _)
      if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(part)) {
        return false;
      }
    }

    return true;
  }

  static Uint8List _deriveKey(String password, Uint8List salt) {
    final passwordBytes = utf8.encode(password);
    final combined = Uint8List.fromList([...passwordBytes, ...salt]);

    var key = sha256.convert(combined).bytes;
    for (int i = 0; i < 10000; i++) {
      key = sha256.convert([...key, ...salt]).bytes;
    }

    return Uint8List.fromList(key);
  }

  static String _decrypt(Uint8List encrypted, Uint8List key) {
    final decrypted = Uint8List(encrypted.length);

    for (int i = 0; i < encrypted.length; i++) {
      decrypted[i] = encrypted[i] ^ key[i % key.length];
    }

    return utf8.decode(decrypted);
  }
}
