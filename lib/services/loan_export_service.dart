import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import '../data/local/database.dart';
import '../data/local/group_dao.dart';

class LoanExportResult {
  const LoanExportResult({
    required this.bytes,
    required this.mimeType,
    required this.fileName,
  });

  final Uint8List bytes;
  final String mimeType;
  final String fileName;
}

class LoanExportService {
  const LoanExportService();

  Future<LoanExportResult> exportLoans({
    required List<LoanDetail> loanDetails,
    required LocalUser activeUser,
  }) async {
    // Separate loans into two sections: as lender and as borrower
    final asLender = <LoanDetail>[];
    final asBorrower = <LoanDetail>[];

    for (final detail in loanDetails) {
      if (detail.loan.lenderUserId == activeUser.id) {
        asLender.add(detail);
      } else if (detail.loan.borrowerUserId == activeUser.id) {
        asBorrower.add(detail);
      }
    }

    const headers = [
      'Título del libro',
      'Prestatario',
      'Fecha de solicitud',
      'Fecha de aprobación',
      'Fecha de vencimiento',
      'Fecha de devolución',
      'Estado',
      'Tipo',
    ];

    final rows = <List<dynamic>>[];

    // Add section header for loans as lender
    if (asLender.isNotEmpty) {
      rows.add(['=== PRÉSTAMOS QUE HE DADO ===', '', '', '', '', '', '', '']);
      for (final detail in asLender) {
        rows.add(_loanToRow(detail));
      }
      rows.add(['', '', '', '', '', '', '', '']); // Empty row separator
    }

    // Add section header for loans as borrower
    if (asBorrower.isNotEmpty) {
      rows.add(
          ['=== PRÉSTAMOS QUE HE RECIBIDO ===', '', '', '', '', '', '', '']);
      for (final detail in asBorrower) {
        rows.add(_loanToRow(detail));
      }
    }

    const csvConverter = ListToCsvConverter();
    final csvString = csvConverter.convert([headers, ...rows]);

    return LoanExportResult(
      bytes: Uint8List.fromList(utf8.encode(csvString)),
      mimeType: 'text/csv',
      fileName: _fileName('historial_prestamos', 'csv'),
    );
  }

  List<dynamic> _loanToRow(LoanDetail detail) {
    final loan = detail.loan;
    final bookTitle = detail.book?.title ?? 'Libro desconocido';
    final borrowerName =
        loan.externalBorrowerName ?? detail.borrower?.username ?? 'Desconocido';
    final requestedAt = DateFormat.yMd().add_Hm().format(loan.requestedAt);
    final approvedAt = loan.approvedAt != null
        ? DateFormat.yMd().add_Hm().format(loan.approvedAt!)
        : '';
    final dueDate = loan.dueDate != null
        ? DateFormat.yMd().format(loan.dueDate!)
        : 'Sin fecha límite';
    final returnedAt = loan.returnedAt != null
        ? DateFormat.yMd().add_Hm().format(loan.returnedAt!)
        : '';
    final status = _statusLabel(loan.status);
    final loanType = loan.externalBorrowerName != null ? 'Manual' : 'Normal';

    return [
      bookTitle,
      borrowerName,
      requestedAt,
      approvedAt,
      dueDate,
      returnedAt,
      status,
      loanType,
    ];
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'requested':
        return 'Solicitado';
      case 'active':
        return 'Activo';
      case 'returned':
        return 'Devuelto';
      case 'expired':
        return 'Expirado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  String _fileName(String base, String extension) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '${base}_$timestamp.$extension';
  }
}
