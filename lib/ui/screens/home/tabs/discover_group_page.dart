import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../data/local/database.dart';
import '../../../../data/local/group_dao.dart';
import '../../../../providers/book_providers.dart';
import '../../../../services/coach_marks/coach_mark_controller.dart';
import '../../../../services/coach_marks/coach_mark_models.dart';
import '../../../../services/discover_group_controller.dart';
import '../../../../services/onboarding_service.dart';
import '../../../widgets/coach_mark_target.dart';
import '../../../widgets/empty_state.dart';
import 'discover_book_detail_page.dart';
import '../../../../models/book_genre.dart';
import '../../../widgets/library/book_text_list.dart';

/// Helper to resolve owner name
String _resolveOwnerName(LocalUser? ownerUser, int ownerIdFallback) {
  final username = ownerUser?.username.trim();
  if (username != null && username.isNotEmpty) {
    return username;
  }
  return 'Usuario $ownerIdFallback';
}

/// Helper to resolve status display
_DiscoverStatusDisplay _resolveStatusDisplay({
  required ThemeData theme,
  required SharedBook sharedBook,
  LoanDetail? loanDetail,
}) {
  final colors = theme.colorScheme;

  if (loanDetail != null) {
    final status = loanDetail.loan.status;
    if (status == 'requested') {
      return _DiscoverStatusDisplay(
        label: 'Solicitado',
        icon: Icons.schedule_outlined,
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
        caption: 'Solicitud pendiente de aprobación',
      );
    } else if (status == 'active') {
      return _DiscoverStatusDisplay(
        label: 'En préstamo',
        icon: Icons.handshake_outlined,
        background: colors.primaryContainer,
        foreground: colors.onPrimaryContainer,
        caption: 'Préstamo activo',
      );
    }
  }

  if (sharedBook.isAvailable) {
    return _DiscoverStatusDisplay(
      label: 'Disponible',
      icon: Icons.check_circle_outlined,
      background: colors.tertiaryContainer,
      foreground: colors.onTertiaryContainer,
    );
  } else {
    return _DiscoverStatusDisplay(
      label: 'No disponible',
      icon: Icons.block_outlined,
      background: colors.surfaceContainerHighest,
      foreground: colors.onSurface,
    );
  }
}

/// Page showing shared books in a specific group
class DiscoverGroupPage extends ConsumerStatefulWidget {
  const DiscoverGroupPage({super.key, required this.group});

  final Group group;

  @override
  ConsumerState<DiscoverGroupPage> createState() => _DiscoverGroupPageState();
}

