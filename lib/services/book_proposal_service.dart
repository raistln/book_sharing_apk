import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../data/local/club_dao.dart';
import '../data/local/database.dart';

/// Service for managing book proposals and voting
class BookProposalService {
  BookProposalService({
    required this.dao,
  });

  final ClubDao dao;
  final _uuid = const Uuid();

  // =====================================================================
  // PROPOSAL CREATION
  // =====================================================================

  /// Create a new book proposal
  Future<String> createProposal({
    required String clubUuid,
    required String bookUuid,
    required String proposedByUuid,
    required int totalChapters,
    int? closeDays, // Days until voting closes (default 7)
  }) async {
    final proposalUuid = _uuid.v4();

    final closeDate = DateTime.now().add(
      Duration(days: closeDays ?? 7),
    );

    final companion = BookProposalsCompanion.insert(
      uuid: proposalUuid,
      clubId: 0, // Will be set on sync
      clubUuid: clubUuid,
      bookUuid: bookUuid,
      proposedByUserId: 0, // Will be set on sync
      proposedByRemoteId: Value(proposedByUuid),
      totalChapters: totalChapters,
      votes: const Value(''), // Empty CSV initially
      voteCount: const Value(0),
      status: const Value('abierta'),
      closeDate: Value(closeDate),
      isDirty: const Value(true),
    );

    await dao.upsertProposal(companion);

    return proposalUuid;
  }

  // =====================================================================
  // VOTING
  // =====================================================================

  /// Vote for a proposal
  Future<bool> voteForProposal({
    required String proposalUuid,
    required String userUuid,
  }) async {
    final proposal = await dao.getProposalByUuid(proposalUuid);
    if (proposal == null) {
      throw Exception('Proposal not found');
    }

    // Check if proposal is still open
    if (proposal.status != 'abierta') {
      throw Exception('Proposal is no longer open for voting');
    }

    // Check if voting period has expired
    if (proposal.closeDate != null &&
        DateTime.now().isAfter(proposal.closeDate!)) {
      // Auto-close expired proposal
      await closeVoting(proposalUuid, closedByAdmin: false);
      throw Exception('Voting period has expired');
    }

    // Parse existing votes
    final existingVotes = proposal.votes.isEmpty
        ? <String>[]
        : proposal.votes.split(',').where((v) => v.isNotEmpty).toList();

    // Check if user already voted
    if (existingVotes.contains(userUuid)) {
      return false; // Already voted
    }

    // Add vote
    existingVotes.add(userUuid);
    final newVotesString = existingVotes.join(',');

    await dao.upsertProposal(BookProposalsCompanion(
      uuid: Value(proposalUuid),
      votes: Value(newVotesString),
      voteCount: Value(existingVotes.length),
      isDirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));

    return true;
  }

  /// Remove vote (if user changes their mind before closing)
  Future<bool> removeVote({
    required String proposalUuid,
    required String userUuid,
  }) async {
    final proposal = await dao.getProposalByUuid(proposalUuid);
    if (proposal == null) return false;

    // Can only remove votes from open proposals
    if (proposal.status != 'abierta') return false;

    final existingVotes = proposal.votes.isEmpty
        ? <String>[]
        : proposal.votes.split(',').where((v) => v.isNotEmpty).toList();

    if (!existingVotes.contains(userUuid)) {
      return false; // User hasn't voted
    }

    existingVotes.remove(userUuid);
    final newVotesString = existingVotes.join(',');

    await dao.upsertProposal(BookProposalsCompanion(
      uuid: Value(proposalUuid),
      votes: Value(newVotesString),
      voteCount: Value(existingVotes.length),
      isDirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));

    return true;
  }

  /// Check if a user has voted for a proposal
  Future<bool> hasUserVoted(String proposalUuid, String userUuid) async {
    final proposal = await dao.getProposalByUuid(proposalUuid);
    if (proposal == null) return false;

    final votes = proposal.votes.isEmpty
        ? <String>[]
        : proposal.votes.split(',').where((v) => v.isNotEmpty).toList();

    return votes.contains(userUuid);
  }

