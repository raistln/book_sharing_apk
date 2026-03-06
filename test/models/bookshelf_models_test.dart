import 'package:book_sharing_app/models/bookshelf_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookShelfSortOrder', () {
    test('has correct labels and icons', () {
      expect(BookShelfSortOrder.recent.label, 'Recientes');
      expect(BookShelfSortOrder.recent.icon, Icons.schedule);

      expect(BookShelfSortOrder.alphabetical.label, 'A → Z');
      expect(BookShelfSortOrder.alphabetical.icon, Icons.sort_by_alpha);

      expect(BookShelfSortOrder.author.label, 'Autor');
      expect(BookShelfSortOrder.author.icon, Icons.person_outline);

      expect(BookShelfSortOrder.pageCount.label, 'Páginas');
      expect(BookShelfSortOrder.pageCount.icon, Icons.format_list_numbered);

      expect(BookShelfSortOrder.rating.label, 'Valoración');
      expect(BookShelfSortOrder.rating.icon, Icons.star_outline);
    });
  });

  group('ShelfThemeConfig', () {
    test('forTheme returns correct config for each theme', () {
      expect(ShelfThemeConfig.forTheme(ShelfTheme.classicWood).displayName, 'Clásica');
      expect(ShelfThemeConfig.forTheme(ShelfTheme.modernWhite).displayName, 'Moderna');
      expect(ShelfThemeConfig.forTheme(ShelfTheme.vintageBrown).displayName, 'Vintage');
      expect(ShelfThemeConfig.forTheme(ShelfTheme.industrial).displayName, 'Industrial');
      expect(ShelfThemeConfig.forTheme(ShelfTheme.cozyPastel).displayName, 'Pastel');
    });

    test('themes map contains all themes', () {
      expect(ShelfThemeConfig.themes.length, 5);
      expect(ShelfThemeConfig.themes.containsKey(ShelfTheme.classicWood), true);
      expect(ShelfThemeConfig.themes.containsKey(ShelfTheme.modernWhite), true);
      expect(ShelfThemeConfig.themes.containsKey(ShelfTheme.vintageBrown), true);
      expect(ShelfThemeConfig.themes.containsKey(ShelfTheme.industrial), true);
      expect(ShelfThemeConfig.themes.containsKey(ShelfTheme.cozyPastel), true);
    });
  });

  group('WallThemeConfig', () {
    test('forTheme returns correct config for each theme', () {
      expect(WallThemeConfig.forTheme(WallTheme.plaster).displayName, 'Yeso');
      expect(WallThemeConfig.forTheme(WallTheme.brick).displayName, 'Ladrillo');
      expect(WallThemeConfig.forTheme(WallTheme.paper).displayName, 'Papel');
      expect(WallThemeConfig.forTheme(WallTheme.wood).displayName, 'Madera');
      expect(WallThemeConfig.forTheme(WallTheme.dark).displayName, 'Oscuro');
    });

    test('walls map contains all themes', () {
      expect(WallThemeConfig.walls.length, 5);
      expect(WallThemeConfig.walls.containsKey(WallTheme.plaster), true);
      expect(WallThemeConfig.walls.containsKey(WallTheme.brick), true);
      expect(WallThemeConfig.walls.containsKey(WallTheme.paper), true);
      expect(WallThemeConfig.walls.containsKey(WallTheme.wood), true);
      expect(WallThemeConfig.walls.containsKey(WallTheme.dark), true);
    });
  });

  group('BookShelfFilter', () {
    test('isActive returns true when searchQuery is not empty', () {
      const filter = BookShelfFilter(searchQuery: 'test');
      expect(filter.isActive, true);
    });

    test('isActive returns true when genres is not empty', () {
      const filter = BookShelfFilter(genres: {'fantasy'});
      expect(filter.isActive, true);
    });

    test('isActive returns true when minRating is set', () {
      const filter = BookShelfFilter(minRating: 3);
      expect(filter.isActive, true);
    });

    test('isActive returns false when all fields are default', () {
      const filter = BookShelfFilter();
      expect(filter.isActive, false);
    });

    test('copyWith returns new instance with updated searchQuery', () {
      const original = BookShelfFilter(searchQuery: 'old');
      final copied = original.copyWith(searchQuery: 'new');
      expect(copied.searchQuery, 'new');
      expect(original.searchQuery, 'old');
    });

    test('copyWith returns new instance with updated genres', () {
      const original = BookShelfFilter(genres: {'old'});
      final copied = original.copyWith(genres: {'new'});
      expect(copied.genres, {'new'});
      expect(original.genres, {'old'});
    });

    test('copyWith returns new instance with cleared minRating', () {
      const original = BookShelfFilter(minRating: 3);
      final copied = original.copyWith(clearMinRating: true);
      expect(copied.minRating, null);
      expect(original.minRating, 3);
    });

    test('copyWith preserves other values when updating', () {
      const original = BookShelfFilter(searchQuery: 'query', genres: {'genre'}, minRating: 3);
      final copied = original.copyWith(searchQuery: 'newQuery');
      expect(copied.searchQuery, 'newQuery');
      expect(copied.genres, {'genre'});
      expect(copied.minRating, 3);
    });
  });
}
