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
    for (final type in values) {
      if (type.value == value) {
        return type;
      }
    }
    return null;
  }
}
