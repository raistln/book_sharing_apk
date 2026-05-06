import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/clubs_provider.dart';
import '../../../providers/book_providers.dart';
import '../../dialogs/create_club_dialog.dart';
import '../../widgets/community/join_by_code_dialog.dart';
import 'club_detail_page.dart';
import '../../../l10n/generated/app_localizations.dart';

class ClubsListPage extends ConsumerWidget {
  const ClubsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context);
    final clubsAsync = ref.watch(userClubsProvider);

    return clubsAsync.when(
      data: (clubs) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const CreateClubDialog(),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: Text(l10n.clubListCreateGroup),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleJoinClubByCode(context, ref),
                      icon: const Icon(Icons.qr_code_2_outlined),
                      label: Text(l10n.clubListJoinByCode),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: clubs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.menu_book, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(l10n.clubListEmpty),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: clubs.length,
                      itemBuilder: (context, index) {
                        final club = clubs[index];
                        return Card(
                          child: ListTile(
                            title: Text(club.name),
                            subtitle: Text('${club.frequency} • ${club.city}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ClubDetailPage(club: club),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Future<void> _handleJoinClubByCode(
      BuildContext context, WidgetRef ref) async {
    final l10n = S.of(context);
    final user = ref.read(activeUserProvider).value;
    if (user == null || user.remoteId == null) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => JoinByCodeDialog(
        onJoin: (code) async {
          final clubService = ref.read(clubServiceProvider);
          await clubService.joinClubByUuid(
            clubUuid: code,
            userId: user.id,
            userRemoteId: user.remoteId!,
          );
        },
        title: l10n.clubListJoinTitle,
        labelText: l10n.clubListJoinIdLabel,
        helperText: l10n.clubListJoinIdHint,
        successMessage: l10n.successJoinedGroup,
      ),
    );
  }
}
