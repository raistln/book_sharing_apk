class IsbnUtils {
  const IsbnUtils._();

  static final RegExp _isbnCharacters = RegExp(r'[^0-9Xx]');

  /// Removes non ISBN characters (except X) and uppercases the result.
  static String? normalize(String? raw) {
    if (raw == null) return null;
    final cleaned = raw.replaceAll(_isbnCharacters, '').toUpperCase();
    return cleaned.isEmpty ? null : cleaned;
  }

  /// Returns a prioritized list of ISBN candidates (normalized input first).
  /// For ISBN-13 values starting with 978, the converted ISBN-10 is appended.
  static List<String> expandCandidates(String? raw) {
    final normalized = normalize(raw);
    if (normalized == null) return const [];

    final candidates = <String>{normalized};
    final isbn10 = toIsbn10(normalized);
    if (isbn10 != null) {
      candidates.add(isbn10);
    }
    return List.unmodifiable(candidates);
  }

  static bool isIsbn13(String? value) {
    final normalized = normalize(value);
    return normalized != null && normalized.length == 13 && int.tryParse(normalized) != null;
  }

  static bool isIsbn10(String? value) {
    final normalized = normalize(value);
    if (normalized == null || normalized.length != 10) return false;
    final body = normalized.substring(0, 9);
    if (int.tryParse(body) == null) return false;
    final checkChar = normalized[9];
    return checkChar == 'X' || int.tryParse(checkChar) != null;
  }

  /// Converts an ISBN-13 that starts with 978 into ISBN-10.
  /// Returns null when the input cannot be converted.
  static String? toIsbn10(String? raw) {
    final normalized = normalize(raw);
    if (normalized == null || normalized.length != 13 || !normalized.startsWith('978')) {
      return null;
    }

    final core = normalized.substring(3, 12);
    final digits = core.split('').map(int.parse).toList(growable: false);

    var sum = 0;
    for (var i = 0; i < digits.length; i++) {
      sum += digits[i] * (10 - i);
    }

    final remainder = sum % 11;
    var checkDigit = 11 - remainder;
    String checkChar;
    if (checkDigit == 10) {
      checkChar = 'X';
    } else if (checkDigit == 11) {
      checkChar = '0';
    } else {
      checkChar = checkDigit.toString();
    }

    return '$core$checkChar';
  }
}
