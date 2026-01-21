class ReleaseNote {
  final String version;
  final DateTime date;
  final List<String> changes;
  final String? thankYouMessage;

  const ReleaseNote({
    required this.version,
    required this.date,
    required this.changes,
    this.thankYouMessage,
  });
}
