import 'package:book_sharing_app/data/local/club_dao.dart';
import 'package:book_sharing_app/services/section_comment_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockClubDao extends Mock implements ClubDao {}

void main() {
  late MockClubDao mockDao;
  late SectionCommentService service;

  setUp(() {
    mockDao = MockClubDao();
    service = SectionCommentService(dao: mockDao);
  });

  group('SectionCommentService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });
  });
}
