import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../data/local/group_dao.dart';

const _discoverBasePageSize = 20;
const _discoverMinPageSize = 10;
const _discoverMaxPageSize = 40;
const _discoverPageAdjustStep = 5;
const _discoverFastFetchThreshold = Duration(milliseconds: 300);
const _discoverSlowFetchThreshold = Duration(milliseconds: 750);
const _discoverCacheTtl = Duration(minutes: 5);
const _discoverLargeDatasetThreshold = 60;

class DiscoverGroupState {
  const DiscoverGroupState({
    required this.items,
    required this.isLoadingInitial,
    required this.isLoadingMore,
    required this.hasMore,
    required this.searchQuery,
    required this.includeUnavailable,
    required this.ownerUserIdFilter,
    required this.pageSize,
    required this.lastLoadedAt,
    required this.lastLoadDuration,
    required this.loadedFromCache,
    required this.isLargeDataset,
    required this.invalidatedSharedBookIds,
    this.error,
  });

  factory DiscoverGroupState.initial() => const DiscoverGroupState(
        items: <SharedBookDetail>[],
        isLoadingInitial: false,
        isLoadingMore: false,
        hasMore: true,
        searchQuery: '',
        includeUnavailable: false,
        ownerUserIdFilter: null,
        pageSize: _discoverBasePageSize,
        lastLoadedAt: null,
        lastLoadDuration: null,
        loadedFromCache: false,
        isLargeDataset: false,
        invalidatedSharedBookIds: <int>{},
        error: null,
      );

  final List<SharedBookDetail> items;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final bool hasMore;
  final String searchQuery;
  final bool includeUnavailable;
  final int? ownerUserIdFilter;
  final int pageSize;
  final DateTime? lastLoadedAt;
  final Duration? lastLoadDuration;
  final bool loadedFromCache;
  final bool isLargeDataset;
  final Set<int> invalidatedSharedBookIds;
  final Object? error;

  DiscoverGroupState copyWith({
    List<SharedBookDetail>? items,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    bool? hasMore,
    String? searchQuery,
    bool? includeUnavailable,
    int? pageSize,
    Object? lastLoadedAt = _sentinel,
    Object? lastLoadDuration = _sentinel,
    bool? loadedFromCache,
    bool? isLargeDataset,
    Object? ownerUserIdFilter = _sentinel,
    Set<int>? invalidatedSharedBookIds,
    Object? error = _sentinel,
  }) {
    return DiscoverGroupState(
      items: items ?? this.items,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      includeUnavailable: includeUnavailable ?? this.includeUnavailable,
      pageSize: pageSize ?? this.pageSize,
      lastLoadedAt: identical(lastLoadedAt, _sentinel)
          ? this.lastLoadedAt
          : lastLoadedAt as DateTime?,
      lastLoadDuration: identical(lastLoadDuration, _sentinel)
          ? this.lastLoadDuration
          : lastLoadDuration as Duration?,
      loadedFromCache: loadedFromCache ?? this.loadedFromCache,
      isLargeDataset: isLargeDataset ?? this.isLargeDataset,
      ownerUserIdFilter: identical(ownerUserIdFilter, _sentinel)
          ? this.ownerUserIdFilter
          : ownerUserIdFilter as int?,
      invalidatedSharedBookIds:
          invalidatedSharedBookIds ?? this.invalidatedSharedBookIds,
      error: identical(error, _sentinel) ? this.error : error,
    );
  }

  static const Object _sentinel = Object();
}

class DiscoverGroupController extends StateNotifier<DiscoverGroupState> {
  DiscoverGroupController({
    required GroupDao groupDao,
    required this.groupId,
    this.activeUser,
    this.ownBooks = const <Book>[],
  })  : _groupDao = groupDao,
        super(DiscoverGroupState.initial()) {
    Future<void>.microtask(() => loadInitial(force: true));
  }

  final GroupDao _groupDao;
  final int groupId;
  final LocalUser? activeUser;
  final List<Book> ownBooks;
  int _lastRequestId = 0;
  int _pageSize = _discoverBasePageSize;

  static final Map<_DiscoverCacheKey, _DiscoverCacheEntry> _cache = {};

