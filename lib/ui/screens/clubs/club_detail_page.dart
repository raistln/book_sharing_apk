import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/club_dao.dart';
import '../../../data/local/database.dart';
import '../../../models/club_enums.dart';
import '../../../models/reading_section.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/clubs_provider.dart';
import 'package:drift/drift.dart' show Value;
import '../../dialogs/add_book_to_club_dialog.dart';
import '../../dialogs/propose_book_dialog.dart';
import '../../dialogs/update_reading_progress_dialog.dart';
import '../../widgets/library/book_details_page.dart';
import 'club_members_page.dart';
import 'club_proposals_page.dart';
import 'club_settings_page.dart';
import 'section_discussion_page.dart';

class ClubDetailPage extends ConsumerWidget {
  const ClubDetailPage({super.key, required this.club});

  final ReadingClub club;

  static const routeName = '/club-detail';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBookAsync = ref.watch(activeClubBookDetailsProvider(club.uuid));
    final queueAsync = ref.watch(clubBookQueueProvider(club.uuid));
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoSection(club: club),
                  const SizedBox(height: 16),
                  _NextMeetingSection(club: club, isOwner: isOwner),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SectionDiscussionPage(
                              clubUuid: club.uuid,
                              bookUuid: null,
                              sectionNumber: 0,
                              totalChapters: 0,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.forum),
                      label: const Text('Chat General del Club'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _CurrentBookSection(
                    activeBookAsync: activeBookAsync,
                    queueAsync: queueAsync,
                    progressAsync: progressAsync,
                    clubUuid: club.uuid,
                    nextBooksVisible: club.nextBooksVisible,
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
                    },
                  ),
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
                    },
                  ),
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
                final sections = ReadingSectionListHelper.fromJsonString(
                  details.clubBook.sections,
                );
                final sectionCount = sections.isEmpty ? 1 : sections.length;
                final currentSection = (progress?.currentSection ?? 1).clamp(
                  1,
                  sectionCount,
                );

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
            label: Text(hasActiveBook ? 'Discusión' : 'Proponer libro'),
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
      expandedHeight: 140,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          club.name,
          style: const TextStyle(
            shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
          ),
        ),
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
        if (isOwner) ...[
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Añadir libro a la cola del club',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddBookToClubDialog(clubUuid: club.uuid),
              );
            },
          ),
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
    required this.queueAsync,
    required this.progressAsync,
    required this.clubUuid,
    required this.nextBooksVisible,
  });

  final AsyncValue<ClubBookWithDetails?> activeBookAsync;
  final AsyncValue<List<ClubBookWithDetails>> queueAsync;
  final AsyncValue<ClubReadingProgressData?> progressAsync;
  final String clubUuid;
  final int nextBooksVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LEYENDO AHORA',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Theme.of(context).primaryColor,
              ),
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
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.auto_stories,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        const Text('No hay libro activo'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  AddBookToClubDialog(clubUuid: clubUuid),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Añadir libro'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final book = details.book;
            final clubBook = details.clubBook;
            final sections =
                ReadingSectionListHelper.fromJsonString(clubBook.sections);
            if (sections.isEmpty &&
                clubBook.sectionMode != SectionMode.manual.value) {
              Future.microtask(() {
                ref
                    .read(clubServiceProvider)
                    .repairBookSectionsIfMissing(clubBook.uuid);
              });
            }
            final totalSections =
                sections.isEmpty ? clubBook.totalChapters : sections.length;
            final progress = progressAsync.value;
            final currentSection = (progress?.currentSection ?? 1).clamp(
              1,
              totalSections,
            );

            ReadingSection? currentReadingSection;
            for (final section in sections) {
              if (section.numero == currentSection) {
                currentReadingSection = section;
                break;
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                                ? const Icon(
                                    Icons.book,
                                    size: 40,
                                    color: Colors.grey,
                                  )
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
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  book.author ?? 'Autor desconocido',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 16),
                                LinearProgressIndicator(
                                  value: totalSections > 0
                                      ? currentSection / totalSections
                                      : 0,
                                  backgroundColor: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        totalSections <= 1
                                            ? 'Lectura completa sin dividir en capítulos'
                                            : 'Sección $currentSection/$totalSections',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.chat_bubble_outline,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SectionDiscussionPage(
                                                  clubUuid: clubUuid,
                                                  bookUuid: book.uuid,
                                                  sectionNumber: currentSection,
                                                  totalChapters:
                                                      clubBook.totalChapters,
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
                                                totalSections: totalSections,
                                                initialSection: currentSection,
                                                initialStatus: progress != null
                                                    ? ReadingProgressStatus
                                                        .fromString(
                                                            progress.status)
                                                    : ReadingProgressStatus
                                                        .noEmpezado,
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(0, 0),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: const Text('Actualizar'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (currentReadingSection != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    totalSections <= 1
                                        ? 'La conversación del club se mantiene en un solo hilo.'
                                        : 'Capítulos ${currentReadingSection.capituloInicio}-${currentReadingSection.capituloFin}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _UpcomingBooksSection(
                  queueAsync: queueAsync,
                  nextBooksVisible: nextBooksVisible,
                ),
                if (sections.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SectionsOverview(
                    clubUuid: clubUuid,
                    bookUuid: book.uuid,
                    sections: sections,
                    totalChapters: clubBook.totalChapters,
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, s) => Text('Error: $e'),
        ),
      ],
    );
  }
}

class _UpcomingBooksSection extends StatelessWidget {
  const _UpcomingBooksSection({
    required this.queueAsync,
    required this.nextBooksVisible,
  });

  final AsyncValue<List<ClubBookWithDetails>> queueAsync;
  final int nextBooksVisible;

  @override
  Widget build(BuildContext context) {
    return queueAsync.when(
      data: (queue) {
        final upcoming = queue
            .where((item) => item.clubBook.status == ClubBookStatus.proximo.value)
            .take(nextBooksVisible)
            .toList();

        if (upcoming.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              upcoming.length == 1 ? 'LO QUE VIENE DESPUÉS' : 'PRÓXIMAS LECTURAS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 176,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: upcoming.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _QueuedBookCard(item: upcoming[index]);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _QueuedBookCard extends StatelessWidget {
  const _QueuedBookCard({required this.item});

  final ClubBookWithDetails item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 142,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BookDetailsPage(bookId: item.book.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade200,
                      image: item.book.coverPath != null
                          ? DecorationImage(
                              image: NetworkImage(item.book.coverPath!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: item.book.coverPath == null
                        ? const Icon(Icons.book_outlined, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.book.author ?? 'Autor desconocido',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionsOverview extends StatelessWidget {
  const _SectionsOverview({
    required this.clubUuid,
    required this.bookUuid,
    required this.sections,
    required this.totalChapters,
  });

  final String clubUuid;
  final String bookUuid;
  final List<ReadingSection> sections;
  final int totalChapters;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SECCIONES Y DISCUSIÓN',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Theme.of(context).primaryColor,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          sections.length == 1
              ? 'Este libro está en modo completo, sin dividir por capítulos.'
              : 'Cada sección se abre en su fecha para evitar spoilers.',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[700]),
        ),
        const SizedBox(height: 12),
        ...sections.map((section) {
          final isUnlocked = !now.isBefore(section.fechaApertura);
          final isCurrent = isUnlocked && now.isBefore(section.fechaCierre);
          final title = sections.length == 1
              ? 'Libro completo'
              : 'Sección ${section.numero}: capítulos ${section.capituloInicio}-${section.capituloFin}';

          return Card(
            elevation: 0,
            color: isUnlocked ? Colors.white : Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isCurrent
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.35)
                    : Colors.grey.shade300,
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isUnlocked
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.12)
                    : Colors.grey.shade300,
                child: Icon(
                  isUnlocked ? Icons.forum_outlined : Icons.lock_outline,
                  color: isUnlocked
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade700,
                ),
              ),
              title: Text(title),
              subtitle: Text(
                isUnlocked
                    ? 'Abierta desde ${dateFormat.format(section.fechaApertura)}'
                    : 'Se abre el ${dateFormat.format(section.fechaApertura)}',
              ),
              trailing: isUnlocked
                  ? TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SectionDiscussionPage(
                              clubUuid: clubUuid,
                              bookUuid: bookUuid,
                              sectionNumber: section.numero,
                              totalChapters: totalChapters,
                            ),
                          ),
                        );
                      },
                      child: const Text('Entrar'),
                    )
                  : const Text('Bloqueada'),
            ),
          );
        }),
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
                    final book =
                        await ref.read(bookDaoProvider).findByUuid(proposal.bookUuid);
                    if (book != null && context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BookDetailsPage(bookId: book.id),
                        ),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Detalles no disponibles para este libro propuesto',
                          ),
                        ),
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
                              top: Radius.circular(11),
                            ),
                            image: proposal.coverUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(proposal.coverUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: proposal.coverUrl == null
                              ? const Center(
                                  child: Icon(
                                    Icons.book_outlined,
                                    color: Colors.grey,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                proposal.title ?? 'Sin título',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.how_to_vote,
                                    size: 12,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${proposal.voteCount}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
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
        final displayMembers = members.take(5).toList();
        return SizedBox(
          height: 65,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...displayMembers.map((memberWithUser) {
                  final member = memberWithUser.member;
                  final user = memberWithUser.user;
                  final initials = user.username.isNotEmpty
                      ? user.username.substring(0, 1).toUpperCase()
                      : '?';

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
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
                          ClubMemberRole.fromString(member.role).isOwner
                              ? 'Admin'
                              : 'Miem.',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }),
                if (members.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        '+${members.length - 5}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Text('Error: $e'),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
  });

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

class _NextMeetingSection extends ConsumerWidget {
  const _NextMeetingSection({required this.club, required this.isOwner});

  final ReadingClub club;
  final bool isOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final date = club.nextMeetingDate;
    final place = club.nextMeetingPlace;

    if (date == null && place == null && !isOwner) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withValues(alpha: 0.05),
              theme.primaryColor.withValues(alpha: 0.01),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.event, color: theme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'PRÓXIMA REUNIÓN',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                if (isOwner)
                  IconButton(
                    icon: const Icon(Icons.edit_calendar_outlined, size: 20),
                    onPressed: () => _showEditMeetingDialog(context, ref),
                    tooltip: 'Editar reunión',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (date != null) ...[
              Row(
                children: [
                  const Icon(Icons.access_time_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE, d \'de\' MMMM \'a las\' HH:mm', 'es').format(date),
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (place != null && place.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      place,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ] else if (date != null) ...[
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Lugar no especificado',
                    style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ],
              ),
            ],
            if (date == null && place == null && isOwner) ...[
              Text(
                'No hay reunión programada. Haz clic en el lápiz para agendar la próxima reunión.',
                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey[600]),
              ),
            ],
            if (isOwner && (date != null || place != null)) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _clearMeeting(context, ref),
                  icon: const Icon(Icons.clear, size: 16, color: Colors.red),
                  label: const Text('Cancelar reunión', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditMeetingDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _EditMeetingDialog(club: club),
    );
  }

  void _clearMeeting(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reunión'),
        content: const Text('¿Estás seguro de que deseas cancelar y borrar la próxima reunión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(clubServiceProvider).clearNextMeeting(club.uuid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reunión cancelada')),
        );
      }
    }
  }
}

