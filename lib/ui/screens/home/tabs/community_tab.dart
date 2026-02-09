import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lending_groups_tab.dart';
import '../../clubs/clubs_list_page.dart';

class CommunityTab extends ConsumerWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Lectura Compartida'),
              Tab(text: 'Clubes de Lectura'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                LendingGroupsTab(),
                ClubsListPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
