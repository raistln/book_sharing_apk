import 'package:book_sharing_app/services/loan_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoanExportService', () {
    test('can be instantiated', () {
      const service = LoanExportService();
      expect(service, isNotNull);
    });
  });
}