class _EditMeetingDialog extends ConsumerStatefulWidget {
  const _EditMeetingDialog({required this.club});

  final ReadingClub club;

  @override
  ConsumerState<_EditMeetingDialog> createState() => _EditMeetingDialogState();
}

class _EditMeetingDialogState extends ConsumerState<_EditMeetingDialog> {
  late DateTime? _selectedDate;
  late TimeOfDay? _selectedTime;
  final _placeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.club.nextMeetingDate;
    _selectedTime = widget.club.nextMeetingDate != null
        ? TimeOfDay.fromDateTime(widget.club.nextMeetingDate!)
        : null;
    _placeController.text = widget.club.nextMeetingPlace ?? '';
  }

  @override
  void dispose() {
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
      if (_selectedTime == null) {
        _selectTime();
      }
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _save() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una fecha')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final time = _selectedTime ?? const TimeOfDay(hour: 18, minute: 0);
      final finalDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        time.hour,
        time.minute,
      );

      final clubService = ref.read(clubServiceProvider);
      await clubService.updateClubSettings(
        clubUuid: widget.club.uuid,
        nextMeetingDate: Value(finalDateTime),
        nextMeetingPlace: Value(_placeController.text.trim()),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reunión agendada con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Programar Reunión'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(_selectedDate == null
                  ? 'Seleccionar Fecha'
                  : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: _selectDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: Text(_selectedTime == null
                  ? 'Seleccionar Hora'
                  : _selectedTime!.format(context)),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: _selectTime,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _placeController,
              decoration: const InputDecoration(
                labelText: 'Lugar / Enlace (Zoom, Meet...)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}

