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
import '../home_shell.dart' show DiscoverBookDetailPage;

/// Helper function to filter shared books for discovery
List<SharedBookDetail> _filterSharedBooksForDiscover({
  required List<SharedBookDetail> details,
  required LocalUser? activeUser,
  required List<Book> ownBooks,
  required bool includeUnavailable,
  required int? ownerUserIdFilter,
}) {
  final ownIsbnSet = <String>{};
  for (final book in ownBooks) {
    final isbn = book.isbn?.trim();
    if (isbn != null && isbn.isNotEmpty) {
      ownIsbnSet.add(isbn);
    }
  }

  return details.where((detail) {
    final sharedBook = detail.sharedBook;
    if (sharedBook.ownerUserId == activeUser?.id) {
      return false;
    }

    if (ownerUserIdFilter != null && sharedBook.ownerUserId != ownerUserIdFilter) {
      return false;
    }

    if (!includeUnavailable && !sharedBook.isAvailable) {
      return false;
    }

    final isbn = detail.book?.isbn?.trim();
    if (isbn != null && isbn.isNotEmpty && ownIsbnSet.contains(isbn)) {
      return false;
    }

    return true;
  }).toList();
}

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
    if (status == 'pending') {
      return _DiscoverStatusDisplay(
        label: 'Pendiente',
        icon: Icons.schedule_outlined,
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
        caption: 'Solicitud pendiente de aprobación',
      );
    } else if (status == 'accepted') {
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
  late ProviderSubscription<AsyncValue<OnboardingProgress>> _discoverProgressSub;
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
    final currentState = ref.read(discoverGroupControllerProvider(widget.group.id));
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
    if (!_pendingDiscoverCoach || _discoverCoachTriggered || !_discoverTargetsReady) {
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
    final showLargeDatasetNotice = state.isLargeDataset && state.searchQuery.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DiscoverSearchBar(
                controller: _searchController,
                onClear: () {
                  _searchController.clear();
                  controller.updateSearch('');
                },
                isLoading: state.isLoadingInitial,
                focusNode: _searchFocusNode,
              ),
              const SizedBox(height: 12),
              CoachMarkTarget(
                id: CoachMarkId.discoverFilterChips,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Incluir no disponibles'),
                      selected: state.includeUnavailable,
                      onSelected: (value) {
                        controller.setIncludeUnavailable(value);
                      },
                    ),
                    ..._buildOwnerFilterChips(
                      membersAsync: membersAsync,
                      state: state,
                      controller: controller,
                      activeUser: activeUser,
                    ),
                  ],
                ),
              ),
              if (kDebugMode) ...[ 
                const SizedBox(height: 12),
                _DiscoverMetricsBanner(state: state),
              ],
              if (showLargeDatasetNotice) ...[
                const SizedBox(height: 12),
                DiscoverLargeDatasetBanner(
                  onSearchTap: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                    _searchFocusNode.requestFocus();
                  },
                  canIncludeUnavailable: !state.includeUnavailable,
                  onIncludeUnavailable: state.includeUnavailable
                      ? null
                      : () => controller.setIncludeUnavailable(true),
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: ownBooksAsync.when(
                  data: (ownBooks) => _buildResultsList(
                    theme: theme,
                    state: state,
                    controller: controller,
                    ownBooks: ownBooks,
                    activeUser: activeUser,
                    members: membersAsync.asData?.value ?? const <GroupMemberDetail>[],
                    loanDetails: loansAsync.asData?.value ?? const <LoanDetail>[],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => _DiscoverErrorView(
                    message: 'No pudimos cargar tu biblioteca.',
                    details: '$error',
                    onRetry: () => controller.refresh(),
                  ),
                ),
              ),
            ],
          ),
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

    final filtered = _filterSharedBooksForDiscover(
      details: state.items,
      activeUser: activeUser,
      ownBooks: ownBooks,
      includeUnavailable: state.includeUnavailable,
      ownerUserIdFilter: state.ownerUserIdFilter,
    );

    if (filtered.isNotEmpty && !_discoverTargetsReady) {
      _discoverTargetsReady = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeTriggerDiscoverCoach());
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
      if (status != 'pending' && status != 'accepted') {
        continue;
      }
      final entry = activeLoansBySharedBookId[shared.id];
      if (entry == null || _loanStatusPriority(status) > _loanStatusPriority(entry.loan.status)) {
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
        message = 'Revisa el término ingresado o restablece los filtros para ver más libros.';
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
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filtered.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= filtered.length) {
            if (state.error != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      'Error al cargar más resultados.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    TextButton(
                      onPressed: () => controller.loadMore(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final detail = filtered[index];
          final book = detail.book;
          final title = book?.title ?? 'Libro sin título';
          final author = (book?.author ?? '').trim();
          final ownerName = ownerNames[detail.sharedBook.ownerUserId] ??
              _resolveOwnerName(null, detail.sharedBook.ownerUserId);
          final activeLoan = activeLoansBySharedBookId[detail.sharedBook.id];
          final statusDisplay = _resolveStatusDisplay(
            theme: theme,
            sharedBook: detail.sharedBook,
            loanDetail: activeLoan,
          );

          final card = Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _DiscoverStatusChip(display: statusDisplay),
                      ],
                    ),
                    if (author.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.person_outline, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              author,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.group_outlined, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Propietario: $ownerName',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    if (statusDisplay.caption != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        statusDisplay.caption!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );

          if (index == 0) {
            return CoachMarkTarget(
              id: CoachMarkId.discoverShareBook,
              child: card,
            );
          }

          return card;
        },
      ),
    );
  }

  List<Widget> _buildOwnerFilterChips({
    required AsyncValue<List<GroupMemberDetail>> membersAsync,
    required DiscoverGroupState state,
    required DiscoverGroupController controller,
    required LocalUser? activeUser,
  }) {
    return membersAsync.when(
      data: (members) {
        if (members.isEmpty) {
          return const <Widget>[];
        }

        final chips = <Widget>[
          FilterChip(
            label: const Text('Todos los dueños'),
            selected: state.ownerUserIdFilter == null,
            onSelected: (_) => controller.setOwnerFilter(null),
          ),
        ];

        final seen = <int>{};
        final sortedMembers = members.toList()
          ..sort((a, b) {
            final nameA = a.user?.username ?? 'Miembro ${a.membership.memberUserId}';
            final nameB = b.user?.username ?? 'Miembro ${b.membership.memberUserId}';
            return nameA.toLowerCase().compareTo(nameB.toLowerCase());
          });

        for (final detail in sortedMembers) {
          final membership = detail.membership;
          final user = detail.user;
          final userId = membership.memberUserId;
          if (activeUser?.id == userId) {
            continue;
          }
          if (!seen.add(userId)) {
            continue;
          }

          final displayName = (user?.username ?? 'Miembro ${membership.memberUserId}').trim();
          chips.add(
            FilterChip(
              label: Text(
                displayName.isEmpty ? 'Miembro ${membership.memberUserId}' : displayName,
              ),
              selected: state.ownerUserIdFilter == userId,
              onSelected: (selected) => controller.setOwnerFilter(selected ? userId : null),
            ),
          );
        }

        if (chips.length <= 1) {
          return const <Widget>[];
        }

        return chips;
      },
      loading: () => const <Widget>[
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ],
      error: (error, _) => <Widget>[
        Tooltip(
          message: 'Error al cargar dueños: $error',
          child: const Icon(Icons.error_outline, size: 20),
        ),
      ],
    );
  }

  int _loanStatusPriority(String status) {
    switch (status) {
      case 'accepted':
        return 2;
      case 'pending':
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: display.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(display.icon, size: 16, color: display.foreground),
            const SizedBox(width: 6),
            Text(
              display.label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: display.foreground, fontWeight: FontWeight.w600),
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

class DiscoverLargeDatasetBanner extends StatelessWidget {
  const DiscoverLargeDatasetBanner({
    super.key,
    required this.onSearchTap,
    required this.canIncludeUnavailable,
    this.onIncludeUnavailable,
  });

  final VoidCallback onSearchTap;
  final bool canIncludeUnavailable;
  final VoidCallback? onIncludeUnavailable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.tune, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Este grupo tiene muchos libros compartidos. Usa la búsqueda o ajusta los filtros para encontrar más rápido.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: onSearchTap,
                icon: const Icon(Icons.search),
                label: const Text('Buscar o filtrar'),
              ),
              if (canIncludeUnavailable && onIncludeUnavailable != null)
                OutlinedButton.icon(
                  onPressed: onIncludeUnavailable,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Ver no disponibles'),
                ),
            ],
          ),
        ],
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