class _DiscoverGroupPageState extends ConsumerState<DiscoverGroupPage> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late final FocusNode _searchFocusNode;
  Timer? _searchDebounce;
  bool _pendingDiscoverCoach = false;
  bool _discoverTargetsReady = false;
  bool _discoverCoachTriggered = false;
  bool _waitingDiscoverCompletion = false;
  bool _isGridView = true; // Default to Grid (3 columns)
  late ProviderSubscription<AsyncValue<OnboardingProgress>>
      _discoverProgressSub;
  late ProviderSubscription<CoachMarkState> _discoverCoachSub;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
    _searchFocusNode = FocusNode();
    _searchController.addListener(_onSearchChanged);

    _discoverProgressSub = ref.listenManual<AsyncValue<OnboardingProgress>>(
      onboardingProgressProvider,
      (previous, next) {
        final progress = next.asData?.value;
        if (progress != null && progress.shouldShowDiscoverCoach) {
          _pendingDiscoverCoach = true;
          _maybeTriggerDiscoverCoach();
        }
      },
    );

    _discoverCoachSub = ref.listenManual<CoachMarkState>(
      coachMarkControllerProvider,
      (previous, next) {
        if (_waitingDiscoverCompletion &&
            previous?.sequence == CoachMarkSequence.discover &&
            next.sequence != CoachMarkSequence.discover &&
            !next.isVisible &&
            next.queue.isEmpty) {
          _waitingDiscoverCompletion = false;
          _pendingDiscoverCoach = false;
          unawaited(() async {
            final onboarding = ref.read(onboardingServiceProvider);
            await onboarding.markDiscoverCoachSeen();
            ref.invalidate(onboardingProgressProvider);
          }());
        }
      },
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchFocusNode.dispose();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _discoverProgressSub.close();
    _discoverCoachSub.close();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref
          .read(discoverGroupControllerProvider(widget.group.id).notifier)
          .loadMore();
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    final currentState =
        ref.read(discoverGroupControllerProvider(widget.group.id));
    if (query == currentState.searchQuery) {
      return;
    }
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      ref
          .read(discoverGroupControllerProvider(widget.group.id).notifier)
          .updateSearch(query);
    });
  }

  void _maybeTriggerDiscoverCoach() {
    if (!_pendingDiscoverCoach ||
        _discoverCoachTriggered ||
        !_discoverTargetsReady) {
      return;
    }

    final controller = ref.read(coachMarkControllerProvider.notifier);
    _discoverCoachTriggered = true;
    _waitingDiscoverCompletion = true;
    unawaited(controller.beginSequence(CoachMarkSequence.discover));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final group = widget.group;
    final state = ref.watch(discoverGroupControllerProvider(group.id));
    final controller =
        ref.read(discoverGroupControllerProvider(group.id).notifier);
    final activeUser = ref.watch(activeUserProvider).value;
    final ownBooksAsync = ref.watch(bookListProvider);
    final membersAsync = ref.watch(groupMemberDetailsProvider(group.id));
    final loansAsync = ref.watch(userRelevantLoansProvider(group.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: _isGridView ? 'Ver lista' : 'Ver cuadrícula',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          PopupMenuButton<GroupSortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar por',
            initialValue: state.sortOption,
            onSelected: (option) {
              controller.setSortOption(option);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: GroupSortOption.titleAz,
                child: Text('Título (A-Z)'),
              ),
              const PopupMenuItem(
                value: GroupSortOption.titleZa,
                child: Text('Título (Z-A)'),
              ),
              const PopupMenuItem(
                value: GroupSortOption.authorAz,
                child: Text('Autor (A-Z)'),
              ),
              const PopupMenuItem(
                value: GroupSortOption.authorZa,
                child: Text('Autor (Z-A)'),
              ),
              const PopupMenuItem(
                value: GroupSortOption.newest,
                child: Text('Más recientes'),
              ),
              const PopupMenuItem(
                value: GroupSortOption.oldest,
                child: Text('Más antiguos'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: _DiscoverSearchBar(
                controller: _searchController,
                onClear: () {
                  _searchController.clear();
                  controller.updateSearch('');
                },
                isLoading: state.isLoadingInitial,
                focusNode: _searchFocusNode,
              ),
            ),
            const SizedBox(height: 12),
            CoachMarkTarget(
              id: CoachMarkId.discoverFilterChips,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Genres and Hide Read
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _GenreDropdown(
                            currentValue: state.genreFilter,
                            onChanged: (val) => controller.setGenreFilter(val),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Ocultar leídos'),
                            selected: state.hideRead,
                            onSelected: (value) =>
                                controller.setHideRead(value),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Row 2: Members and Include Unavailable
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _MemberSelector(
                            membersAsync: membersAsync,
                            selectedUserId: state.ownerUserIdFilter,
                            onChanged: (userId) =>
                                controller.setOwnerFilter(userId),
                            activeUserId: activeUser?.id,
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Incluir no disponibles'),
                            selected: state.includeUnavailable,
                            onSelected: (value) =>
                                controller.setIncludeUnavailable(value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 8),
              _DiscoverMetricsBanner(state: state),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ownBooksAsync.when(
                  data: (ownBooks) => _buildResultsList(
                    theme: theme,
                    state: state,
                    controller: controller,
                    ownBooks: ownBooks,
                    activeUser: activeUser,
                    members: membersAsync.asData?.value ??
                        const <GroupMemberDetail>[],
                    loanDetails:
                        loansAsync.asData?.value ?? const <LoanDetail>[],
                    isGridView: _isGridView,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => _DiscoverErrorView(
                    message: 'No pudimos cargar tu biblioteca.',
                    details: '$error',
                    onRetry: () => controller.refresh(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList({
    required ThemeData theme,
    required DiscoverGroupState state,
    required DiscoverGroupController controller,
    required List<Book> ownBooks,
    required LocalUser? activeUser,
    required List<GroupMemberDetail> members,
    required List<LoanDetail> loanDetails,
    required bool isGridView,
  }) {
    if (state.isLoadingInitial && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return _DiscoverErrorView(
        message: 'No pudimos cargar los libros compartidos.',
        details: '${state.error}',
        onRetry: () => controller.refresh(),
      );
    }

    final filtered = state.items;

    if (filtered.isNotEmpty && !_discoverTargetsReady) {
      _discoverTargetsReady = true;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _maybeTriggerDiscoverCoach());
    }

    final ownerNames = <int, String>{
      for (final member in members)
        member.membership.memberUserId:
            _resolveOwnerName(member.user, member.membership.memberUserId),
    };

    final activeLoansBySharedBookId = <int, LoanDetail>{};
    for (final detail in loanDetails) {
      final shared = detail.sharedBook;
      if (shared == null) {
        continue;
      }
      final status = detail.loan.status;
      if (status != 'requested' && status != 'active') {
        // FIXED: accepted -> active
        continue;
      }
      final entry = activeLoansBySharedBookId[shared.id];
      if (entry == null ||
          _loanStatusPriority(status) >
              _loanStatusPriority(entry.loan.status)) {
        activeLoansBySharedBookId[shared.id] = detail;
      }
    }

    if (filtered.isEmpty) {
      final hasSearch = state.searchQuery.isNotEmpty;
      final ownerFilterActive = state.ownerUserIdFilter != null;

      late final String title;
      late final String message;
      EmptyStateAction? action;

      if (hasSearch) {
        title = 'Sin resultados para tu búsqueda';
        message =
            'Revisa el término ingresado o restablece los filtros para ver más libros.';
        action = EmptyStateAction(
          label: 'Limpiar búsqueda',
          icon: Icons.clear,
          variant: EmptyStateActionVariant.text,
          onPressed: () {
            _searchController.clear();
            controller.updateSearch('');
            controller.setOwnerFilter(null);
          },
        );
      } else if (ownerFilterActive) {
        title = 'Sin libros de este miembro';
        message =
            'Prueba con otra persona o vuelve a mostrar todos los libros disponibles.';
        action = EmptyStateAction(
          label: 'Quitar filtro',
          icon: Icons.filter_list_off,
          variant: EmptyStateActionVariant.text,
          onPressed: () {
            controller.setOwnerFilter(null);
            controller.refresh();
          },
        );
      } else {
        title = 'Todavía no hay libros para descubrir';
        message =
            'Cuando otros miembros compartan ejemplares compatibles, los verás listados aquí.';
        action = EmptyStateAction(
          label: 'Actualizar lista',
          icon: Icons.refresh,
          variant: EmptyStateActionVariant.text,
          onPressed: () => controller.refresh(),
        );
      }

      return EmptyState(
        icon: Icons.menu_book_outlined,
        title: title,
        message: message,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        action: action,
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      child: isGridView
          ? GridView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Set to 3 columns
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: filtered.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= filtered.length) {
                  if (state.error != null) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'Error',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                }

                final detail = filtered[index];
                // Use a specialized Grid Item widget or adapt existing logic
                // For simplicity, reusing a similar card structure but adapted for Grid
                return _buildGridItem(context, detail, theme, ownerNames,
                    activeLoansBySharedBookId);
              },
            )
          : BookTextList(
              books: filtered.map((d) => d.book).whereType<Book>().toList(),
              onBookTap: (book) {
                // We need to find the sharedBookId for this book in state.items
                final detail =
                    state.items.firstWhere((d) => d.book?.id == book.id);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DiscoverBookDetailPage(
                      group: widget.group,
                      sharedBookId: detail.sharedBook.id,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    SharedBookDetail detail,
    ThemeData theme,
    Map<int, String> ownerNames,
    Map<int, LoanDetail> activeLoansBySharedBookId,
  ) {
    final book = detail.book;
    final title = book?.title ?? 'Libro sin título';
    final author = (book?.author ?? '').trim();
    final activeLoan = activeLoansBySharedBookId[detail.sharedBook.id];
    final statusDisplay = _resolveStatusDisplay(
      theme: theme,
      sharedBook: detail.sharedBook,
      loanDetail: activeLoan,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DiscoverBookDetailPage(
                group: widget.group,
                sharedBookId: detail.sharedBook.id,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceContainerHighest,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background (Image or Gradient)
              if (book?.coverPath != null)
                Image.network(
                  book!.coverPath!,
                  fit: BoxFit.cover,
                  // Removed color filter on image itself, will use overlay
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primaryContainer,
                        theme.colorScheme.surfaceContainerHighest,
                      ],
                    ),
                  ),
                ),

              // Contrast Overlay (Uniform for ALL cards to ensure text readability)
              Container(
                color: Colors.black.withValues(alpha: 0.55),
              ),

              // Content Overlay (Always visible, centered/large)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (author.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        author,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Status Chip (Small, top right or bottom? User said "solo se vea nombre y autor",
              // but status is critical. Let's keep it subtle at the bottom or top)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: _DiscoverStatusChip(display: statusDisplay),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _loanStatusPriority(String status) {
    switch (status) {
      case 'active': // FIXED: accepted -> active
        return 2;
      case 'requested':
        return 1;
      default:
        return 0;
    }
  }
}

class _DiscoverStatusDisplay {
  const _DiscoverStatusDisplay({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    this.caption,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final String? caption;
}

class _DiscoverStatusChip extends StatelessWidget {
  const _DiscoverStatusChip({required this.display});

  final _DiscoverStatusDisplay display;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: display.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(display.icon, size: 10, color: display.foreground),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                display.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: display.foreground,
                  fontWeight: FontWeight.w600,
                  fontSize: 7.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverMetricsBanner extends StatelessWidget {
  const _DiscoverMetricsBanner({required this.state});

  final DiscoverGroupState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timestamp = state.lastLoadedAt;
    final duration = state.lastLoadDuration;
    final parts = <String>[
      'items=${state.items.length}',
      'page=${state.pageSize}',
      if (duration != null) 'dur=${duration.inMilliseconds}ms',
      'cache=${state.loadedFromCache ? 'hit' : 'miss'}',
      'large=${state.isLargeDataset ? 'yes' : 'no'}',
      if (timestamp != null) 'ts=${DateFormat.Hms().format(timestamp)}',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        parts.join(' · '),
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}

class _GenreDropdown extends StatelessWidget {
  const _GenreDropdown({
    required this.currentValue,
    required this.onChanged,
  });

  final String? currentValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: currentValue,
          hint: const Text('Género'),
          style: theme.textTheme.bodyMedium,
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Todos los géneros'),
            ),
            ...BookGenre.values.map((genre) {
              return DropdownMenuItem<String?>(
                value: genre.label,
                child: Text(genre.label),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _MemberSelector extends StatelessWidget {
  const _MemberSelector({
    required this.membersAsync,
    required this.selectedUserId,
    required this.onChanged,
    this.activeUserId,
  });

  final AsyncValue<List<GroupMemberDetail>> membersAsync;
  final int? selectedUserId;
  final ValueChanged<int?> onChanged;
  final int? activeUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: membersAsync.when(
        data: (members) {
          final sortedMembers = members
              .where((m) => m.membership.memberUserId != activeUserId)
              .toList()
            ..sort((a, b) =>
                (a.user?.username ?? '').compareTo(b.user?.username ?? ''));

          return DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: selectedUserId,
              hint: const Text('Miembro'),
              style: theme.textTheme.bodyMedium,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Todos los miembros'),
                ),
                ...sortedMembers.map((m) {
                  return DropdownMenuItem<int?>(
                    value: m.membership.memberUserId,
                    child: Text(m.user?.username ??
                        'Usuario ${m.membership.memberUserId}'),
                  );
                }),
              ],
              onChanged: onChanged,
            ),
          );
        },
        loading: () =>
            const SizedBox(width: 100, child: LinearProgressIndicator()),
        error: (_, __) => const Text('Error'),
      ),
    );
  }
}

class _DiscoverSearchBar extends StatelessWidget {
  const _DiscoverSearchBar({
    required this.controller,
    required this.onClear,
    required this.isLoading,
    required this.focusNode,
  });

  final TextEditingController controller;
  final VoidCallback onClear;
  final bool isLoading;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        Widget? suffix;
        if (isLoading) {
          suffix = const Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        } else if (hasText) {
          suffix = IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.clear),
          );
        }

        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Buscar por título, autor o ISBN',
            suffixIcon: suffix,
          ),
          textInputAction: TextInputAction.search,
        );
      },
    );
  }
}

class _DiscoverErrorView extends StatelessWidget {
  const _DiscoverErrorView({
    required this.message,
    required this.details,
    required this.onRetry,
  });

  final String message;
  final String details;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              details,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
