import 'dart:collection';

import 'package:book_sharing_app/data/local/database.dart';
import 'package:book_sharing_app/data/local/group_dao.dart';
import 'package:book_sharing_app/services/discover_group_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiscoverGroupController', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.test(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('loadInitial grows page size on fast full fetch', () async {
      final dao = _StubbedGroupDao(
        db,
        responses: [
          _StubbedFetchResponse(
            builder: (call) => _generateSharedDetails(call.limit),
          ),
        ],
      );

      final controller = DiscoverGroupController(groupDao: dao, groupId: 1);
      await controller.loadInitial(force: true);

      expect(dao.calls, hasLength(1));
      expect(dao.calls.first.limit, 20);

      final state = controller.state;
      expect(state.items, hasLength(20));
      expect(state.hasMore, isTrue);
      expect(state.pageSize, 25);
      expect(state.isLargeDataset, isTrue);
      expect(state.loadedFromCache, isFalse);
    });

    test('loadMore shrinks page size after slow partial fetch', () async {
      final dao = _StubbedGroupDao(
        db,
        responses: [
          _StubbedFetchResponse(
            builder: (call) => _generateSharedDetails(call.limit),
          ),
          _StubbedFetchResponse(
            delay: const Duration(milliseconds: 800),
            builder: (call) => _generateSharedDetails(5, startId: call.offset),
          ),
        ],
      );

      final controller = DiscoverGroupController(groupDao: dao, groupId: 1);
      await controller.loadInitial(force: true);
      await controller.loadMore();

      expect(dao.calls, hasLength(2));
      expect(dao.calls[0].limit, 20);
      expect(dao.calls[1].limit, 25);

      final state = controller.state;
      expect(state.items, hasLength(25));
      expect(state.hasMore, isFalse);
      expect(state.pageSize, 20);
      expect(state.isLargeDataset, isFalse);
    });

    test('large dataset flag stays true when total count exceeds threshold', () async {
      final dao = _StubbedGroupDao(
        db,
        responses: [
          _StubbedFetchResponse(
            builder: (call) => _generateSharedDetails(call.limit),
          ),
          _StubbedFetchResponse(
            builder: (call) => _generateSharedDetails(call.limit, startId: call.offset),
          ),
          _StubbedFetchResponse(
            builder: (call) => _generateSharedDetails(15, startId: call.offset),
          ),
        ],
      );

      final controller = DiscoverGroupController(groupDao: dao, groupId: 1);
      await controller.loadInitial(force: true);
      await controller.loadMore();
      await controller.loadMore();

      expect(dao.calls, hasLength(3));

      final state = controller.state;
      expect(state.items.length, 60);
      expect(state.hasMore, isFalse);
      expect(state.pageSize, 30);
      expect(state.isLargeDataset, isTrue);
    });

    test('updateSearch resets page size before refetch', () async {
      final dao = _StubbedGroupDao(
        db,
        responses: [
          _StubbedFetchResponse(
            builder: (call) => _generateSharedDetails(call.limit),
          ),
          _StubbedFetchResponse(
            builder: (call) => _generateSharedDetails(call.limit, startId: call.offset + 100),
          ),
        ],
      );

      final controller = DiscoverGroupController(groupDao: dao, groupId: 1);
      await controller.loadInitial(force: true);

      expect(controller.state.pageSize, 25);

      await controller.updateSearch('harry');

      expect(dao.calls.length, 2);
      expect(dao.calls[1].limit, 20);
      expect(dao.calls[1].searchQuery, 'harry');

      final state = controller.state;
      expect(state.searchQuery, 'harry');
      expect(state.items, hasLength(20));
      expect(state.pageSize, 25);
      expect(state.loadedFromCache, isFalse);
      expect(state.isLargeDataset, isTrue);
    });

    test('loadInitial with force=false returns cached data without dao hit', () async {
      final dao = _StubbedGroupDao(
        db,
        responses: [
          _StubbedFetchResponse(
            builder: (call) => _generateSharedDetails(call.limit),
          ),
        ],
      );

      final controller = DiscoverGroupController(groupDao: dao, groupId: 42);
      await controller.loadInitial(force: true);
      expect(dao.calls, hasLength(1));
      expect(controller.state.loadedFromCache, isFalse);

      await controller.loadInitial(force: false);

      expect(dao.calls, hasLength(1));
      final state = controller.state;
      expect(state.loadedFromCache, isTrue);
      expect(state.items, hasLength(20));
      expect(state.pageSize, greaterThanOrEqualTo(20));
    });

    test('setIncludeUnavailable triggers refetch with flag and resets dataset size', () async {
      final dao = _StubbedGroupDao(
        db,
        responses: [
          _StubbedFetchResponse(
            builder: (call) => _generateSharedDetails(call.limit),
          ),
          _StubbedFetchResponse(
            builder: (call) => _generateSharedDetails(call.limit, startId: call.offset + 200),
          ),
        ],
      );

      final controller = DiscoverGroupController(groupDao: dao, groupId: 7);
      await controller.loadInitial(force: true);
      expect(controller.state.includeUnavailable, isFalse);
      expect(controller.state.pageSize, 25);

      await controller.setIncludeUnavailable(true);

      expect(dao.calls, hasLength(2));
      expect(dao.calls[1].includeUnavailable, isTrue);
      expect(dao.calls[1].limit, 20);

      final state = controller.state;
      expect(state.includeUnavailable, isTrue);
      expect(state.items, hasLength(20));
      expect(state.pageSize, 25);
      expect(state.isLargeDataset, isTrue);
    });
  });
}

