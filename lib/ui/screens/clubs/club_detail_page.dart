import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../data/local/club_dao.dart';
import '../../../models/club_enums.dart';
import '../../../providers/clubs_provider.dart';
import '../../../providers/book_providers.dart';
import '../../dialogs/add_book_to_club_dialog.dart';
import 'section_discussion_page.dart';
import 'club_settings_page.dart';
import 'club_proposals_page.dart';
import 'club_members_page.dart';
import '../../dialogs/propose_book_dialog.dart';
import '../../dialogs/update_reading_progress_dialog.dart';
import '../../widgets/library/book_details_page.dart';

class ClubDetailPage extends ConsumerWidget {
  const ClubDetailPage({super.key, required this.club});

  final ReadingClub club;

  static const routeName = '/club-detail';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watchers
    final activeBookAsync = ref.watch(activeClubBookDetailsProvider(club.uuid));
    final membersAsync = ref.watch(clubMembersProvider(club.uuid));
    final proposalsAsync = ref.watch(clubProposalsProvider(club.uuid));
    final progressAsync = ref.watch(activeBookUserProgressProvider(club.uuid));

    final userAsync = ref.watch(activeUserProvider);
    final user = userAsync.value;
    final isOwner = user != null &&
        (user.id == club.ownerUserId ||
            (user.remoteId != null && user.remoteId == club.ownerRemoteId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isOwner),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoSection(club: club),
                  const SizedBox(height: 24),
                  _CurrentBookSection(
                    activeBookAsync: activeBookAsync,
                    progressAsync: progressAsync,
                    clubUuid: club.uuid,
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                      title: 'Propuestas',
                      action: 'Ver todas',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ClubProposalsPage(clubUuid: club.uuid),
                          ),
                        );
                      }),
                  _ProposalsSection(proposalsAsync: proposalsAsync),
                  const SizedBox(height: 24),
                  _SectionHeader(
                      title: 'Miembros',
                      action: 'Gestionar',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ClubMembersPage(club: club),
                          ),
                        );
                      }),
                  _MembersSection(membersAsync: membersAsync),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: activeBookAsync.when(
        data: (details) {
          final hasActiveBook = details != null;
          return FloatingActionButton.extended(
            onPressed: () {
              if (hasActiveBook) {
                final progress = progressAsync.value;
                final currentSection = progress?.currentSection ?? 1;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SectionDiscussionPage(
                      clubUuid: club.uuid,
                      bookUuid: details.book.uuid,
                      sectionNumber: currentSection,
                      totalChapters: details.clubBook.totalChapters,
                    ),
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) => ProposeBookDialog(clubUuid: club.uuid),
                );
              }
            },
            label: Text(hasActiveBook ? 'Discusión' : 'Proponer Libro'),
            icon: Icon(hasActiveBook ? Icons.chat_bubble_outline : Icons.add),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isOwner) {
    return SliverAppBar(
      expandedHeight: 140.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(club.name,
            style: const TextStyle(
                shadows: [Shadow(color: Colors.black45, blurRadius: 2)])),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColorDark,
              ],
            ),
          ),
          child: const Center(
            child: Icon(Icons.menu_book, size: 60, color: Colors.white24),
          ),
        ),
      ),
      actions: [
        if (isOwner)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ClubSettingsPage(club: club),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.club});

  final ReadingClub club;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          club.description,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(club.city),
            const SizedBox(width: 16),
            const Icon(Icons.repeat, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(club.frequency.toUpperCase()),
          ],
        ),
      ],
    );
  }
}

class _CurrentBookSection extends ConsumerWidget {
  const _CurrentBookSection({
    required this.activeBookAsync,
    required this.progressAsync,
    required this.clubUuid,
  });

