// Models and enums for the Virtual Bookshelf feature.
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Sort Order
// ─────────────────────────────────────────────

enum BookShelfSortOrder {
  recent('Recientes', Icons.schedule),
  alphabetical('A → Z', Icons.sort_by_alpha),
  author('Autor', Icons.person_outline),
  pageCount('Páginas', Icons.format_list_numbered),
  rating('Valoración', Icons.star_outline);

  const BookShelfSortOrder(this.label, this.icon);
  final String label;
  final IconData icon;
}

// ─────────────────────────────────────────────
// Shelf Theme
// ─────────────────────────────────────────────

enum ShelfTheme {
  classicWood,
  modernWhite,
  vintageBrown,
  industrial,
  cozyPastel,
}

class ShelfThemeConfig {
  final String displayName;
  final Color shelfColor;
  final Color shelfEdgeColor;
  final Color accentColor;
  final Color textColor;

  const ShelfThemeConfig({
    required this.displayName,
    required this.shelfColor,
    required this.shelfEdgeColor,
    required this.accentColor,
    required this.textColor,
  });

  static const Map<ShelfTheme, ShelfThemeConfig> themes = {
    ShelfTheme.classicWood: ShelfThemeConfig(
      displayName: 'Clásica',
      shelfColor: Color(0xFF8B6914),
      shelfEdgeColor: Color(0xFF6B4F12),
      accentColor: Color(0xFF5C3D1A),
      textColor: Color(0xFF3E2723),
    ),
    ShelfTheme.modernWhite: ShelfThemeConfig(
      displayName: 'Moderna',
      shelfColor: Color(0xFFE8E3DC),
      shelfEdgeColor: Color(0xFFD0C8BC),
      accentColor: Color(0xFF607D8B),
      textColor: Color(0xFF37474F),
    ),
    ShelfTheme.vintageBrown: ShelfThemeConfig(
      displayName: 'Vintage',
      shelfColor: Color(0xFF5D4037),
      shelfEdgeColor: Color(0xFF3E2723),
      accentColor: Color(0xFF795548),
      textColor: Color(0xFF4E342E),
    ),
    ShelfTheme.industrial: ShelfThemeConfig(
      displayName: 'Industrial',
      shelfColor: Color(0xFF455A64),
      shelfEdgeColor: Color(0xFF263238),
      accentColor: Color(0xFF78909C),
      textColor: Color(0xFF263238),
    ),
    ShelfTheme.cozyPastel: ShelfThemeConfig(
      displayName: 'Pastel',
      shelfColor: Color(0xFFBCAAA4),
      shelfEdgeColor: Color(0xFFA1887F),
      accentColor: Color(0xFFE8B4B8),
      textColor: Color(0xFF5D4037),
    ),
  };

  static ShelfThemeConfig forTheme(ShelfTheme theme) => themes[theme]!;
}

// ─────────────────────────────────────────────
// Wall Theme
// ─────────────────────────────────────────────

enum WallTheme {
  plaster,
  brick,
  paper,
  wood,
  dark,
}

class WallThemeConfig {
  final String displayName;
  final Color color;
  final double textureOpacity;

  const WallThemeConfig({
    required this.displayName,
    required this.color,
    required this.textureOpacity,
  });

  static const Map<WallTheme, WallThemeConfig> walls = {
    WallTheme.plaster: WallThemeConfig(
      displayName: 'Yeso',
      color: Color(0xFFF5F0E8),
      textureOpacity: 0.04,
    ),
    WallTheme.brick: WallThemeConfig(
      displayName: 'Ladrillo',
      color: Color(0xFFE2D1C3),
      textureOpacity: 0.15,
    ),
    WallTheme.paper: WallThemeConfig(
      displayName: 'Papel',
      color: Color(0xFFE8EAF6),
      textureOpacity: 0.08,
    ),
    WallTheme.wood: WallThemeConfig(
      displayName: 'Madera',
      color: Color(0xFFD7CCC8),
      textureOpacity: 0.12,
    ),
    WallTheme.dark: WallThemeConfig(
      displayName: 'Oscuro',
      color: Color(0xFF263238),
      textureOpacity: 0.06,
    ),
  };

  static WallThemeConfig forTheme(WallTheme theme) => walls[theme]!;
}

// ─────────────────────────────────────────────
// Filter
// ─────────────────────────────────────────────

class BookShelfFilter {
  final String searchQuery;
  final Set<String> genres;
  final int? minRating;

  const BookShelfFilter({
    this.searchQuery = '',
    this.genres = const {},
    this.minRating,
  });

  bool get isActive =>
      searchQuery.isNotEmpty || genres.isNotEmpty || minRating != null;

  BookShelfFilter copyWith({
    String? searchQuery,
    Set<String>? genres,
    int? minRating,
    bool clearMinRating = false,
  }) {
    return BookShelfFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      genres: genres ?? this.genres,
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
    );
  }
}
