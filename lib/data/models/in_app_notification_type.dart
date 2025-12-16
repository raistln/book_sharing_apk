enum InAppNotificationType {
  loanRequested('loan_requested'),
  loanApproved('loan_approved'),
  loanRejected('loan_rejected'),
  loanCancelled('loan_cancelled'),
  loanReturned('borrower_returned'),
  loanExpired('loan_expired'),
  returnReminderSent('return_reminder'),
  returnPendingConfirmation('return_pending');

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
