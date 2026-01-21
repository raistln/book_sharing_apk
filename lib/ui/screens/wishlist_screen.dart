import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/book_providers.dart';
import '../widgets/profile/add_wishlist_item_sheet.dart';
import '../widgets/textured_background.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final wishlistAsync = ref.watch(wishlistItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Deseos',
            style: TextStyle(fontFamily: 'Georgia')),
      ),
      body: TexturedBackground(
        child: wishlistAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border,
                        size: 64,
                        color:
                            theme.colorScheme.secondary.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'Tu lista de deseos está vacía.',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Añade libros que quieras leer o comprar.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return Dismissible(
                  key: Key('wishlist_${item.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delete_outline,
                        color: theme.colorScheme.error),
                  ),
                  onDismissed: (_) {
                    ref.read(wishlistRepositoryProvider).removeItem(item.id);
                  },
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(Icons.favorite,
                            color: theme.colorScheme.primary, size: 20),
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.author != null) Text(item.author!),
                          if (item.notes != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.notes!,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.library_add_outlined),
                            tooltip: 'Añadir a mi biblioteca',
                            onPressed: () => _moveToLibrary(context, ref, item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Eliminar deseo',
                            onPressed: () {
                              _confirmDelete(context, ref, item);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) => Center(child: Text('Error: $e')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo deseo'),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddWishlistItemSheet(),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar deseo?'),
        content: Text('"${item.title}" se borrará de tu lista.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              ref.read(wishlistRepositoryProvider).removeItem(item.id);
              Navigator.pop(context);
            },
            child: Text('Eliminar',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _moveToLibrary(
      BuildContext context, WidgetRef ref, dynamic item) async {
    final activeUser = ref.read(activeUserProvider).value;
    if (activeUser == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Ya lo tienes?'),
        content: Text(
            '¿Seguro que quieres pasar "${item.title}" a tu biblioteca personal? Se quitará de tu lista de deseos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Aún no'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('¡Sí, ya es mío!'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repository = ref.read(bookRepositoryProvider);
      await repository.addBook(
        title: item.title,
        author: item.author,
        isbn: item.isbn,
        barcode: null,
        coverPath: null,
        description: item.notes ?? 'Añadido desde mi lista de deseos',
        status: 'private',
        isRead: false,
        owner: activeUser,
        genre: null,
        isPhysical: true,
        pageCount: null,
        publicationYear: null,
      );

      // Si se añade con éxito, lo borramos de la wishlist
      await ref.read(wishlistRepositoryProvider).removeItem(item.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${item.title}" añadido a tu biblioteca personal.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al mover a la biblioteca: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
