import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    required this.pageSize,
    required this.lastLoadedAt,
    required this.lastLoadDuration,
    required this.loadedFromCache,
    required this.isLargeDataset,
    this.error,
  });

  factory DiscoverGroupState.initial() => const DiscoverGroupState(
        items: <SharedBookDetail>[],
        isLoadingInitial: false,
        isLoadingMore: false,
        hasMore: true,
        searchQuery: '',
        includeUnavailable: false,
        pageSize: _discoverBasePageSize,
        lastLoadedAt: null,
        lastLoadDuration: null,
        loadedFromCache: false,
        isLargeDataset: false,
        error: null,
      );

  final List<SharedBookDetail> items;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final bool hasMore;
  final String searchQuery;
  final bool includeUnavailable;
  final int pageSize;
  final DateTime? lastLoadedAt;
  final Duration? lastLoadDuration;
  final bool loadedFromCache;
  final bool isLargeDataset;
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
      error: identical(error, _sentinel) ? this.error : error,
    );
  }

  static const Object _sentinel = Object();
}

class DiscoverGroupController extends StateNotifier<DiscoverGroupState> {
  DiscoverGroupController({
    required GroupDao groupDao,
    required this.groupId,
  })  : _groupDao = groupDao,
        super(DiscoverGroupState.initial()) {
    Future<void>.microtask(() => loadInitial(force: true));
  }

  final GroupDao _groupDao;
  final int groupId;
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
      );
      if (!cached.isStale) {
        return;
      }
    }

    final requestId = ++_lastRequestId;
    state = state.copyWith(
      isLoadingInitial: true,
      hasMore: true,
      error: null,
      items: cached == null || force ? <SharedBookDetail>[] : state.items,
      loadedFromCache: cached != null,
      pageSize: pageSize,
      isLargeDataset: cached?.isLargeDataset ?? false,
    );

    try {
      final start = DateTime.now();
      debugPrint('[DiscoverGroupController] Fetch initial page (group=$groupId, offset=0, limit=$pageSize, query="${state.searchQuery}", includeUnavailable=${state.includeUnavailable})');
      final results = await _groupDao.fetchSharedBooksPage(
        groupId: groupId,
        limit: pageSize,
        offset: 0,
        includeUnavailable: state.includeUnavailable,
        searchQuery: state.searchQuery,
      );
      final completedAt = DateTime.now();
      final duration = completedAt.difference(start);

      if (requestId != _lastRequestId) {
        return;
      }

      final hasMore = results.length == pageSize;
      final nextPageSize = _computeNextPageSize(
        currentPageSize: pageSize,
        duration: duration,
        fetchedCount: results.length,
      );
      _pageSize = nextPageSize;
      final isLargeDataset = hasMore || results.length >= _discoverLargeDatasetThreshold;

      state = state.copyWith(
        items: results,
        hasMore: hasMore,
        isLoadingInitial: false,
        isLoadingMore: false,
        error: null,
        lastLoadedAt: completedAt,
        lastLoadDuration: duration,
        loadedFromCache: false,
        pageSize: nextPageSize,
        isLargeDataset: isLargeDataset,
      );

      _cache[cacheKey] = _DiscoverCacheEntry(
        items: results,
        hasMore: hasMore,
        fetchedAt: completedAt,
        duration: duration,
        pageSize: nextPageSize,
        isLargeDataset: isLargeDataset,
      );
      debugPrint('[DiscoverGroupController] Initial page loaded ${results.length} items in ${duration.inMilliseconds} ms (nextPageSize=$nextPageSize)');
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
      debugPrint('[DiscoverGroupController] Fetch more (group=$groupId, offset=${state.items.length}, limit=$pageSize)');
      final results = await _groupDao.fetchSharedBooksPage(
        groupId: groupId,
        limit: pageSize,
        offset: state.items.length,
        includeUnavailable: state.includeUnavailable,
        searchQuery: state.searchQuery,
      );
      final completedAt = DateTime.now();
      final duration = completedAt.difference(start);

      final updatedItems = [...state.items, ...results];
      final hasMore = results.length == pageSize;
      final nextPageSize = _computeNextPageSize(
        currentPageSize: pageSize,
        duration: duration,
        fetchedCount: results.length,
      );
      _pageSize = nextPageSize;
      final totalCount = updatedItems.length;
      final isLargeDataset = hasMore || totalCount >= _discoverLargeDatasetThreshold;

      state = state.copyWith(
        items: updatedItems,
        hasMore: hasMore,
        isLoadingMore: false,
        lastLoadedAt: completedAt,
        lastLoadDuration: duration,
        loadedFromCache: false,
        pageSize: nextPageSize,
        isLargeDataset: isLargeDataset,
      );

      _cache[_cacheKey()] = _DiscoverCacheEntry(
        items: updatedItems,
        hasMore: hasMore,
        fetchedAt: completedAt,
        duration: duration,
        pageSize: nextPageSize,
        isLargeDataset: isLargeDataset,
      );
      debugPrint('[DiscoverGroupController] Append page with ${results.length} items in ${duration.inMilliseconds} ms (nextPageSize=$nextPageSize)');
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
    );
    await loadInitial(force: false);
  }

  _DiscoverCacheKey _cacheKey() => _DiscoverCacheKey(
        groupId: groupId,
        searchQuery: state.searchQuery,
        includeUnavailable: state.includeUnavailable,
      );

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
  });

  final int groupId;
  final String searchQuery;
  final bool includeUnavailable;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _DiscoverCacheKey &&
        other.groupId == groupId &&
        other.searchQuery == searchQuery &&
        other.includeUnavailable == includeUnavailable;
  }

  @override
  int get hashCode => Object.hash(groupId, searchQuery, includeUnavailable);
}

class _DiscoverCacheEntry {
  _DiscoverCacheEntry({
    required this.items,
    required this.hasMore,
    required this.fetchedAt,
    required this.duration,
    required this.pageSize,
    required this.isLargeDataset,
  });

  final List<SharedBookDetail> items;
  final bool hasMore;
  final DateTime fetchedAt;
  final Duration duration;
  final int pageSize;
  final bool isLargeDataset;

  bool get isStale => DateTime.now().difference(fetchedAt) > _discoverCacheTtl;
}
