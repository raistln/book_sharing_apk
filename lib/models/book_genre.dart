enum BookGenre {
  fantasy,
  scienceFiction,
  horror,
  thrillerSuspense,
  crimeMystery,
  romance,
  historical,
  literaryFiction,
  nonFiction,
  biographyMemoir,
  essay,
  philosophy,
  poetry,
  comicsGraphicNovel,
  youngAdult,
  children,
  technicalEducational,
  selfHelp,
  politicsSociety,
  religionSpirituality,
  humor,
  adventure,
  dystopian,
  classic;

  /// Hex color representing this genre's thematic tint.
  String get primaryHex {
    switch (this) {
      case BookGenre.fantasy:
        return '#7B5EA7';
      case BookGenre.scienceFiction:
        return '#3D5A99';
      case BookGenre.horror:
        return '#8B2020';
      case BookGenre.thrillerSuspense:
      case BookGenre.crimeMystery:
        return '#4A4A5A';
      case BookGenre.romance:
        return '#C47A8A';
      case BookGenre.historical:
        return '#8B6347';
      case BookGenre.adventure:
        return '#3A7D44';
      case BookGenre.children:
      case BookGenre.youngAdult:
        return '#E07B39';
      case BookGenre.poetry:
        return '#C9A84C';
      case BookGenre.essay:
      case BookGenre.nonFiction:
      case BookGenre.biographyMemoir:
      case BookGenre.technicalEducational:
      case BookGenre.selfHelp:
      case BookGenre.politicsSociety:
      case BookGenre.religionSpirituality:
      case BookGenre.philosophy:
        return '#4A6B8A';
      case BookGenre.classic:
      case BookGenre.literaryFiction:
        return '#A08060';
      case BookGenre.comicsGraphicNovel:
      case BookGenre.humor:
      case BookGenre.dystopian:
        return '#7A7A7A';
    }
  }

  /// Decode a JSON-encoded list of genre names (stored in [Group.allowedGenres])
  /// into a [Set] of [BookGenre]. Returns empty set if [json] is null/invalid.
  static Set<BookGenre> allowedFromJson(String? json) {
    if (json == null || json.isEmpty) return const {};
    try {
      // Simple parsing of a JSON array: ["fantasy","horror"]
      final trimmed = json.trim();
      if (!trimmed.startsWith('[')) return const {};
      final inner = trimmed.substring(1, trimmed.length - 1);
      if (inner.trim().isEmpty) return const {};
      return inner
          .split(',')
          .map((s) => s.trim().replaceAll('"', "").replaceAll("'", ''))
          .where((s) => s.isNotEmpty)
          .map((s) => fromString(s))
          .whereType<BookGenre>()
          .toSet();
    } catch (_) {
      return const {};
    }
  }

  /// Encode a list of [BookGenre] as a JSON array string for [Group.allowedGenres].
  static String encodeToJson(List<BookGenre> genres) {
    if (genres.isEmpty) return '[]';
    final items = genres.map((g) => '"${g.name}"').join(',');
    return '[$items]';
  }

  String get label {
    switch (this) {
      case BookGenre.fantasy:
        return 'Fantasía';
      case BookGenre.scienceFiction:
        return 'Ciencia Ficción';
      case BookGenre.horror:
        return 'Terror';
      case BookGenre.thrillerSuspense:
        return 'Thriller / Suspense';
      case BookGenre.crimeMystery:
        return 'Crimen / Misterio';
      case BookGenre.romance:
        return 'Romance';
      case BookGenre.historical:
        return 'Histórica';
      case BookGenre.literaryFiction:
        return 'Ficción Literaria';
      case BookGenre.nonFiction:
        return 'No Ficción';
      case BookGenre.biographyMemoir:
        return 'Biografía / Memorias';
      case BookGenre.essay:
        return 'Ensayo';
      case BookGenre.philosophy:
        return 'Filosofía';
      case BookGenre.poetry:
        return 'Poesía';
      case BookGenre.comicsGraphicNovel:
        return 'Cómic / Novela Gráfica';
      case BookGenre.youngAdult:
        return 'Juvenil (YA)';
      case BookGenre.children:
        return 'Infantil';
      case BookGenre.technicalEducational:
        return 'Técnico / Educativo';
      case BookGenre.selfHelp:
        return 'Autoayuda';
      case BookGenre.politicsSociety:
        return 'Política / Sociedad';
      case BookGenre.religionSpirituality:
        return 'Religión / Espiritualidad';
      case BookGenre.humor:
        return 'Humor';
      case BookGenre.adventure:
        return 'Aventura';
      case BookGenre.dystopian:
        return 'Distopía';
      case BookGenre.classic:
        return 'Clásico';
    }
  }

  static BookGenre? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return BookGenre.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BookGenre.values.firstWhere(
        (e) => e.label == value,
        orElse: () => BookGenre.classic, // Default fallback
      ),
    );
  }

  static List<BookGenre> fromCsv(String? csv) {
    if (csv == null || csv.isEmpty) return [];
    // Support both name and label in CSV for robustness
    return csv
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => fromString(s))
        .whereType<BookGenre>()
        .toList();
  }

  static String toCsv(List<BookGenre> genres) {
    return genres.map((e) => e.name).join(',');
  }

  static BookGenre? fromExternalCategory(String? category) {
    if (category == null) return null;
    final cat = category.toLowerCase();

    if (cat.contains('fantasy')) return BookGenre.fantasy;
    if (cat.contains('science fiction')) return BookGenre.scienceFiction;
    if (cat.contains('thriller') || cat.contains('suspense')) {
      return BookGenre.thrillerSuspense;
    }
    if (cat.contains('horror')) return BookGenre.horror;
    if (cat.contains('detective') ||
        cat.contains('mystery') ||
        cat.contains('crime')) {
      return BookGenre.crimeMystery;
    }
    if (cat.contains('romance')) return BookGenre.romance;
    if (cat.contains('historical fiction')) return BookGenre.historical;
    if (cat.contains('literary')) return BookGenre.literaryFiction;
    if (cat.contains('biography') || cat.contains('memoir')) {
      return BookGenre.biographyMemoir;
    }
    if (cat.contains('essay')) return BookGenre.essay;
    if (cat.contains('philosophy')) return BookGenre.philosophy;
    if (cat.contains('poetry')) return BookGenre.poetry;
    if (cat.contains('comic') ||
        cat.contains('graphic novel') ||
        cat.contains('manga')) {
      return BookGenre.comicsGraphicNovel;
    }
    if (cat.contains('young adult')) return BookGenre.youngAdult;
    if (cat.contains('juvenile') || cat.contains('children')) {
      return BookGenre.children;
    }
    if (cat.contains('technical') ||
        cat.contains('education') ||
        cat.contains('computers')) {
      return BookGenre.technicalEducational;
    }
    if (cat.contains('self-help') || cat.contains('motivation')) {
      return BookGenre.selfHelp;
    }
    if (cat.contains('politics') || cat.contains('social science')) {
      return BookGenre.politicsSociety;
    }
    if (cat.contains('religion') || cat.contains('spiritual')) {
      return BookGenre.religionSpirituality;
    }
    if (cat.contains('humor') || cat.contains('comedy')) return BookGenre.humor;
    if (cat.contains('adventure')) return BookGenre.adventure;
    if (cat.contains('dystopian')) return BookGenre.dystopian;
    if (cat.contains('classic')) return BookGenre.classic;

    return null;
  }

  static List<BookGenre> fromExternalCategories(List<String>? categories) {
    if (categories == null || categories.isEmpty) return [];
    return categories
        .map((c) => fromExternalCategory(c))
        .whereType<BookGenre>()
        .toSet() // Remove duplicates
        .toList();
  }
}
