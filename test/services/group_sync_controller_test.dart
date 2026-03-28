import 'package:book_sharing_app/data/repositories/supabase_group_repository.dart';
import 'package:book_sharing_app/data/repositories/user_repository.dart';
import 'package:book_sharing_app/services/group_sync_controller.dart';
import 'package:book_sharing_app/services/supabase_config_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseGroupSyncRepository extends Mock implements SupabaseGroupSyncRepository {}
class MockUserRepository extends Mock implements UserRepository {}
class MockSupabaseConfigService extends Mock implements SupabaseConfigService {}

void main() {
  late MockSupabaseGroupSyncRepository mockGroupRepo;
  late MockUserRepository mockUserRepo;
  late MockSupabaseConfigService mockConfigService;
  late GroupSyncController controller;

  setUp(() {
    mockGroupRepo = MockSupabaseGroupSyncRepository();
    mockUserRepo = MockUserRepository();
    mockConfigService = MockSupabaseConfigService();
    controller = GroupSyncController(
      groupRepository: mockGroupRepo,
      userRepository: mockUserRepo,
      configService: mockConfigService,
    );
  });

  group('GroupSyncController', () {
    test('can be instantiated', () {
      expect(controller, isNotNull);
    });
    test('initial state is correct', () {
      expect(controller.state.isSyncing, false);
      expect(controller.state.hasPendingChanges, false);
      expect(controller.state.lastError, null);
      expect(controller.state.lastSyncedAt, null);
    });
  });
}