  Future<void> loadInitial({bool force = false}) async {
    if (state.isLoadingInitial) {
      return;
    }

    int pageSize = _pageSize;
    final cacheKey = _cacheKey();
    final cached = !force ? _cache[cacheKey] : null;
    if (cached != null) {
      _pageSize = cached.pageSize;
      pageSize = cached.pageSize;
      state = state.copyWith(
        items: cached.items,
        hasMore: cached.hasMore,
        isLoadingInitial: false,
        isLoadingMore: false,
        error: null,
        lastLoadedAt: cached.fetchedAt,
        lastLoadDuration: cached.duration,
        loadedFromCache: true,
        pageSize: cached.pageSize,
        isLargeDataset: cached.isLargeDataset,
        invalidatedSharedBookIds: cached.invalidatedIds,
      );
      if (!cached.isStale && state.invalidatedSharedBookIds.isEmpty) {
        return;
      }
    }

    final pendingInvalidations = state.invalidatedSharedBookIds;
    final requestId = ++_lastRequestId;
    state = state.copyWith(
      isLoadingInitial: true,
      hasMore: true,
      error: null,
      items: cached == null || force ? <SharedBookDetail>[] : state.items,
      loadedFromCache: cached != null,
      pageSize: pageSize,
      isLargeDataset: cached?.isLargeDataset ?? false,
      invalidatedSharedBookIds: <int>{},
    );

    try {
      final start = DateTime.now();
      if (kDebugMode) {
        debugPrint(
            '[DiscoverGroupController] Fetch initial page (group=$groupId, offset=0, limit=$pageSize, query="${state.searchQuery}", includeUnavailable=${state.includeUnavailable}, owner=${state.ownerUserIdFilter})');
      }
      final invalidatedIds = pendingInvalidations;
      final excludeIsbns = ownBooks
          .map((b) => b.isbn?.trim())
          .whereType<String>()
          .where((isbn) => isbn.isNotEmpty)
          .toList();

      final results = await _groupDao.fetchSharedBooksPage(
        groupId: groupId,
        limit: pageSize,
        offset: 0,
        includeUnavailable: state.includeUnavailable,
        searchQuery: state.searchQuery,
        ownerUserId: state.ownerUserIdFilter,
        excludeUserId: activeUser?.id,
        excludeIsbns: excludeIsbns,
      );

      final completedAt = DateTime.now();
      final duration = completedAt.difference(start);

      if (requestId != _lastRequestId) {
        return;
      }

      final filteredResults = results
          .where(
            (detail) => !invalidatedIds.contains(detail.sharedBook.id),
          )
          .toList();

      final hasMore = filteredResults.length == pageSize;
      final nextPageSize = _computeNextPageSize(
        currentPageSize: pageSize,
        duration: duration,
        fetchedCount: filteredResults.length,
      );
      _pageSize = nextPageSize;
      final isLargeDataset =
          hasMore || filteredResults.length >= _discoverLargeDatasetThreshold;

      state = state.copyWith(
        items: filteredResults,
        hasMore: hasMore,
        isLoadingInitial: false,
        isLoadingMore: false,
        error: null,
        lastLoadedAt: completedAt,
        lastLoadDuration: duration,
        loadedFromCache: false,
        pageSize: nextPageSize,
        isLargeDataset: isLargeDataset,
        invalidatedSharedBookIds: <int>{},
      );

      _cache[cacheKey] = _DiscoverCacheEntry(
        items: filteredResults,
        hasMore: hasMore,
        fetchedAt: completedAt,
        duration: duration,
        pageSize: nextPageSize,
        isLargeDataset: isLargeDataset,
        invalidatedIds: {},
      );
      if (kDebugMode) {
        debugPrint(
            '[DiscoverGroupController] Initial page loaded ${results.length} items in ${duration.inMilliseconds} ms (nextPageSize=$nextPageSize)');
      }
    } catch (error, stackTrace) {
      if (requestId != _lastRequestId) {
        return;
      }
      Zone.current.handleUncaughtError(error, stackTrace);
      state = state.copyWith(
        isLoadingInitial: false,
        isLoadingMore: false,
        hasMore: false,
        error: error,
        invalidatedSharedBookIds: pendingInvalidations,
      );
    }
  }

