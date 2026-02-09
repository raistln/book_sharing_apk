import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/clubs_provider.dart';

class ClubProposalsPage extends ConsumerWidget {
  const ClubProposalsPage({super.key, required this.clubUuid});

  final String clubUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalsAsync = ref.watch(clubProposalsProvider(clubUuid));
    final activeUser = ref.watch(activeUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Propuestas de Lectura'),
      ),
      body: proposalsAsync.when(
        data: (proposals) {
          if (proposals.isEmpty) {
            return const Center(
              child: Text(
                'No hay propuestas activas',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: proposals.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final proposal = proposals[index];
              return _ProposalCard(
                proposal: proposal,
                userUuid: activeUser?.remoteId,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigation to ProposeBookDialog should be handled here if needed,
          // or maybe just keep it in the main page.
          // For now, let's allow proposing from here too.
          // We need to import ProposeBookDialog.
          // But usually better to keep logic in one place.
        },
        label: const Text('Proponer'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _ProposalCard extends ConsumerStatefulWidget {
  const _ProposalCard({
    required this.proposal,
    required this.userUuid,
  });

  final BookProposal proposal;
  final String? userUuid;

  @override
  ConsumerState<_ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends ConsumerState<_ProposalCard> {
  bool _isVoting = false;

  Future<void> _toggleVote() async {
    if (widget.userUuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para votar')),
      );
      return;
    }

    setState(() => _isVoting = true);
    try {
      final service = ref.read(bookProposalServiceProvider);
      final hasVoted =
          await service.hasUserVoted(widget.proposal.uuid, widget.userUuid!);

      if (hasVoted) {
        await service.removeVote(
            proposalUuid: widget.proposal.uuid, userUuid: widget.userUuid!);
      } else {
        await service.voteForProposal(
            proposalUuid: widget.proposal.uuid, userUuid: widget.userUuid!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isVoting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasVoted = widget.userUuid != null &&
        widget.proposal.votes.split(',').contains(widget.userUuid);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 70,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
                image: widget.proposal.coverUrl != null
                    ? DecorationImage(
                        image: NetworkImage(widget.proposal.coverUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.proposal.coverUrl == null
                  ? const Center(
                      child: Icon(Icons.book_outlined,
                          color: Colors.grey, size: 30))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.proposal.title ?? 'Sin título',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.proposal.author ?? 'Autor desconocido',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.format_list_numbered,
                          size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.proposal.totalChapters} caps',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: _isVoting ? null : _toggleVote,
                  icon: Icon(
                    hasVoted ? Icons.favorite : Icons.favorite_border,
                    color: hasVoted ? Colors.red : Colors.grey,
                  ),
                ),
                Text(
                  '${widget.proposal.voteCount}',
                  style: TextStyle(
                    color: hasVoted ? Colors.red : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
