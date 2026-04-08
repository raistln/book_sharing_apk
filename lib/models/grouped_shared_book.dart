import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';

class GroupedSharedBook {
  final Book? book;
  final List<SharedBookDetail> allCopies;

  GroupedSharedBook({
    required this.book,
    required this.allCopies,
  });

  int get count => allCopies.length;

  String get title => book?.title ?? 'Sin título';
  String get author => book?.author ?? 'Anónimo';
  String get coverPath => book?.coverPath ?? '';
  
  /// Returns whether at least one copy is currently available for loan.
  bool get isAnyAvailable => allCopies.any((detail) => detail.sharedBook.isAvailable);
}