  Future<void> refresh() => loadInitial(force: true);

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoadingInitial) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final start = DateTime.now();
      final pageSize = _pageSize;
      if (kDebugMode) {
        debugPrint(
            '[DiscoverGroupController] Fetch more (group=$groupId, offset=${state.items.length}, limit=$pageSize, owner=${state.ownerUserIdFilter})');
      }
      final excludeIsbns = ownBooks
          .map((b) => b.isbn?.trim())
          .whereType<String>()
          .where((isbn) => isbn.isNotEmpty)
          .toList();

      final results = await _groupDao.fetchSharedBooksPage(
        groupId: groupId,
        limit: pageSize,
        offset: state.items.length,
        includeUnavailable: state.includeUnavailable,
        searchQuery: state.searchQuery,
        ownerUserId: state.ownerUserIdFilter,
        excludeUserId: activeUser?.id,
        excludeIsbns: excludeIsbns,
      );

      final completedAt = DateTime.now();
      final duration = completedAt.difference(start);

      final invalidatedIds = state.invalidatedSharedBookIds;
      final newResults = results
          .where((detail) => !invalidatedIds.contains(detail.sharedBook.id))
          .toList();
      final updatedItems = [...state.items, ...newResults];
      final hasMore = results.length == pageSize;
      final nextPageSize = _computeNextPageSize(
        currentPageSize: pageSize,
        duration: duration,
        fetchedCount: newResults.length,
      );
      _pageSize = nextPageSize;
      final totalCount = updatedItems.length;
      final isLargeDataset =
          hasMore || totalCount >= _discoverLargeDatasetThreshold;

      state = state.copyWith(
        items: updatedItems,
        hasMore: hasMore,
        isLoadingMore: false,
        lastLoadedAt: completedAt,
        lastLoadDuration: duration,
        loadedFromCache: false,
        pageSize: nextPageSize,
        isLargeDataset: isLargeDataset,
        invalidatedSharedBookIds: <int>{},
      );

      final cacheKey = _cacheKey();
      _cache[cacheKey] = _DiscoverCacheEntry(
        items: updatedItems,
        hasMore: hasMore,
        fetchedAt: completedAt,
        duration: duration,
        pageSize: nextPageSize,
        isLargeDataset: isLargeDataset,
        invalidatedIds: {},
      );
      if (kDebugMode) {
        debugPrint(
            '[DiscoverGroupController] Append page with ${results.length} items in ${duration.inMilliseconds} ms (nextPageSize=$nextPageSize)');
      }
    } catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
      state = state.copyWith(isLoadingMore: false, error: error);
    }
  }

  Future<void> updateSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed == state.searchQuery) {
      return;
    }
    _resetPageSize();
    state = state.copyWith(
      searchQuery: trimmed,
      items: <SharedBookDetail>[],
      hasMore: true,
      error: null,
      lastLoadedAt: null,
      lastLoadDuration: null,
      loadedFromCache: false,
      pageSize: _pageSize,
      isLargeDataset: false,
      invalidatedSharedBookIds: <int>{},
    );
    await loadInitial(force: false);
  }

  Future<void> setIncludeUnavailable(bool value) async {
    if (value == state.includeUnavailable) {
      return;
    }
    _resetPageSize();
    state = state.copyWith(
      includeUnavailable: value,
      items: <SharedBookDetail>[],
      hasMore: true,
      error: null,
      lastLoadedAt: null,
      loadedFromCache: false,
      pageSize: _pageSize,
      isLargeDataset: false,
      invalidatedSharedBookIds: <int>{},
    );
    await loadInitial(force: false);
  }

  Future<void> setOwnerFilter(int? userId) async {
    if (state.ownerUserIdFilter == userId) {
      return;
    }
    _resetPageSize();
    state = state.copyWith(
      ownerUserIdFilter: userId,
      items: <SharedBookDetail>[],
      hasMore: true,
      error: null,
      lastLoadedAt: null,
      lastLoadDuration: null,
      loadedFromCache: false,
      pageSize: _pageSize,
      isLargeDataset: false,
      invalidatedSharedBookIds: <int>{},
    );
    await loadInitial(force: false);
  }

  void invalidateSharedBooks(Iterable<int> sharedBookIds) {
    final ids = sharedBookIds.whereType<int>().toSet();
    if (ids.isEmpty) {
      return;
    }
    final updatedItems = state.items
        .where((detail) => !ids.contains(detail.sharedBook.id))
        .toList(growable: false);
    state = state.copyWith(
      items: updatedItems,
      hasMore: true,
      invalidatedSharedBookIds: {...state.invalidatedSharedBookIds, ...ids},
    );
    final cacheKey = _cacheKey();
    final cached = _cache[cacheKey];
    if (cached != null) {
      final updatedCacheItems = cached.items
          .where((detail) => !ids.contains(detail.sharedBook.id))
          .toList(growable: false);
      _cache[cacheKey] = cached.copyWith(
        items: updatedCacheItems,
        hasMore: true,
        invalidatedIds: {...cached.invalidatedIds, ...ids},
      );
    }
  }

  void upsertSharedBooks(List<SharedBookDetail> updates) {
    if (updates.isEmpty) {
      return;
    }

    final updatedIds = updates.map((detail) => detail.sharedBook.id).toSet();
    final cacheKey = _cacheKey();
    final cached = _cache[cacheKey];
    if (cached != null) {
      final mergedCacheItems = _mergeDetails(cached.items, updates);
      final hasMore = cached.hasMore;
      _cache[cacheKey] = cached.copyWith(
        items: mergedCacheItems,
        hasMore: hasMore,
        invalidatedIds: {...cached.invalidatedIds}..removeAll(updatedIds),
      );
    }

    if (state.items.isEmpty) {
      return;
    }

    final mergedItems = _mergeDetails(state.items, updates);
    state = state.copyWith(
      items: mergedItems,
      invalidatedSharedBookIds: {...state.invalidatedSharedBookIds}
        ..removeAll(updatedIds),
    );
  }

  List<SharedBookDetail> _mergeDetails(
    List<SharedBookDetail> current,
    List<SharedBookDetail> updates,
  ) {
    final map = {for (final detail in current) detail.sharedBook.id: detail};
    for (final detail in updates) {
      map[detail.sharedBook.id] = detail;
    }
    final merged = map.values.toList()
      ..sort((a, b) {
        final titleA = (a.book?.title ?? '').toLowerCase();
        final titleB = (b.book?.title ?? '').toLowerCase();
        final titleCompare = titleA.compareTo(titleB);
        if (titleCompare != 0) {
          return titleCompare;
        }
        return a.sharedBook.id.compareTo(b.sharedBook.id);
      });
    return merged;
  }

  _DiscoverCacheKey _cacheKey() {
    final isbnHash = Object.hashAll(ownBooks
        .map((b) => b.isbn?.trim())
        .whereType<String>()
        .where((i) => i.isNotEmpty)
        .toList()
      ..sort());

    return _DiscoverCacheKey(
      groupId: groupId,
      searchQuery: state.searchQuery,
      includeUnavailable: state.includeUnavailable,
      ownerUserId: state.ownerUserIdFilter,
      excludeUserId: activeUser?.id,
      excludeIsbnsHash: isbnHash,
    );
  }

  void _resetPageSize() {
    _pageSize = _discoverBasePageSize;
  }

  int _computeNextPageSize({
    required int currentPageSize,
    required Duration duration,
    required int fetchedCount,
  }) {
    final ms = duration.inMilliseconds;
    if (ms >= _discoverSlowFetchThreshold.inMilliseconds &&
        currentPageSize > _discoverMinPageSize) {
      return (currentPageSize - _discoverPageAdjustStep)
          .clamp(_discoverMinPageSize, _discoverMaxPageSize);
    }

    if (ms <= _discoverFastFetchThreshold.inMilliseconds &&
        fetchedCount == currentPageSize &&
        currentPageSize < _discoverMaxPageSize) {
      return (currentPageSize + _discoverPageAdjustStep)
          .clamp(_discoverMinPageSize, _discoverMaxPageSize);
    }

    return currentPageSize;
  }
}

