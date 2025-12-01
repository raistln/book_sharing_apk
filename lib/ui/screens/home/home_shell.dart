import 'dart:async';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../providers/auth_providers.dart';
import '../../../services/notification_service.dart';
import '../../../providers/notification_providers.dart';
import '../../widgets/sync_banner.dart';
import '../auth/pin_setup_screen.dart';
import 'tabs/community_tab.dart';
import 'tabs/discovery_tab.dart';
import 'tabs/settings_tab.dart';
import 'tabs/stats_tab.dart';
import 'tabs/library_tab.dart';
import '../../widgets/notifications/notification_bell.dart';
import '../../widgets/notifications/notifications_sheet.dart';
import '../../widgets/library/book_form_sheet.dart';

enum _BookFormResult {
  saved,
  deleted,
}

final _currentTabProvider = StateProvider<int>((ref) => 0);





class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<NotificationIntent?>(notificationIntentProvider, (previous, next) {
      if (next == null) {
        return;
      }
      _handleNotificationIntent(context, ref, next);
    });

    final currentIndex = ref.watch(_currentTabProvider);

    return Scaffold(
      body: Column(
        children: [
          const SyncBanner(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: NotificationBell(
                onPressed: () => _showNotificationsSheet(context, ref),
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: [
                LibraryTab(onOpenForm: ({Book? book}) => _showBookFormSheet(context, ref, book: book)),
                const CommunityTab(),
                const DiscoverTab(),
                const StatsTab(),
                const SettingsTab(),
              ],
            ),
          ),
        ],
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
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Comunidad',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Descubrir',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Estadísticas',
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

  Future<void> _showNotificationsSheet(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      builder: (context) => const NotificationsSheet(),
    );
  }

  Future<void> _showBookFormSheet(BuildContext context, WidgetRef ref, {Book? book}) async {
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
        content: Text(message),
        backgroundColor:
            isError ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
    );
  }

}
