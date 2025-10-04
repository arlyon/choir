import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String _passwordVerifiedKey = 'password_verified';
  static const String _decryptedTokenKey = 'decrypted_token';

  static String? _cachedToken;
  static String? _cachedPassword;

  // These are embedded in the app at build time via environment variables
  static const String _distributedEncryptedToken = String.fromEnvironment("TURSO_AUTH_TOKEN_ENCRYPTED");
  static const String _distributedSalt = String.fromEnvironment("TURSO_AUTH_TOKEN_SALT");

  static Future<bool> hasPasswordBeenVerified() async {
    final verified = await _storage.read(key: _passwordVerifiedKey);
    return verified == 'true';
  }

  static Future<void> markPasswordAsVerified() async {
    await _storage.write(key: _passwordVerifiedKey, value: 'true');
  }

  static Future<String?> getStoredToken() async {
    if (_cachedToken != null) {
      return _cachedToken;
    }

    final storedToken = await _storage.read(key: _decryptedTokenKey);
    if (storedToken != null && _isValidJWT(storedToken)) {
      _cachedToken = storedToken;
      return storedToken;
    } else if (storedToken != null) {
      // Invalid JWT found in storage, clear it
      await _storage.delete(key: _decryptedTokenKey);
    }

    return null;
  }

  static Future<String?> decryptDistributedToken(String password) async {
    if (_cachedToken != null && _cachedPassword == password) {
      return _cachedToken;
    }

    if (_distributedEncryptedToken.isEmpty || _distributedSalt.isEmpty) {
      return null; // Token not properly configured
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
      await markPasswordAsVerified();
      return token;
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearPasswordVerification() async {
    await _storage.delete(key: _passwordVerifiedKey);
    await _storage.delete(key: _decryptedTokenKey);
    _cachedToken = null;
    _cachedPassword = null;
  }

  static String? getCachedToken() {
    return _cachedToken;
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