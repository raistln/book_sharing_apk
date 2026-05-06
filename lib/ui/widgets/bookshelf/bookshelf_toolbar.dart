import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/bookshelf_models.dart';
import '../../../providers/bookshelf_providers.dart';
import 'bookshelf_editor_sheet.dart';
import '../../../l10n/generated/app_localizations.dart';

class BookshelfToolbar extends ConsumerWidget {
  final ShelfThemeConfig themeConfig;

  const BookshelfToolbar({
    super.key,
    required this.themeConfig,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(bookshelfSortProvider);
    final searchVisible = ref.watch(bookshelfSearchVisibleProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Search toggle
              IconButton(
                onPressed: () => ref
                    .read(bookshelfSearchVisibleProvider.notifier)
                    .update((s) => !s),
                icon: Icon(
                  searchVisible ? Icons.search_off : Icons.search,
                  color: themeConfig.textColor,
                ),
                tooltip: S.of(context).bookshelfSearchTooltip,
              ),

              // Sort chips (scrollable)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: BookShelfSortOrder.values.map((sort) {
                      final isSelected = currentSort == sort;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(
                            sort.localizedLabel(context),
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white
                                  : themeConfig.textColor,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              ref.read(bookshelfSortProvider.notifier).state =
                                  sort;
                              saveBookshelfSort(sort);
                            }
                          },
                          selectedColor: themeConfig.accentColor,
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: isSelected
                                ? themeConfig.accentColor
                                : themeConfig.textColor.withValues(alpha: 0.2),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Theme selector button
              IconButton(
                onPressed: () => _showThemeSelector(context, ref),
                icon:
                    Icon(Icons.palette_outlined, color: themeConfig.textColor),
                tooltip: S.of(context).bookshelfThemeTooltip,
              ),

              // Manual Edit button
              IconButton(
                onPressed: () => _showBookshelfEditor(context),
                icon: Icon(Icons.edit_note, color: themeConfig.textColor),
                tooltip: S.of(context).bookshelfManageTooltip,
              ),
            ],
          ),
        ),
        if (searchVisible)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: TextField(
              onChanged: (value) =>
                  ref.read(bookshelfFilterProvider.notifier).update(
                        (f) => f.copyWith(searchQuery: value),
                      ),
              style: TextStyle(color: themeConfig.textColor),
              decoration: InputDecoration(
                hintText: S.of(context).bookshelfSearchHint,
                hintStyle: TextStyle(
                    color: themeConfig.textColor.withValues(alpha: 0.4)),
                isDense: true,
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: themeConfig.textColor.withValues(alpha: 0.4)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: themeConfig.accentColor),
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showBookshelfEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BookshelfEditorSheet(),
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        final currentTheme = ref.watch(bookshelfThemeProvider);
        final currentWall = ref.watch(bookshelfWallProvider);

        final theme = Theme.of(context);
        return DefaultTabController(
          length: 2,
          child: AlertDialog(
            title: Text(S.of(context).bookshelfCustomTitle),
            contentPadding: EdgeInsets.zero,
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: S.of(context).bookshelfTabShelves),
                      Tab(text: S.of(context).bookshelfTabWall),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Shelf Material Section
                        ListView(
                          children: ShelfTheme.values.map((theme) {
                            final config = ShelfThemeConfig.forTheme(theme);
                            final isSelected = currentTheme == theme;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: config.shelfColor,
                                radius: 12,
                              ),
                              title: Text(theme.localizedDisplayName(context)),
                              trailing: isSelected
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : null,
                              onTap: () {
                                ref
                                    .read(bookshelfThemeProvider.notifier)
                                    .state = theme;
                                saveBookshelfTheme(theme);
                              },
                            );
                          }).toList(),
                        ),

                        // Wall Background Section
                        ListView(
                          children: WallTheme.values.map((wall) {
                            final config = WallThemeConfig.forTheme(wall);
                            final isSelected = currentWall == wall;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: config.color,
                                radius: 12,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withValues(
                                        alpha: config.textureOpacity * 2),
                                  ),
                                ),
                              ),
                              title: Text(wall.localizedDisplayName(context)),
                              trailing: isSelected
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : null,
                              onTap: () {
                                ref.read(bookshelfWallProvider.notifier).state =
                                    wall;
                                saveBookshelfWall(wall);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).cancel),
              ),
            ],
          ),
        );
      },
    );
  }
}
