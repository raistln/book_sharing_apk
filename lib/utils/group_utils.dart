/// Utility functions for group operations
library;

/// The canonical name for the personal loans group
const String kPersonalLoansGroupName = 'Préstamos Personales';

/// Normalizes a string by removing accents and converting to lowercase
String _normalizeString(String input) {
  return input
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n');
}

/// Checks if a group name represents the personal loans group
/// 
/// This function normalizes both strings (removes accents, converts to lowercase)
/// and checks if the group name contains both "prestamos" and "personales".
/// This handles variations in encoding, capitalization, and accents.
bool isPersonalLoansGroup(String groupName) {
  final normalized = _normalizeString(groupName);
  return normalized.contains('prestamos') && normalized.contains('personales');
}