  // =====================================================================
  // VOTING CLOSURE
  // =====================================================================

  /// Close voting and determine winner
  Future<String?> closeVoting(
    String proposalUuid, {
    bool closedByAdmin = false,
  }) async {
    final proposal = await dao.getProposalByUuid(proposalUuid);
    if (proposal == null) {
      throw Exception('Proposal not found');
    }

    if (proposal.status != 'abierta') {
      throw Exception('Proposal is not open');
    }

    await dao.closeProposal(proposalUuid, 'cerrada');

    // Log if closed by admin
    if (closedByAdmin) {
      // This would be logged in moderation_logs
      // Requires knowing who closed it
    }

    return proposalUuid;
  }

  /// Determine winner from multiple proposals (called by owner after voting)
  Future<String?> selectWinner({
    required String clubUuid,
    required String? winnerProposalUuid, // If null, use highest votes
  }) async {
    final proposals = await dao.watchActiveProposals(clubUuid).first;

    if (proposals.isEmpty) return null;

    String? selectedUuid;

    if (winnerProposalUuid != null) {
      // Owner manually selected winner (tie-breaking)
      selectedUuid = winnerProposalUuid;
    } else {
      // Auto-select based on highest votes
      final sorted = proposals.toList()
        ..sort((a, b) => b.voteCount.compareTo(a.voteCount));

      // Check for tie
      if (sorted.length > 1 && sorted[0].voteCount == sorted[1].voteCount) {
        // Tie detected, requires manual selection
        return null;
      }

      selectedUuid = sorted.first.uuid;
    }

    // Mark winner
    await dao.closeProposal(selectedUuid, 'ganadora');

    // Mark all others as descartadas
    for (final p in proposals) {
      if (p.uuid != selectedUuid) {
        await dao.closeProposal(p.uuid, 'descartada');
      }
    }

    return selectedUuid;
  }

  /// Check if there's a tie in voting
  Future<bool> hasTie(String clubUuid) async {
    final proposals = await dao.watchActiveProposals(clubUuid).first;

    if (proposals.length < 2) return false;

    final sorted = proposals.toList()
      ..sort((a, b) => b.voteCount.compareTo(a.voteCount));

    return sorted[0].voteCount == sorted[1].voteCount &&
        sorted[0].voteCount > 0;
  }

  /// Get list of tied proposals
  Future<List<BookProposal>> getTiedProposals(String clubUuid) async {
    final proposals = await dao.watchActiveProposals(clubUuid).first;

    if (proposals.length < 2) return [];

    final sorted = proposals.toList()
      ..sort((a, b) => b.voteCount.compareTo(a.voteCount));

    final maxVotes = sorted.first.voteCount;

    if (maxVotes == 0) return []; // No votes yet

    return sorted.where((p) => p.voteCount == maxVotes).toList();
  }

  // =====================================================================
  // AUTO-CLOSE EXPIRED PROPOSALS
  // =====================================================================

  /// Close expired proposals (should be called periodically, e.g., daily)
  Future<int> closeExpiredProposals(String clubUuid) async {
    final proposals = await dao.watchActiveProposals(clubUuid).first;
    var closedCount = 0;

    for (final proposal in proposals) {
      if (proposal.closeDate != null &&
          DateTime.now().isAfter(proposal.closeDate!)) {
        await closeVoting(proposal.uuid, closedByAdmin: false);
        closedCount++;
      }
    }

    return closedCount;
  }

  // =====================================================================
  // PROPOSAL QUERIES
  // =====================================================================

  /// Stream active proposals
  Stream<List<BookProposal>> watchActiveProposals(String clubUuid) {
    return dao.watchActiveProposals(clubUuid);
  }

  /// Get proposal details
  Future<BookProposal?> getProposal(String proposalUuid) async {
    return dao.getProposalByUuid(proposalUuid);
  }
}
