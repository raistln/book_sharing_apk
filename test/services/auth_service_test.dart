import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/repositories/user_repository.dart';
import 'package:book_sharing_app/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserRepository extends Mock implements UserRepository {}

class _InMemoryAuthStorage implements AuthStorageAdapter {
  final Map<String, String> _store = {};

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async {
    _store[key] = value;
  }
}

void main() {
  group('AuthService', () {
    late _MockUserRepository userRepository;
    late _InMemoryAuthStorage storage;
    late AuthService authService;

    LocalUser buildUser({
      String? pinHash,
      String? pinSalt,
      DateTime? pinUpdatedAt,
      bool isDirty = false,
    }) {
      final now = DateTime.now();
      return LocalUser(
        id: 1,
        uuid: 'user-uuid',
        username: 'alice',
        remoteId: 'remote-uuid',
        pinHash: pinHash,
        pinSalt: pinSalt,
        pinUpdatedAt: pinUpdatedAt,
        isDirty: isDirty,
        isDeleted: false,
        syncedAt: now,
        createdAt: now,
        updatedAt: now,
      );
    }

    setUp(() {
      userRepository = _MockUserRepository();
      storage = _InMemoryAuthStorage();
      authService = AuthService(
        userRepository: userRepository,
        storageAdapter: storage,
      );
    });

    test('hashPinWithSalt is deterministic and sensitive to inputs', () {
      const pin = '1234';
      const salt = 'random-salt';

      final hash1 = AuthService.hashPinWithSalt(pin, salt);
      final hash2 = AuthService.hashPinWithSalt(pin, salt);
      final hash3 = AuthService.hashPinWithSalt('4321', salt);

      expect(hash1, hash2);
      expect(hash3, isNot(hash1));
    });

    test('verifyPin returns true when stored hash matches', () async {
      const salt = 'salt';
      const pin = '6789';
      final hash = AuthService.hashPinWithSalt(pin, salt);
      final user = buildUser(pinHash: hash, pinSalt: salt);

      when(() => userRepository.getActiveUser()).thenAnswer((_) async => user);

      final result = await authService.verifyPin(pin);
      final mismatch = await authService.verifyPin('0000');

      expect(result, isTrue);
      expect(mismatch, isFalse);
    });

    test('setPin hashes and stores the PIN via repository', () async {
      final user = buildUser();
      when(() => userRepository.getActiveUser()).thenAnswer((_) async => user);

      DateTime? capturedUpdatedAt;
      String? capturedHash;
      String? capturedSalt;
      bool? capturedMarkDirty;

      when(
        () => userRepository.updatePinData(
          userId: any(named: 'userId'),
          pinHash: any(named: 'pinHash'),
          pinSalt: any(named: 'pinSalt'),
          pinUpdatedAt: any(named: 'pinUpdatedAt'),
          markDirty: any(named: 'markDirty'),
        ),
      ).thenAnswer((invocation) async {
        capturedHash = invocation.namedArguments[#pinHash] as String;
        capturedSalt = invocation.namedArguments[#pinSalt] as String;
        capturedUpdatedAt = invocation.namedArguments[#pinUpdatedAt] as DateTime;
        capturedMarkDirty = invocation.namedArguments[#markDirty] as bool;
      });

      await authService.setPin('2468');

      expect(capturedHash, isNotNull);
      expect(capturedSalt, isNotNull);
      expect(capturedHash!.isNotEmpty, isTrue);
      expect(capturedSalt!.isNotEmpty, isTrue);
      expect(capturedUpdatedAt, isNotNull);
      expect(capturedMarkDirty, isTrue);

      verify(
        () => userRepository.updatePinData(
          userId: user.id,
          pinHash: capturedHash!,
          pinSalt: capturedSalt!,
          pinUpdatedAt: capturedUpdatedAt!,
          markDirty: true,
        ),
      ).called(1);
    });

    test('clearPin removes stored hash and locks the session', () async {
      final user = buildUser();
      when(() => userRepository.getActiveUser()).thenAnswer((_) async => user);
      when(() => userRepository.clearPinData(userId: user.id)).thenAnswer((_) async {});

      await authService.clearPin();

      verify(() => userRepository.clearPinData(userId: user.id)).called(1);
      expect(await storage.read('auth.session_locked'), equals('true'));
    });

    test('hasConfiguredPin depends on active user pin fields', () async {
      when(() => userRepository.getActiveUser()).thenAnswer((_) async => null);
      expect(await authService.hasConfiguredPin(), isFalse);

      final userWithoutPin = buildUser(pinHash: null, pinSalt: null);
      when(() => userRepository.getActiveUser())
          .thenAnswer((_) async => userWithoutPin);
      expect(await authService.hasConfiguredPin(), isFalse);

      final userWithPin = buildUser(pinHash: 'hash', pinSalt: 'salt');
      when(() => userRepository.getActiveUser()).thenAnswer((_) async => userWithPin);
      expect(await authService.hasConfiguredPin(), isTrue);
    });
  });
}
