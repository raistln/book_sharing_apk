import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseLoanService {
  final SupabaseClient _client;

  SupabaseLoanService(this._client);

  /// Fetches loans for a user (both as lender and borrower) updated after [since].
  Future<List<Map<String, dynamic>>> fetchUserLoans({
    required String userId,
    DateTime? since,
  }) async {
    var query = _client.from('loans').select();

    // Filter by user involvement
    // Use 'or' correctly with PostgREST syntax
    query = query.or('lender_user_id.eq.$userId,borrower_user_id.eq.$userId');

    if (since != null) {
      query = query.gt('updated_at', since.toIso8601String());
    }

    // Order by updated_at to ensure consistent syncing
    // Type casting is needed because select() returns specific builder types
    return await query.order('updated_at', ascending: true);
  }

  /// Upserts a list of loans to Supabase.
  /// Returns the list of upserted records (with server-generated fields if any).
  Future<List<Map<String, dynamic>>> upsertLoans(
      List<Map<String, dynamic>> loans) async {
    if (loans.isEmpty) return [];

    final response =
        await _client.from('loans').upsert(loans, onConflict: 'uuid').select();

    return List<Map<String, dynamic>>.from(response);
  }

  /// Deletes a loan by UUID.
  Future<void> deleteLoan(String uuid) async {
    await _client.from('loans').delete().eq('uuid', uuid);
  }

  /// Atomically accepts a loan using a server-side RPC.
  /// Handles validation and auto-rejection of conflicting requests.
  Future<Map<String, dynamic>> acceptLoan({
    required String loanId,
    required String lenderUserId,
  }) async {
    final response = await _client.rpc('accept_loan', params: {
      'p_loan_id': loanId,
      'p_lender_user_id': lenderUserId,
    });
    return response as Map<String, dynamic>;
  }
}
