import 'package:share_plus/share_plus.dart';
import '../data/local/database.dart';

class ShareUtils {
  static Future<void> shareBookRecommendation(Book book) async {
    final text = 'He leído este libro y me he acordado de ti 📚\n\n'
        '"${book.title}"${book.author != null ? ' de ${book.author}' : ''}\n\n'
        '¡Descárgate PassTheBook para compartir lecturas!';
    await Share.share(text);
  }
}
