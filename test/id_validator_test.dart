import 'package:flutter_test/flutter_test.dart';
import 'package:SSKor/id_validator.dart';

void main() {
  group('IdValidator', () {
    test('accepts valid alphanumeric IDs', () {
      final (isValid, result) = IdValidator.validateAndNormalize('ABC123');
      expect(isValid, true);
      expect(result, 'ABC123');
    });

    test('accepts IDs with spaces', () {
      final (isValid, result) = IdValidator.validateAndNormalize('ABC 123');
      expect(isValid, true);
      expect(result, 'ABC 123');
    });

    test('normalizes Norwegian æ to ae', () {
      final (isValid, result) = IdValidator.validateAndNormalize('Blåkors');
      expect(isValid, true);
      expect(result, 'Blaakors');
    });

    test('normalizes Norwegian ø to oe', () {
      final (isValid, result) = IdValidator.validateAndNormalize('Grønn');
      expect(isValid, true);
      expect(result, 'Groenn');
    });

    test('normalizes Norwegian å to aa', () {
      final (isValid, result) = IdValidator.validateAndNormalize('Gård');
      expect(isValid, true);
      expect(result, 'Gaard');
    });

    test('normalizes mixed Norwegian characters', () {
      final (isValid, result) = IdValidator.validateAndNormalize('Øystein Åse');
      expect(isValid, true);
      expect(result, 'Oeystein Aase');
    });

    test('normalizes uppercase Norwegian characters', () {
      final (isValid, result) = IdValidator.validateAndNormalize('ØÆÅ');
      expect(isValid, true);
      expect(result, 'OeAeAa');
    });

    test('rejects special characters', () {
      final (isValid, result) = IdValidator.validateAndNormalize('ABC@123');
      expect(isValid, false);
      expect(result, contains('invalid characters'));
      expect(result, contains('@'));
    });

    test('rejects symbols', () {
      final (isValid, result) = IdValidator.validateAndNormalize('ABC-123');
      expect(isValid, false);
      expect(result, contains('invalid characters'));
      expect(result, contains('-'));
    });

    test('rejects empty strings', () {
      final (isValid, result) = IdValidator.validateAndNormalize('');
      expect(isValid, false);
      expect(result, 'ID cannot be empty');
    });

    test('wasNormalized detects changes', () {
      expect(IdValidator.wasNormalized('Øystein', 'Oeystein'), true);
      expect(IdValidator.wasNormalized('ABC123', 'ABC123'), false);
    });
  });
}