  final AsyncValue<ClubBookWithDetails?> activeBookAsync;
  final AsyncValue<ClubReadingProgressData?> progressAsync;
  final String clubUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LEYENDO AHORA',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        activeBookAsync.when(
          data: (details) {
            if (details == null) {
              return Card(
                elevation: 0,
                color: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.auto_stories,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text('No hay libro activo'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddBookToClubDialog(
                                  clubUuid: activeBookAsync
                                          .whenData((v) => v?.clubBook.clubUuid)
                                          .value ??
                                      clubUuid),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Añadir Libro'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final book = details.book;
            final clubBook = details.clubBook;
            final totalChapters = clubBook.totalChapters;
            final progress = progressAsync.value;
            final currentSection = progress?.currentSection ?? 1;

            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BookDetailsPage(bookId: book.id),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                          image: book.coverPath != null
                              ? DecorationImage(
                                  image: NetworkImage(book.coverPath!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: book.coverPath == null
                            ? const Icon(Icons.book,
                                size: 40, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.author ?? 'Autor desconocido',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: totalChapters > 0
                                  ? currentSection / totalChapters
                                  : 0,
                              backgroundColor: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sección $currentSection/$totalChapters',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.chat_bubble_outline,
                                          size: 20),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SectionDiscussionPage(
                                              clubUuid: clubUuid,
                                              bookUuid: book.uuid,
                                              sectionNumber: currentSection,
                                              totalChapters: totalChapters,
                                            ),
                                          ),
                                        );
                                      },
                                      tooltip: 'Discusión',
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              UpdateReadingProgressDialog(
                                            clubUuid: clubUuid,
                                            bookUuid: book.uuid,
                                            totalSections: totalChapters,
                                            initialSection: currentSection,
                                            initialStatus: progress != null
                                                ? ReadingProgressStatus
                                                    .fromString(progress.status)
                                                : ReadingProgressStatus
                                                    .noEmpezado,
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text('Actualizar'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator())),
          error: (e, s) => Text('Error: $e'),
        ),
      ],
    );
  }
}

class _ProposalsSection extends ConsumerWidget {
  const _ProposalsSection({required this.proposalsAsync});

  final AsyncValue<List<BookProposal>> proposalsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 160,
      child: proposalsAsync.when(
        data: (proposals) {
          if (proposals.isEmpty) {
            return Center(
              child: Text(
                'No hay propuestas activas',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
            );
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: proposals.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final proposal = proposals[index];
              return Container(
                width: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () async {
                    // Try to find local book ID by UUID
                    final book = await ref
                        .read(bookDaoProvider)
                        .findByUuid(proposal.bookUuid);
                    if (book != null && context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              BookDetailsPage(bookId: book.id),
                        ),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Detalles no disponibles para este libro propuesto')),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(11)),
                            image: proposal.coverUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(proposal.coverUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: proposal.coverUrl == null
                              ? const Center(
                                  child: Icon(Icons.book_outlined,
                                      color: Colors.grey))
                              : null,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                proposal.title ?? 'Sin título',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.how_to_vote,
                                      size: 12, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${proposal.voteCount}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => const SizedBox(),
      ),
    );
  }
}

class _MembersSection extends StatelessWidget {
  const _MembersSection({required this.membersAsync});

  final AsyncValue<List<ClubMemberWithUser>> membersAsync;

  @override
  Widget build(BuildContext context) {
    return membersAsync.when(
      data: (members) {
        // Limit to 5 members for display
        final displayMembers = members.take(5).toList();
        return Row(
          children: [
            ...displayMembers.map((memberWithUser) {
              final member = memberWithUser.member;
              final user = memberWithUser.user;
              final initials = user.username.isNotEmpty
                  ? user.username.substring(0, 1).toUpperCase()
                  : '?';

              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: Text(
                        initials,
                        style: TextStyle(color: Colors.indigo.shade800),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.role == 'dueño' ? 'Admin' : 'Miem.',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }),
            if (members.length > 5)
              CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: Text('+${members.length - 5}',
                    style: const TextStyle(color: Colors.black54)),
              ),
          ],
        );
      },
      loading: () => const SizedBox(
          height: 50, child: Center(child: CircularProgressIndicator())),
      error: (e, s) => Text('Error: $e'),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(
      {required this.title, required this.action, required this.onTap});

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(action),
        ),
      ],
    );
  }
}
