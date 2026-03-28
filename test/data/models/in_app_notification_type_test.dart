import 'package:book_sharing_app/data/models/in_app_notification_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InAppNotificationType', () {
    test('fromValue returns correct enum for valid value', () {
      expect(InAppNotificationType.fromValue('loan_requested'), InAppNotificationType.loanRequested);
      expect(InAppNotificationType.fromValue('loan_approved'), InAppNotificationType.loanApproved);
      expect(InAppNotificationType.fromValue('loan_rejected'), InAppNotificationType.loanRejected);
      expect(InAppNotificationType.fromValue('loan_cancelled'), InAppNotificationType.loanCancelled);
      expect(InAppNotificationType.fromValue('borrower_returned'), InAppNotificationType.loanReturned);
      expect(InAppNotificationType.fromValue('loan_expired'), InAppNotificationType.loanExpired);
      expect(InAppNotificationType.fromValue('loan_due_soon'), InAppNotificationType.loanDueSoon);
      expect(InAppNotificationType.fromValue('group_member_joined'), InAppNotificationType.groupMemberJoined);
      expect(InAppNotificationType.fromValue('group_member_left'), InAppNotificationType.groupMemberLeft);
      expect(InAppNotificationType.fromValue('group_updated'), InAppNotificationType.groupUpdated);
      expect(InAppNotificationType.fromValue('group_deleted'), InAppNotificationType.groupDeleted);
      expect(InAppNotificationType.fromValue('return_reminder'), InAppNotificationType.returnReminderSent);
      expect(InAppNotificationType.fromValue('return_pending'), InAppNotificationType.returnPendingConfirmation);
    });

    test('fromValue returns correct enum for name', () {
      expect(InAppNotificationType.fromValue('loanRequested'), InAppNotificationType.loanRequested);
      expect(InAppNotificationType.fromValue('loanApproved'), InAppNotificationType.loanApproved);
    });

    test('fromValue normalizes input', () {
      expect(InAppNotificationType.fromValue('LOAN_REQUESTED'), InAppNotificationType.loanRequested);
      expect(InAppNotificationType.fromValue('loan-requested'), InAppNotificationType.loanRequested);
      expect(InAppNotificationType.fromValue('Loan Requested'), InAppNotificationType.loanRequested);
    });

    test('fromValue returns null for invalid value', () {
      expect(InAppNotificationType.fromValue('invalid'), isNull);
      expect(InAppNotificationType.fromValue(''), isNull);
    });

    test('value property returns correct string', () {
      expect(InAppNotificationType.loanRequested.value, 'loan_requested');
      expect(InAppNotificationType.loanApproved.value, 'loan_approved');
    });
  });
}
