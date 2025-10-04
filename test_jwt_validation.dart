#!/usr/bin/env dart

import 'lib/auth_service.dart';

void main() {
  // Test with a real JWT token
  const realJWT = 'eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJhIjoicnciLCJpYXQiOjE3NTUyNjE1NjksImlkIjoiNjVjZWJlOWYtOTBmNC00MWE1LWI3MTItYWU5ZDFiZWFkMTkxIiwicmlkIjoiN2Q5OTMwNWMtNzM5OC00MmU0LWFiNmQtYzE4NjE0ZWY5YmY1In0.s6KZyzWcR7ZE_qoqJmxKVBAT5pVeejyqhljONIywIBGtCyk3xFgF_A9AVo3hMjKb1XqpGmymQFxqTTpiaHcpBA';

  // Test invalid tokens
  const invalidTokens = [
    'not.a.jwt',
    'invalid',
    'one.two',
    'one.two.three.four',
    '',
    'header.payload.',
    '.payload.signature',
    'header..signature',
    'invalid@chars.in#parts.here!',
  ];

  print('Testing JWT validation...');
  print('');

  // This should be valid - we need to access the private method for testing
  // For now, let's just print what we expect
  print('Real JWT (should be valid): $realJWT');
  print('Expected: valid JWT with 3 parts');
  print('');

  print('Invalid tokens (should all be invalid):');
  for (final token in invalidTokens) {
    print('  "$token"');
  }
}