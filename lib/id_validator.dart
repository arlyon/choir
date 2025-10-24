/// Utility class for validating and normalizing IDs for barcode generation.
///
/// Code 128 barcodes require ASCII characters only. This validator ensures
/// that IDs contain only alphanumeric characters and spaces, with automatic
/// normalization of Norwegian characters (æ, ø, å).
class IdValidator {
  /// Normalizes Norwegian characters to their ASCII equivalents.
  /// - æ -> ae
  /// - Æ -> Ae
  /// - ø -> oe
  /// - Ø -> Oe
  /// - å -> aa
  /// - Å -> Aa
  static String _normalizeNorwegianChars(String input) {
    return input
        .replaceAll('æ', 'ae')
        .replaceAll('Æ', 'Ae')
        .replaceAll('ø', 'oe')
        .replaceAll('Ø', 'Oe')
        .replaceAll('å', 'aa')
        .replaceAll('Å', 'Aa');
  }

  /// Validates and normalizes an ID for barcode generation.
  ///
  /// Returns a tuple:
  /// - First element: true if valid, false otherwise
  /// - Second element: normalized ID if valid, error message if invalid
  ///
  /// Valid IDs contain only:
  /// - Alphanumeric characters (a-z, A-Z, 0-9)
  /// - Spaces
  /// - Norwegian characters (æ, ø, å) which are automatically normalized
  static (bool, String) validateAndNormalize(String id) {
    if (id.isEmpty) {
      return (false, 'ID cannot be empty');
    }

    // First normalize Norwegian characters
    final normalized = _normalizeNorwegianChars(id);

    // Check if the normalized string contains only alphanumeric and space
    // This regex matches strings with only letters, numbers, and spaces
    final validPattern = RegExp(r'^[a-zA-Z0-9 ]+$');

    if (!validPattern.hasMatch(normalized)) {
      // Find the first invalid character for better error message
      final invalidChars = <String>{};
      for (int i = 0; i < normalized.length; i++) {
        final char = normalized[i];
        if (!RegExp(r'[a-zA-Z0-9 ]').hasMatch(char)) {
          invalidChars.add(char);
        }
      }

      return (
        false,
        'ID contains invalid characters: ${invalidChars.join(', ')}. Only letters, numbers, and spaces are allowed.',
      );
    }

    return (true, normalized);
  }

  /// Checks if a string was modified during normalization.
  /// Returns true if Norwegian characters were replaced.
  static bool wasNormalized(String original, String normalized) {
    return original != normalized;
  }
}
