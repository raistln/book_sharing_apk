import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/auth_providers.dart';
import '../../../services/notification_service.dart';
import '../../../providers/notification_providers.dart';
import '../../../providers/user_profile_provider.dart';
import '../../widgets/sync_banner.dart';
import '../../widgets/textured_background.dart';
import '../auth/pin_setup_screen.dart';
import 'tabs/community_tab.dart';
import 'tabs/settings_tab.dart';
import 'tabs/library_tab.dart';
import 'tabs/loans_tab.dart';
import '../../widgets/notifications/notification_bell.dart';
import '../../widgets/notifications/notifications_sheet.dart';
import '../../widgets/library/book_form_sheet.dart';
import '../../widgets/profile/user_profile_sheet.dart';
import '../../../services/release_notes_service.dart';
import '../../widgets/release_notes_dialog.dart';
import '../../widgets/bulletin/bulletin_sheet.dart';
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
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NotificationBell(
                    onPressed: () => _showNotificationsSheet(context, ref),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _handleBulletinAction(context, ref),
                    icon: const Icon(Icons.newspaper_outlined),
                    tooltip: 'Boletín Provincial',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showProfileSheet(context),
                    icon: const Icon(Icons.account_circle_outlined),
                    tooltip: 'Mi Perfil',
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: [
                  LibraryTab(
                      onOpenForm: ({Book? book}) =>
                          _showBookFormSheet(context, ref, book: book)),
                  const LoansTab(),
                  const CommunityTab(),
                  const SettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Biblioteca',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Préstamos',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Grupos',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
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
    if (currentIndex == 0) {
      return FloatingActionButton.extended(
        onPressed: () => _showBookFormSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Añadir libro'),
      );
    }

    // Loans tab (index 1) has its own FAB in LoansTab scaffold
    if (currentIndex == 1) return null;

    if (kDebugMode) {
      return FloatingActionButton.extended(
        onPressed: () => _clearPin(context, ref),
        icon: const Icon(Icons.dangerous_outlined),
        label: const Text('Debug: reset PIN'),
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
              ? 'Libro añadido a tu biblioteca.'
              : 'Libro actualizado correctamente.',
          isError: false,
        );
        break;
      case _BookFormResult.deleted:
        _showFeedbackSnackBar(
          context: context,
          message: 'Libro eliminado.',
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
      message: 'PIN borrado (solo debug).',
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

  Future<void> _showProfileSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => const UserProfileSheet(),
    );
  }

  Future<void> _handleBulletinAction(
      BuildContext context, WidgetRef ref) async {
    final userProfile = ref.read(userProfileProvider).value;
    final province = userProfile?.residence;

    if (province == null || province.isEmpty) {
      _showResidenceWarning(context);
      return;
    }

    _showLoadingDialog(context);

    try {
      final bulletin = await ref.read(latestBulletinProvider.future);
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading

      if (bulletin == null) {
        _showComingSoonBulletin(context, province);
      } else {
        _showBulletinSheet(context, bulletin);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading
      _showFeedbackSnackBar(
        context: context,
        message: 'Error al cargar el boletín: $e',
        isError: true,
      );
    }
  }

  void _showResidenceWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lugar de residencia necesario'),
        content: const Text(
          'Para recibir boletines literarios de tu zona, por favor rellena tu lugar de residencia en tu perfil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ahora no'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showProfileSheet(context);
            },
            child: const Text('Ir al Perfil'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonBulletin(BuildContext context, String province) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Boletín de $province'),
        content: const Text(
          'Estamos trabajando en la función de Boletines para tu provincia. ¡Estará disponible próximamente!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
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