class _StubbedGroupDao extends GroupDao {
  _StubbedGroupDao(
    super.db, {
    required Iterable<_StubbedFetchResponse> responses,
  }) : _responses = Queue<_StubbedFetchResponse>.of(responses);

  final Queue<_StubbedFetchResponse> _responses;
  final List<_FetchCall> calls = [];

  @override
  Future<List<SharedBookDetail>> fetchSharedBooksPage({
    required int groupId,
    required int limit,
    required int offset,
    bool includeUnavailable = false,
    String? searchQuery,
  }) async {
    if (_responses.isEmpty) {
      fail('No stubbed response configured');
    }

    final call = _FetchCall(
      groupId: groupId,
      limit: limit,
      offset: offset,
      includeUnavailable: includeUnavailable,
      searchQuery: searchQuery,
    );
    calls.add(call);

    final response = _responses.removeFirst();
    if (response.delay != Duration.zero) {
      await Future<void>.delayed(response.delay);
    }
    return response.builder(call);
  }
}

class _FetchCall {
  _FetchCall({
    required this.groupId,
    required this.limit,
    required this.offset,
    required this.includeUnavailable,
    required this.searchQuery,
  });

  final int groupId;
  final int limit;
  final int offset;
  final bool includeUnavailable;
  final String? searchQuery;
}

class _StubbedFetchResponse {
  _StubbedFetchResponse({
    this.delay = Duration.zero,
    required this.builder,
  });

  final Duration delay;
  final List<SharedBookDetail> Function(_FetchCall call) builder;
}

final DateTime _baseDate = DateTime(2024, 1, 1);

List<SharedBookDetail> _generateSharedDetails(int count, {int startId = 0}) {
  return List<SharedBookDetail>.generate(count, (index) {
    final id = startId + index + 1;
    return SharedBookDetail(
      sharedBook: SharedBook(
        id: id,
        uuid: 'shared-$id',
        remoteId: null,
        groupId: 1,
        groupUuid: 'group-uuid',
        bookId: id,
        bookUuid: 'book-$id',
        ownerUserId: 1,
        ownerRemoteId: 'owner-remote',
        visibility: 'group',
        isAvailable: true,
        isDirty: false,
        isDeleted: false,
        syncedAt: null,
        createdAt: _baseDate,
        updatedAt: _baseDate,
      ),
      book: Book(
        id: id,
        uuid: 'book-$id',
        remoteId: null,
        ownerUserId: 1,
        ownerRemoteId: 'owner-remote',
        title: 'Book $id',
        author: 'Author $id',
        isbn: 'isbn-$id',
        barcode: null,
        coverPath: null,
        status: 'available',
        notes: null,
        isDirty: false,
        isDeleted: false,
        syncedAt: null,
        createdAt: _baseDate,
        updatedAt: _baseDate,
      ),
    );
  });
}
