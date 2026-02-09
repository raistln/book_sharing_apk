import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/clubs_provider.dart';
import '../../dialogs/create_club_dialog.dart';
import 'club_detail_page.dart';

class ClubsListPage extends ConsumerWidget {
  const ClubsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(userClubsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreateClubDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Crear Club'),
      ),
      body: clubsAsync.when(
        data: (clubs) {
          if (clubs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aún no tienes clubes de lectura'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
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
                        builder: (context) => ClubDetailPage(club: club),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
