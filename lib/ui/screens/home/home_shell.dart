import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/auth_providers.dart';
import '../../../services/notification_service.dart';
import '../../../providers/notification_providers.dart';
import '../../../providers/user_profile_provider.dart';
import '../../widgets/sync_banner.dart';
import '../../widgets/textured_background.dart';
import '../auth/pin_setup_screen.dart';
import 'tabs/reading_tab.dart';
import 'tabs/community_tab.dart';
import 'tabs/settings_tab.dart';
import 'tabs/library_tab.dart';
import 'tabs/loans_tab.dart';
import '../../widgets/notifications/notifications_sheet.dart';
import '../../widgets/library/book_form_sheet.dart';
import '../profile/user_profile_screen.dart';
import '../../../services/release_notes_service.dart';
import '../../widgets/release_notes_dialog.dart';
import '../../widgets/bulletin/bulletin_sheet.dart';
import '../../widgets/bookshelf/virtual_bookshelf_sheet.dart';
import '../../../providers/bulletin_providers.dart';
import '../../../models/bulletin.dart';

enum _BookFormResult {
  saved,
  deleted,
}

final _currentTabProvider = StateProvider<int>((ref) => 0);

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  static const routeName = '/home';

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loanRepositoryProvider).deleteOldRejectedCancelledLoans();
      _checkReleaseNotes();
    });
  }

  Future<void> _checkReleaseNotes() async {
    final service = ref.read(releaseNotesServiceProvider);
    final shouldShow = await service.shouldShowReleaseNotes();

    if (shouldShow && mounted) {
      final latestNote = service.getLatestReleaseNote();
      if (latestNote != null) {
        await ReleaseNotesDialog.show(context, latestNote);
        await service.markReleaseNotesAsSeen();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<NotificationIntent?>(notificationIntentProvider,
        (previous, next) {
      if (next == null) {
        return;
      }
      _handleNotificationIntent(context, ref, next);
    });

    final currentIndex = ref.watch(_currentTabProvider);

    return Scaffold(
      body: TexturedBackground(
        child: Column(
          children: [
            const SyncBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
              child: Row(
                children: [
                  // Izquierda: Boletín y Estantería Virtual
                  IconButton(
                    onPressed: () => _handleBulletinAction(context, ref),
                    icon: const Icon(Icons.newspaper_outlined),
                    tooltip: S.of(context).tooltipBulletin,
                  ),
                  IconButton(
                    onPressed: () => _showBookshelfSheet(context),
                    icon: const Icon(Icons.shelves),
                    tooltip: S.of(context).tooltipBookshelf,
                  ),

                  const Spacer(),

                  // Derecha: Notificaciones, Usuario, Ajustes
                  IconButton(
                    onPressed: () => _showNotificationsSheet(context, ref),
                    icon: const Icon(Icons.notifications_outlined),
                    tooltip: S.of(context).tooltipNotifications,
                  ),
                  IconButton(
                    onPressed: () => _showProfileScreen(context),
                    icon: const Icon(Icons.person_outline),
                    tooltip: S.of(context).tooltipProfile,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsTab()),
                      );
                    },
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: S.of(context).tooltipSettings,
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: [
                  const ReadingTab(),
                  LibraryTab(
                      onOpenForm: ({Book? book}) =>
                          _showBookFormSheet(context, ref, book: book)),
                  const LoansTab(),
                  const CommunityTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: S.of(context).tabReading,
          ),
          NavigationDestination(
            icon: const Icon(Icons.library_books_outlined),
            selectedIcon: const Icon(Icons.library_books),
            label: S.of(context).tabLibrary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.swap_horiz_outlined),
            selectedIcon: const Icon(Icons.swap_horiz),
            label: S.of(context).tabLoans,
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            selectedIcon: const Icon(Icons.groups),
            label: S.of(context).tabGroups,
          ),
        ],
        onDestinationSelected: (value) {
          ref.read(_currentTabProvider.notifier).state = value;
        },
      ),
      floatingActionButton: _buildFab(context, ref, currentIndex),
    );
  }

  Widget? _buildFab(BuildContext context, WidgetRef ref, int currentIndex) {
    // Library tab is now index 1
    if (currentIndex == 1) {
      return FloatingActionButton.extended(
        onPressed: () => _showBookFormSheet(context, ref),
        icon: const Icon(Icons.add),
        label: Text(S.of(context).addBook),
      );
    }

    if (kDebugMode) {
      return FloatingActionButton.extended(
        onPressed: () => _clearPin(context, ref),
        icon: const Icon(Icons.dangerous_outlined),
        label: Text(S.of(context).debugResetPin),
      );
    }

    return null;
  }

  void _handleNotificationIntent(
    BuildContext context,
    WidgetRef ref,
    NotificationIntent intent,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tabNotifier = ref.read(_currentTabProvider.notifier);

      switch (intent.type) {
        case NotificationType.loanDueSoon:
        case NotificationType.loanExpired:
          tabNotifier.state = 2;
          break;
        case NotificationType.groupInvitation:
          tabNotifier.state = 1;
          break;
      }

      ref.read(notificationIntentProvider.notifier).clear();
    });
  }

  Future<void> _showNotificationsSheet(
      BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      builder: (context) => const NotificationsSheet(),
    );
  }

  Future<void> _showBookFormSheet(BuildContext context, WidgetRef ref,
      {Book? book}) async {
    final result = await showModalBottomSheet<_BookFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => BookFormSheet(initialBook: book),
    );

    if (!context.mounted || result == null) return;

    switch (result) {
      case _BookFormResult.saved:
        _showFeedbackSnackBar(
          context: context,
          message: book == null
              ? S.of(context).snackBookAdded
              : S.of(context).snackBookUpdated,
          isError: false,
        );
        break;
      case _BookFormResult.deleted:
        _showFeedbackSnackBar(
          context: context,
          message: S.of(context).snackBookDeleted,
          isError: false,
        );
        break;
    }
  }

  Future<void> _clearPin(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).clearPin();
    if (!context.mounted) return;
    _showFeedbackSnackBar(
      context: context,
      message: S.of(context).snackPinCleared,
      isError: false,
    );
    Navigator.of(context)
        .pushNamedAndRemoveUntil(PinSetupScreen.routeName, (route) => false);
  }

  void _showFeedbackSnackBar({
    required BuildContext context,
    required String message,
    required bool isError,
  }) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isError
                ? theme.colorScheme.onError
                : theme.colorScheme.onSurface,
            fontFamily: 'Georgia', // Serif para toque literario
          ),
        ),
        backgroundColor: isError
            ? theme.colorScheme.error
            : theme
                .colorScheme.surfaceContainerHighest, // Color papel/superficie
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }

  void _showBookshelfSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VirtualBookshelfSheet(),
    );
  }

  Future<void> _showProfileScreen(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const UserProfileScreen()),
    );
  }

  Future<void> _handleBulletinAction(
      BuildContext context, WidgetRef ref) async {
    _showLoadingDialog(context);

    try {
      // 1. Wait for user profile to be loaded
      await ref.read(userProfileProvider.notifier).load();
      final userProfile = ref.read(userProfileProvider).value;

      if (!context.mounted) return;

      if (userProfile == null || userProfile.residence.isEmpty) {
        Navigator.of(context).pop(); // Close loading
        _showResidenceWarning(context);
        return;
      }

      final province = userProfile.residence;

      // 2. Fetch the bulletin
      final bulletin = await ref.read(latestBulletinProvider.future);
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading

      if (bulletin == null) {
        final now = DateTime.now();
        // Generar un boletín genérico informativo si no hay datos en Supabase
        final placeholder = Bulletin(
          id: -1,
          province: province,
          period: DateFormat('yyyy-MM').format(now),
          month: now.month,
          year: now.year,
          narrative:
              S.of(context).noBulletinPlaceholder(province),
          events: [],
          totalEvents: 0,
          generatedAt: now,
        );
        _showBulletinSheet(context, placeholder);
      } else {
        _showBulletinSheet(context, bulletin);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading
      _showFeedbackSnackBar(
        context: context,
        message: S.of(context).errorLoadingBulletin(e.toString()),
        isError: true,
      );
    }
  }

  void _showResidenceWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).residenceRequired),
        content: Text(
          S.of(context).residenceRequiredMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).notNow),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showProfileScreen(context);
            },
            child: Text(S.of(context).goToProfile),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _showBulletinSheet(BuildContext context, Bulletin bulletin) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BulletinSheet(bulletin: bulletin),
    );
  }
}
