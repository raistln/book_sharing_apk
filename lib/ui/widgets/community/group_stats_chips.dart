import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/group_dao.dart';
import '../../../providers/book_providers.dart';

class GroupStatsChips extends ConsumerWidget {
  const GroupStatsChips({
    super.key,
    required this.groupId,
    required this.membersAsync,
    required this.sharedBooksAsync,
    required this.loansAsync,
    required this.invitationsAsync,
  });

  final int groupId;
  final AsyncValue<List<dynamic>> membersAsync;
  final AsyncValue<List<dynamic>> sharedBooksAsync;
  final AsyncValue<List<dynamic>> loansAsync;
  final AsyncValue<List<dynamic>> invitationsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeUser = ref.watch(activeUserProvider).value;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        AsyncCountChip(
          icon: Icons.people_outline,
          label: 'Miembros',
          value: membersAsync,
        ),
        AsyncCountChip(
          icon: Icons.menu_book_outlined,
          label: 'Libros compartidos',
          value: sharedBooksAsync,
        ),
        // User's contributed books
        if (activeUser != null)
          sharedBooksAsync.when(
            data: (books) {
              final myBooks = (books as List<SharedBookDetail>)
                  .where((detail) =>
                      detail.sharedBook.ownerUserId == activeUser.id)
                  .length;
              return Chip(
                avatar: const Icon(Icons.person_outline, size: 18),
                label: Text('Mis libros: $myBooks'),
              );
            },
            loading: () => const Chip(
              avatar: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              label: Text('Cargando...'),
            ),
            error: (error, _) => const Chip(
              avatar: Icon(Icons.error_outline, size: 18),
              label: Text('Error'),
            ),
          ),
        // Available books (exclude those with active loans)
        loansAsync.when(
          data: (loans) {
            final activeLoans = (loans as List<LoanDetail>)
                .where((detail) =>
                    detail.loan.status == 'requested' ||
                    detail.loan.status == 'active')
                .toList();

            // Get IDs of books with active loans
            final loanedBookIds = activeLoans
                .map((detail) => detail.sharedBook?.id)
                .where((id) => id != null)
                .cast<int>()
                .toSet();

            return sharedBooksAsync.when(
              data: (books) {
                final sharedBooks = books as List<SharedBookDetail>;

                // Count available books (exclude those with active loans)
                final available = sharedBooks
                    .where((detail) =>
                        detail.sharedBook.isAvailable &&
                        !loanedBookIds.contains(detail.sharedBook.id))
                    .length;

                return Chip(
                  avatar: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text('Disponibles: $available'),
                );
              },
              loading: () => const Chip(
                avatar: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                label: Text('Cargando...'),
              ),
              error: (error, _) => const Chip(
                avatar: Icon(Icons.error_outline, size: 18),
                label: Text('Error'),
              ),
            );
          },
          loading: () => const Chip(
            avatar: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            label: Text('Cargando...'),
          ),
          error: (error, _) => const Chip(
            avatar: Icon(Icons.error_outline, size: 18),
            label: Text('Error'),
          ),
        ),
        // Active loans
        loansAsync.when(
          data: (loans) {
            final active = (loans as List<LoanDetail>)
                .where((detail) =>
                    detail.loan.status == 'requested' ||
                    detail.loan.status == 'active')
                .length;

            return Chip(
              avatar: const Icon(Icons.swap_horiz_outlined, size: 18),
              label: Text('Préstamos activos: $active'),
            );
          },
          loading: () => const Chip(
            avatar: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            label: Text('Cargando...'),
          ),
          error: (error, _) => const Chip(
            avatar: Icon(Icons.error_outline, size: 18),
            label: Text('Error'),
          ),
        ),
      ],
    );
  }
}

class AsyncCountChip<T> extends StatelessWidget {
  const AsyncCountChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final AsyncValue<List<T>> value;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (items) => Chip(
        avatar: Icon(icon, size: 18),
        label: Text('$label: ${items.length}'),
      ),
      loading: () => const Chip(
        avatar: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: Text('Cargando...'),
      ),
      error: (error, _) => Chip(
        avatar: const Icon(Icons.error_outline, size: 18),
        label: Text('Error $label'),
      ),
    );
  }
}
