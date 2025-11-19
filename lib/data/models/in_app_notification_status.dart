class InAppNotificationStatus {
  const InAppNotificationStatus._();

  static const String unread = 'unread';
  static const String read = 'read';
  static const String dismissed = 'dismissed';

  static bool isValid(String value) {
    return value == unread || value == read || value == dismissed;
  }
}
