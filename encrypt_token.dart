#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';
import 'lib/token_encryptor.dart';

void main() {
  print('=== Turso Token Encryptor ===');
  print('This script will encrypt your Turso auth token for distribution.');
  print('');

  // Get token from user
  stdout.write('Enter your Turso auth token: ');
  final token = stdin.readLineSync()?.trim() ?? '';

  if (token.isEmpty) {
    print('Error: Token cannot be empty');
    exit(1);
  }

  // Get password from user
  stdout.write('Enter encryption password: ');
  final password = stdin.readLineSync()?.trim() ?? '';

  if (password.isEmpty) {
    print('Error: Password cannot be empty');
    exit(1);
  }

  if (password.length < 6) {
    print('Error: Password must be at least 6 characters');
    exit(1);
  }

  // Encrypt the token
  final result = TokenEncryptor.encryptToken(token, password);

  print('');
  print('=== ENCRYPTED TOKEN DETAILS ===');
  print('Encrypted Token: ${result['encrypted_token']}');
  print('Salt: ${result['salt']}');
  print('');
  print('=== UPDATE YOUR ENV FILE ===');
  print('Replace TURSO_AUTH_TOKEN_ENCRYPTED with: ${result['encrypted_token']}');
  print('Add TURSO_AUTH_TOKEN_SALT with: ${result['salt']}');
  print('');
  print('=== VERIFICATION ===');

  // Verify decryption works
  final decrypted = TokenEncryptor.decryptToken(
    result['encrypted_token']!,
    result['salt']!,
    password,
  );

  if (decrypted == token) {
    print('✅ Encryption/decryption successful!');
  } else {
    print('❌ Encryption/decryption failed!');
    exit(1);
  }
}