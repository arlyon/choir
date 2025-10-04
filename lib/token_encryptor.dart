import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class TokenEncryptor {
  static Map<String, String> encryptToken(String token, String password) {
    final salt = _generateSalt();
    final key = _deriveKey(password, salt);
    final encryptedToken = _encrypt(token, key);

    return {
      'encrypted_token': base64Encode(encryptedToken),
      'salt': base64Encode(salt),
    };
  }

  static String? decryptToken(String encryptedTokenBase64, String saltBase64, String password) {
    try {
      final encryptedToken = base64Decode(encryptedTokenBase64);
      final salt = base64Decode(saltBase64);
      final key = _deriveKey(password, salt);
      return _decrypt(encryptedToken, key);
    } catch (e) {
      return null;
    }
  }

  static Uint8List _generateSalt() {
    final random = Random.secure();
    final salt = Uint8List(32);
    for (int i = 0; i < salt.length; i++) {
      salt[i] = random.nextInt(256);
    }
    return salt;
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

  static Uint8List _encrypt(String plaintext, Uint8List key) {
    final plaintextBytes = utf8.encode(plaintext);
    final encrypted = Uint8List(plaintextBytes.length);

    for (int i = 0; i < plaintextBytes.length; i++) {
      encrypted[i] = plaintextBytes[i] ^ key[i % key.length];
    }

    return encrypted;
  }

  static String _decrypt(Uint8List encrypted, Uint8List key) {
    final decrypted = Uint8List(encrypted.length);

    for (int i = 0; i < encrypted.length; i++) {
      decrypted[i] = encrypted[i] ^ key[i % key.length];
    }

    return utf8.decode(decrypted);
  }

  // Utility method to print encrypted token for embedding in app
  static void printEncryptedToken(String token, String password) {
    final result = encryptToken(token, password);
    print('=== ENCRYPTED TOKEN FOR APP DISTRIBUTION ===');
    print('Encrypted Token: ${result['encrypted_token']}');
    print('Salt: ${result['salt']}');
    print('=== COPY THESE VALUES TO YOUR APP ===');
  }
}