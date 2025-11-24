enum InAppNotificationType {
  loanRequest('loan-request'),
  loanAccepted('loan-accepted'),
  loanRejected('loan-rejected'),
  loanCancelled('loan-cancelled'),
  loanReturned('loan-returned'),
  loanExpired('loan-expired');

  const InAppNotificationType(this.value);

  final String value;

  static InAppNotificationType? fromValue(String value) {
    final normalized = _normalize(value);
    for (final type in values) {
      if (_normalize(type.value) == normalized || _normalize(type.name) == normalized) {
        return type;
      }
    }
    return null;
  }

  static String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
