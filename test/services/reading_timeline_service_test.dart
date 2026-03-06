import 'package:book_sharing_app/data/local/book_dao.dart';
import 'package:book_sharing_app/data/local/timeline_entry_dao.dart';
import 'package:book_sharing_app/services/reading_timeline_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBookDao extends Mock implements BookDao {}
class MockTimelineEntryDao extends Mock implements TimelineEntryDao {}

void main() {
  late MockBookDao mockBookDao;
  late MockTimelineEntryDao mockTimelineEntryDao;
  late ReadingTimelineService service;

  setUp(() {
    mockBookDao = MockBookDao();
    mockTimelineEntryDao = MockTimelineEntryDao();
    service = ReadingTimelineService(
      bookDao: mockBookDao,
      timelineDao: mockTimelineEntryDao,
    );
  });

  group('ReadingTimelineService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });
  });
}