class _DiscoverCacheKey {
  const _DiscoverCacheKey({
    required this.groupId,
    required this.searchQuery,
    required this.includeUnavailable,
    required this.ownerUserId,
    required this.excludeUserId,
    required this.excludeIsbnsHash,
  });

  final int groupId;
  final String searchQuery;
  final bool includeUnavailable;
  final int? ownerUserId;
  final int? excludeUserId;
  final int excludeIsbnsHash;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _DiscoverCacheKey &&
        other.groupId == groupId &&
        other.searchQuery == searchQuery &&
        other.includeUnavailable == includeUnavailable &&
        other.ownerUserId == ownerUserId &&
        other.excludeUserId == excludeUserId &&
        other.excludeIsbnsHash == excludeIsbnsHash;
  }

  @override
  int get hashCode => Object.hash(
        groupId,
        searchQuery,
        includeUnavailable,
        ownerUserId,
        excludeUserId,
        excludeIsbnsHash,
      );
}

class _DiscoverCacheEntry {
  _DiscoverCacheEntry({
    required this.items,
    required this.hasMore,
    required this.fetchedAt,
    required this.duration,
    required this.pageSize,
    required this.isLargeDataset,
    required this.invalidatedIds,
  });

  final List<SharedBookDetail> items;
  final bool hasMore;
  final DateTime fetchedAt;
  final Duration duration;
  final int pageSize;
  final bool isLargeDataset;
  final Set<int> invalidatedIds;

  bool get isStale => DateTime.now().difference(fetchedAt) > _discoverCacheTtl;

  _DiscoverCacheEntry copyWith({
    List<SharedBookDetail>? items,
    bool? hasMore,
    Set<int>? invalidatedIds,
  }) {
    return _DiscoverCacheEntry(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      fetchedAt: fetchedAt,
      duration: duration,
      pageSize: pageSize,
      isLargeDataset: isLargeDataset,
      invalidatedIds: invalidatedIds ?? this.invalidatedIds,
    );
  }
}
