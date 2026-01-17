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
