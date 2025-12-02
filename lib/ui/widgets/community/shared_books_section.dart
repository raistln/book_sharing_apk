import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/local/group_dao.dart';

class SharedBooksSection extends StatelessWidget {
  const SharedBooksSection({super.key, required this.sharedBooksAsync});

  final AsyncValue<List<SharedBookDetail>> sharedBooksAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return sharedBooksAsync.when(
      data: (books) {
        if (books.isEmpty) {
          return Text('No hay libros compartidos todavía.',
              style: theme.textTheme.bodyMedium);
        }
        
        final totalBooks = books.length;
        final availableBooks = books.where((b) => b.sharedBook.isAvailable == true).length;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estadísticas de libros', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.menu_book_outlined,
                    label: 'Total',
                    value: '$totalBooks',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.check_circle_outline,
                    label: 'Disponibles',
                    value: '$availableBooks',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
      error: (error, _) => Text('Error cargando libros compartidos: $error',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
