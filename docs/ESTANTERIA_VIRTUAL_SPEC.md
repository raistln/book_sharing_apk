# 📚 Implementación Completa: Estantería Virtual Interactiva con Mejoras

## Contexto del Proyecto

Estoy desarrollando **PassTheBook**, una app Flutter para gestionar bibliotecas personales y préstamos de libros. Necesito implementar una feature llamada "Mi Estantería Virtual" que muestre visualmente los libros completados del usuario como lomos en una estantería, con capacidades avanzadas de organización y personalización.

**Stack actual:**
- Flutter 3.4+
- Dart 3.4+
- Drift (SQLite) para base de datos local
- Riverpod para gestión de estado
- Supabase para sincronización (opcional)
- Material Design 3

**Filosofía de la app:** Tranquila, contemplativa, sin gamificación estresante ni presión para el usuario.

---

## Objetivo de la Feature

Crear una pantalla interactiva que:
1. Muestre todos los libros completados por el usuario como lomos verticales en estanterías
2. Los lomos se generan automáticamente a partir de las portadas existentes
3. El grosor del lomo varía según el número de páginas del libro
4. **Reorganización manual:** El usuario puede arrastrar y soltar libros para cambiarlos de posición
5. **Filtros avanzados:** Por título, autor, género, fecha de lectura, valoración
6. **Ordenamiento múltiple:** Alfabético, cronológico, por color de portada, por autor, por páginas
7. **Temas visuales:** Diferentes estilos de estantería (madera clásica, blanco moderno, industrial)
8. **Animaciones suaves:** Al añadir nuevos libros, reorganizar, o cambiar de vista
9. Al hacer tap en un lomo, navega al detalle del libro
10. Incluye opción de compartir captura de la estantería como imagen
11. Diseño cálido y acogedor (colores papel envejecido, madera)

---

## Especificaciones Técnicas

### 1. Modelo de Datos Existente

Ya tengo una tabla `user_books` en Drift con esta estructura:

```dart
class UserBooks extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get bookId => text()();
  TextColumn get status => text()(); // 'reading', 'completed', 'wishlist'
  DateTimeColumn get finishedDate => dateTime().nullable()();
  IntColumn get currentPage => integer().nullable()();
  RealColumn get progress => real().nullable()();
  IntColumn get rating => integer().nullable()(); // 1-4 estrellas
}

class Books extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get author => text()();
  TextColumn get coverUrl => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
  TextColumn get isbn => text().nullable()();
  TextColumn get genre => text().nullable()(); // Género principal
  IntColumn get publicationYear => integer().nullable()();
}
```

### 2. Nueva Tabla: Posiciones Personalizadas de Libros

Para soportar reorganización manual, necesito una nueva tabla:

```dart
class BookShelfPositions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get bookId => text()();
  IntColumn get position => integer()(); // Posición en la estantería (0, 1, 2, ...)
  DateTimeColumn get lastModified => dateTime()();
  
  @override
  Set<Column> get primaryKey => {userId, bookId};
}
```

**Lógica de posiciones:**
- Cuando el usuario arrastra un libro, se actualiza su `position`
- Los libros sin posición asignada se ordenan según criterio activo (fecha, alfabético, etc.)
- Si el usuario aplica un filtro/ordenamiento automático, se pueden resetear las posiciones (con confirmación)

---

## 3. Enums y Constantes

### 3.1 Tipos de Ordenamiento

```dart
enum BookShelfSortOrder {
  manual,         // Orden personalizado por el usuario (drag & drop)
  recent,         // Por fecha de lectura (más recientes primero)
  alphabetical,   // A-Z por título
  author,         // Agrupado por autor
  color,          // Arcoíris visual (por color dominante de portada)
  pageCount,      // Por número de páginas (gruesos a delgados)
  rating,         // Por valoración (4 estrellas primero)
  publicationYear // Por año de publicación
}

extension BookShelfSortOrderExtension on BookShelfSortOrder {
  String get displayName {
    switch (this) {
      case BookShelfSortOrder.manual:
        return 'Personalizado';
      case BookShelfSortOrder.recent:
        return 'Recientes primero';
      case BookShelfSortOrder.alphabetical:
        return 'Alfabético (A-Z)';
      case BookShelfSortOrder.author:
        return 'Por autor';
      case BookShelfSortOrder.color:
        return 'Por color';
      case BookShelfSortOrder.pageCount:
        return 'Por páginas';
      case BookShelfSortOrder.rating:
        return 'Por valoración';
      case BookShelfSortOrder.publicationYear:
        return 'Por año';
    }
  }
  
  IconData get icon {
    switch (this) {
      case BookShelfSortOrder.manual:
        return Icons.touch_app;
      case BookShelfSortOrder.recent:
        return Icons.access_time;
      case BookShelfSortOrder.alphabetical:
        return Icons.sort_by_alpha;
      case BookShelfSortOrder.author:
        return Icons.person;
      case BookShelfSortOrder.color:
        return Icons.palette;
      case BookShelfSortOrder.pageCount:
        return Icons.library_books;
      case BookShelfSortOrder.rating:
        return Icons.star;
      case BookShelfSortOrder.publicationYear:
        return Icons.calendar_today;
    }
  }
}
```

### 3.2 Temas de Estantería

```dart
enum ShelfTheme {
  classicWood,    // Madera oscura (por defecto)
  modernWhite,    // Blanco minimalista
  vintageBrown,   // Marrón vintage
  industrial,     // Metal oscuro y hormigón
  cozyPastel,     // Tonos pastel suaves
}

class ShelfThemeConfig {
  final Color backgroundColor;
  final Color shelfWoodDark;
  final Color shelfWoodLight;
  final Color textPrimary;
  final Color textSecondary;
  final String displayName;
  
  const ShelfThemeConfig({
    required this.backgroundColor,
    required this.shelfWoodDark,
    required this.shelfWoodLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.displayName,
  });
  
  static const Map<ShelfTheme, ShelfThemeConfig> themes = {
    ShelfTheme.classicWood: ShelfThemeConfig(
      backgroundColor: Color(0xFFF5F1E8),
      shelfWoodDark: Color(0xFF8B7355),
      shelfWoodLight: Color(0xFF6B5D4F),
      textPrimary: Color(0xFF2C2416),
      textSecondary: Color(0xFF8B7355),
      displayName: 'Madera Clásica',
    ),
    ShelfTheme.modernWhite: ShelfThemeConfig(
      backgroundColor: Color(0xFFFAFAFA),
      shelfWoodDark: Color(0xFFE0E0E0),
      shelfWoodLight: Color(0xFFC0C0C0),
      textPrimary: Color(0xFF212121),
      textSecondary: Color(0xFF757575),
      displayName: 'Blanco Moderno',
    ),
    ShelfTheme.vintageBrown: ShelfThemeConfig(
      backgroundColor: Color(0xFFEDE7DA),
      shelfWoodDark: Color(0xFF5D4E37),
      shelfWoodLight: Color(0xFF4A3F2E),
      textPrimary: Color(0xFF3E2723),
      textSecondary: Color(0xFF6D4C41),
      displayName: 'Vintage',
    ),
    ShelfTheme.industrial: ShelfThemeConfig(
      backgroundColor: Color(0xFF37474F),
      shelfWoodDark: Color(0xFF263238),
      shelfWoodLight: Color(0xFF1C2226),
      textPrimary: Color(0xFFECEFF1),
      textSecondary: Color(0xFFB0BEC5),
      displayName: 'Industrial',
    ),
    ShelfTheme.cozyPastel: ShelfThemeConfig(
      backgroundColor: Color(0xFFFFF3E0),
      shelfWoodDark: Color(0xFFFFB74D),
      shelfWoodLight: Color(0xFFFFA726),
      textPrimary: Color(0xFF4E342E),
      textSecondary: Color(0xFF8D6E63),
      displayName: 'Pastel Acogedor',
    ),
  };
}
```

### 3.3 Filtros de Búsqueda

```dart
class BookShelfFilter {
  final String? searchQuery;        // Búsqueda por título/autor
  final List<String>? genres;       // Filtrar por géneros
  final int? minRating;             // Mínima valoración (1-4)
  final DateTimeRange? dateRange;   // Rango de fechas de lectura
  final int? minPages;              // Mínimo de páginas
  final int? maxPages;              // Máximo de páginas
  
  const BookShelfFilter({
    this.searchQuery,
    this.genres,
    this.minRating,
    this.dateRange,
    this.minPages,
    this.maxPages,
  });
  
  bool get isActive => 
      searchQuery != null ||
      genres != null ||
      minRating != null ||
      dateRange != null ||
      minPages != null ||
      maxPages != null;
  
  BookShelfFilter copyWith({
    String? searchQuery,
    List<String>? genres,
    int? minRating,
    DateTimeRange? dateRange,
    int? minPages,
    int? maxPages,
  }) {
    return BookShelfFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      genres: genres ?? this.genres,
      minRating: minRating ?? this.minRating,
      dateRange: dateRange ?? this.dateRange,
      minPages: minPages ?? this.minPages,
      maxPages: maxPages ?? this.maxPages,
    );
  }
  
  BookShelfFilter clear() => const BookShelfFilter();
}
```

---

## 4. Estado de la Estantería (Riverpod)

### 4.1 State Notifier para Gestión Completa

**Ubicación:** `lib/features/bookshelf/providers/bookshelf_state.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookshelf_state.freezed.dart';

@freezed
class BookShelfState with _$BookShelfState {
  const factory BookShelfState({
    @Default([]) List<BookWithDetails> books,
    @Default(BookShelfSortOrder.recent) BookShelfSortOrder sortOrder,
    @Default(BookShelfFilter()) BookShelfFilter filter,
    @Default(ShelfTheme.classicWood) ShelfTheme theme,
    @Default(false) bool isEditMode, // Modo edición para reorganizar
    @Default(false) bool isLoading,
    String? error,
  }) = _BookShelfState;
}

class BookShelfStateNotifier extends StateNotifier<BookShelfState> {
  final BookshelfService _service;
  final String _userId;
  
  BookShelfStateNotifier(this._service, this._userId) 
      : super(const BookShelfState()) {
    loadBooks();
  }
  
  /// Carga libros completados con filtros y ordenamiento
  Future<void> loadBooks() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final books = await _service.getCompletedBooks(
        _userId,
        sortOrder: state.sortOrder,
        filter: state.filter,
      );
      
      state = state.copyWith(
        books: books,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
  
  /// Cambia el ordenamiento
  void setSortOrder(BookShelfSortOrder newOrder) {
    state = state.copyWith(sortOrder: newOrder);
    loadBooks();
  }
  
  /// Aplica filtros
  void setFilter(BookShelfFilter newFilter) {
    state = state.copyWith(filter: newFilter);
    loadBooks();
  }
  
  /// Cambia el tema visual
  void setTheme(ShelfTheme newTheme) {
    state = state.copyWith(theme: newTheme);
  }
  
  /// Activa/desactiva modo edición
  void toggleEditMode() {
    state = state.copyWith(isEditMode: !state.isEditMode);
  }
  
  /// Reorganiza libro manualmente (drag & drop)
  Future<void> reorderBook(int oldIndex, int newIndex) async {
    // Reordenar en el estado local
    final books = List<BookWithDetails>.from(state.books);
    final book = books.removeAt(oldIndex);
    books.insert(newIndex, book);
    
    state = state.copyWith(books: books);
    
    // Persistir nuevas posiciones
    await _service.saveBookPositions(_userId, books);
    
    // Si no estamos en orden manual, cambiar a manual
    if (state.sortOrder != BookShelfSortOrder.manual) {
      state = state.copyWith(sortOrder: BookShelfSortOrder.manual);
    }
  }
  
  /// Resetea posiciones personalizadas
  Future<void> resetPositions() async {
    await _service.clearBookPositions(_userId);
    state = state.copyWith(sortOrder: BookShelfSortOrder.recent);
    loadBooks();
  }
}

// Provider
final bookShelfStateProvider = 
    StateNotifierProvider<BookShelfStateNotifier, BookShelfState>((ref) {
  final service = ref.watch(bookshelfServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  
  return BookShelfStateNotifier(service, currentUser!.id);
});
```

---

## 5. Servicio de Datos Mejorado

**Ubicación:** `lib/features/bookshelf/services/bookshelf_service.dart`

```dart
import 'package:drift/drift.dart';
import '../../../database/app_database.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';

class BookshelfService {
  final AppDatabase _database;
  
  BookshelfService(this._database);
  
  /// Obtiene libros completados con filtros y ordenamiento
  Future<List<BookWithDetails>> getCompletedBooks(
    String userId, {
    BookShelfSortOrder sortOrder = BookShelfSortOrder.recent,
    BookShelfFilter filter = const BookShelfFilter(),
  }) async {
    // Query base
    var query = _database.select(_database.userBooks).join([
      innerJoin(
        _database.books,
        _database.books.id.equalsExp(_database.userBooks.bookId),
      ),
      leftOuterJoin(
        _database.bookShelfPositions,
        _database.bookShelfPositions.bookId.equalsExp(_database.books.id) &
        _database.bookShelfPositions.userId.equals(userId),
      ),
    ])..where(
      _database.userBooks.status.equals('completed') & 
      _database.userBooks.userId.equals(userId)
    );
    
    // Aplicar filtros
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final searchTerm = '%${filter.searchQuery}%';
      query = query..where(
        _database.books.title.like(searchTerm) |
        _database.books.author.like(searchTerm)
      );
    }
    
    if (filter.genres != null && filter.genres!.isNotEmpty) {
      query = query..where(
        _database.books.genre.isIn(filter.genres!)
      );
    }
    
    if (filter.minRating != null) {
      query = query..where(
        _database.userBooks.rating.isBiggerOrEqualValue(filter.minRating!)
      );
    }
    
    if (filter.dateRange != null) {
      query = query..where(
        _database.userBooks.finishedDate.isBetweenValues(
          filter.dateRange!.start,
          filter.dateRange!.end,
        )
      );
    }
    
    if (filter.minPages != null) {
      query = query..where(
        _database.books.pageCount.isBiggerOrEqualValue(filter.minPages!)
      );
    }
    
    if (filter.maxPages != null) {
      query = query..where(
        _database.books.pageCount.isSmallerOrEqualValue(filter.maxPages!)
      );
    }
    
    // Aplicar ordenamiento
    switch (sortOrder) {
      case BookShelfSortOrder.manual:
        query = query..orderBy([
          OrderingTerm(
            expression: _database.bookShelfPositions.position,
            mode: OrderingMode.asc,
          ),
          // Fallback a fecha si no hay posición
          OrderingTerm(
            expression: _database.userBooks.finishedDate,
            mode: OrderingMode.desc,
          ),
        ]);
        break;
        
      case BookShelfSortOrder.recent:
        query = query..orderBy([
          OrderingTerm(
            expression: _database.userBooks.finishedDate,
            mode: OrderingMode.desc,
          ),
        ]);
        break;
        
      case BookShelfSortOrder.alphabetical:
        query = query..orderBy([
          OrderingTerm(
            expression: _database.books.title,
            mode: OrderingMode.asc,
          ),
        ]);
        break;
        
      case BookShelfSortOrder.author:
        query = query..orderBy([
          OrderingTerm(
            expression: _database.books.author,
            mode: OrderingMode.asc,
          ),
          OrderingTerm(
            expression: _database.books.title,
            mode: OrderingMode.asc,
          ),
        ]);
        break;
        
      case BookShelfSortOrder.pageCount:
        query = query..orderBy([
          OrderingTerm(
            expression: _database.books.pageCount,
            mode: OrderingMode.desc, // Gruesos primero
          ),
        ]);
        break;
        
      case BookShelfSortOrder.rating:
        query = query..orderBy([
          OrderingTerm(
            expression: _database.userBooks.rating,
            mode: OrderingMode.desc,
          ),
        ]);
        break;
        
      case BookShelfSortOrder.publicationYear:
        query = query..orderBy([
          OrderingTerm(
            expression: _database.books.publicationYear,
            mode: OrderingMode.desc,
          ),
        ]);
        break;
        
      case BookShelfSortOrder.color:
        // Para ordenar por color, necesitamos procesar después
        // (no se puede hacer directamente en SQL)
        break;
    }
    
    final results = await query.get();
    
    var books = results.map((row) {
      return BookWithDetails(
        book: row.readTable(_database.books),
        userBook: row.readTable(_database.userBooks),
        position: row.readTableOrNull(_database.bookShelfPositions)?.position,
      );
    }).toList();
    
    // Ordenamiento por color (post-procesamiento)
    if (sortOrder == BookShelfSortOrder.color) {
      books = await _sortByColor(books);
    }
    
    return books;
  }
  
  /// Ordena libros por color dominante de portada (arcoíris)
  Future<List<BookWithDetails>> _sortByColor(List<BookWithDetails> books) async {
    // Extraer color dominante de cada portada
    final booksWithColors = await Future.wait(
      books.map((book) async {
        final color = await _extractDominantColor(book.book.coverUrl);
        return (book: book, hue: color?.hue ?? 0.0);
      })
    );
    
    // Ordenar por matiz (hue) para crear arcoíris
    booksWithColors.sort((a, b) => a.hue.compareTo(b.hue));
    
    return booksWithColors.map((e) => e.book).toList();
  }
  
  /// Extrae color dominante de una imagen
  Future<HSLColor?> _extractDominantColor(String? coverUrl) async {
    if (coverUrl == null) return null;
    
    try {
      // Descargar imagen
      final response = await http.get(Uri.parse(coverUrl));
      final image = img.decodeImage(response.bodyBytes);
      
      if (image == null) return null;
      
      // Redimensionar a 1x1 para obtener color promedio
      final pixel = img.copyResize(image, width: 1, height: 1);
      final color = pixel.getPixel(0, 0);
      
      final flutterColor = Color.fromARGB(
        img.getAlpha(color),
        img.getRed(color),
        img.getGreen(color),
        img.getBlue(color),
      );
      
      return HSLColor.fromColor(flutterColor);
    } catch (e) {
      return null;
    }
  }
  
  /// Guarda posiciones personalizadas de libros
  Future<void> saveBookPositions(
    String userId,
    List<BookWithDetails> books,
  ) async {
    await _database.transaction(() async {
      // Limpiar posiciones existentes
      await (_database.delete(_database.bookShelfPositions)
        ..where((tbl) => tbl.userId.equals(userId))
      ).go();
      
      // Insertar nuevas posiciones
      for (var i = 0; i < books.length; i++) {
        await _database.into(_database.bookShelfPositions).insert(
          BookShelfPositionsCompanion(
            id: Value(uuid.v4()),
            userId: Value(userId),
            bookId: Value(books[i].book.id),
            position: Value(i),
            lastModified: Value(DateTime.now()),
          ),
        );
      }
    });
  }
  
  /// Limpia posiciones personalizadas (resetear a ordenamiento automático)
  Future<void> clearBookPositions(String userId) async {
    await (_database.delete(_database.bookShelfPositions)
      ..where((tbl) => tbl.userId.equals(userId))
    ).go();
  }
  
  /// Cuenta total de libros completados
  Future<int> getCompletedBooksCount(String userId) async {
    final query = _database.select(_database.userBooks)
      ..where((tbl) => 
        tbl.status.equals('completed') & 
        tbl.userId.equals(userId)
      );
    
    return await query.get().then((rows) => rows.length);
  }
}

class BookWithDetails {
  final Book book;
  final UserBook userBook;
  final int? position; // Posición personalizada (null si no establecida)
  
  BookWithDetails({
    required this.book,
    required this.userBook,
    this.position,
  });
}
```

---

## 6. Widget Principal: VirtualBookshelfScreen (Mejorado)

**Ubicación:** `lib/features/bookshelf/screens/virtual_bookshelf_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import '../providers/bookshelf_state.dart';
import '../widgets/bookshelf_header.dart';
import '../widgets/bookshelf_toolbar.dart';
import '../widgets/shelf_row_widget.dart';
import '../widgets/book_spine_widget.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/theme_selector_dialog.dart';
import '../services/bookshelf_share_service.dart';

class VirtualBookshelfScreen extends ConsumerStatefulWidget {
  const VirtualBookshelfScreen({Key? key}) : super(key: key);
  
  @override
  ConsumerState<VirtualBookshelfScreen> createState() => _VirtualBookshelfScreenState();
}

class _VirtualBookshelfScreenState extends ConsumerState<VirtualBookshelfScreen> {
  final _screenshotController = ScreenshotController();
  final _scrollController = ScrollController();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookShelfStateProvider);
    final notifier = ref.read(bookShelfStateProvider.notifier);
    final themeConfig = ShelfThemeConfig.themes[state.theme]!;
    
    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Mi Estantería',
          style: TextStyle(fontFamily: 'Georgia'),
        ),
        backgroundColor: themeConfig.shelfWoodDark,
        foregroundColor: themeConfig.textPrimary,
        actions: [
          // Botón de tema
          IconButton(
            icon: Icon(Icons.palette),
            tooltip: 'Cambiar tema',
            onPressed: () => _showThemeSelector(context),
          ),
          
          // Botón de filtros
          Badge(
            isLabelVisible: state.filter.isActive,
            child: IconButton(
              icon: Icon(Icons.filter_list),
              tooltip: 'Filtrar',
              onPressed: () => _showFilters(context),
            ),
          ),
          
          // Botón de modo edición
          IconButton(
            icon: Icon(
              state.isEditMode ? Icons.done : Icons.edit,
              color: state.isEditMode ? Colors.green : null,
            ),
            tooltip: state.isEditMode ? 'Terminar edición' : 'Reorganizar',
            onPressed: () => notifier.toggleEditMode(),
          ),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: state.isLoading
            ? _buildLoading(themeConfig)
            : state.error != null
                ? _buildError(state.error!, themeConfig)
                : state.books.isEmpty
                    ? _buildEmptyState(themeConfig)
                    : _buildBookshelfContent(state, themeConfig, notifier),
      ),
      floatingActionButton: state.books.isNotEmpty
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón scroll to top (solo visible si scrolled)
                if (_scrollController.hasClients && _scrollController.offset > 200)
                  FloatingActionButton.small(
                    heroTag: 'scroll_top',
                    onPressed: () => _scrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    ),
                    child: Icon(Icons.arrow_upward),
                    backgroundColor: themeConfig.shelfWoodLight,
                  ),
                
                SizedBox(height: 8),
                
                // Botón compartir
                FloatingActionButton.extended(
                  heroTag: 'share',
                  onPressed: () => _shareBookshelf(state.books.length),
                  icon: Icon(Icons.share),
                  label: Text('Compartir'),
                  backgroundColor: themeConfig.shelfWoodDark,
                ),
              ],
            )
          : null,
    );
  }
  
  Widget _buildBookshelfContent(
    BookShelfState state,
    ShelfThemeConfig themeConfig,
    BookShelfStateNotifier notifier,
  ) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          // Header con estadísticas
          BookshelfHeader(
            bookCount: state.books.length,
            themeConfig: themeConfig,
          ),
          
          // Toolbar con ordenamiento
          BookshelfToolbar(
            currentSort: state.sortOrder,
            onSortChanged: (newSort) => notifier.setSortOrder(newSort),
            themeConfig: themeConfig,
            isEditMode: state.isEditMode,
            onResetPositions: () => _confirmResetPositions(notifier),
          ),
          
          SizedBox(height: 16),
          
          // Estanterías con libros
          state.isEditMode
              ? _buildReorderableBookshelf(state, themeConfig, notifier)
              : _buildStaticBookshelf(state, themeConfig),
          
          SizedBox(height: 40),
        ],
      ),
    );
  }
  
  /// Estantería estática (modo visualización)
  Widget _buildStaticBookshelf(BookShelfState state, ShelfThemeConfig themeConfig) {
    final rows = (state.books.length / 15).ceil();
    
    return Column(
      children: List.generate(rows, (rowIndex) {
        final startIndex = rowIndex * 15;
        final endIndex = (startIndex + 15).clamp(0, state.books.length);
        final rowBooks = state.books.sublist(startIndex, endIndex);
        
        return ShelfRowWidget(
          books: rowBooks,
          themeConfig: themeConfig,
          rowIndex: rowIndex,
          onBookTap: (book) => _navigateToBookDetail(book),
        );
      }),
    );
  }
  
  /// Estantería reorganizable (modo edición)
  Widget _buildReorderableBookshelf(
    BookShelfState state,
    ShelfThemeConfig themeConfig,
    BookShelfStateNotifier notifier,
  ) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: state.books.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        notifier.reorderBook(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final book = state.books[index];
        
        return Container(
          key: ValueKey(book.book.id),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              // Handle para arrastrar
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.drag_handle,
                    color: themeConfig.textSecondary,
                  ),
                ),
              ),
              
              // Lomo del libro
              Expanded(
                child: BookSpineWidget(
                  book: book.book,
                  onTap: () => _navigateToBookDetail(book),
                  themeConfig: themeConfig,
                ),
              ),
              
              SizedBox(width: 8),
              
              // Info rápida
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    book.book.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: themeConfig.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    book.book.author,
                    style: TextStyle(
                      fontSize: 10,
                      color: themeConfig.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildLoading(ShelfThemeConfig themeConfig) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: themeConfig.shelfWoodDark),
          SizedBox(height: 16),
          Text(
            'Preparando tu estantería...',
            style: TextStyle(
              fontFamily: 'Georgia',
              color: themeConfig.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildError(String error, ShelfThemeConfig themeConfig) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text('Error al cargar libros'),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => ref.read(bookShelfStateProvider.notifier).loadBooks(),
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(ShelfThemeConfig themeConfig) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories,
              size: 64,
              color: themeConfig.textSecondary.withOpacity(0.3),
            ),
            SizedBox(height: 16),
            Text(
              'Tu estantería espera',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 20,
                color: themeConfig.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Cada libro que termines\naparecerá aquí como un recuerdo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 14,
                color: themeConfig.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showThemeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ThemeSelectorDialog(
        currentTheme: ref.read(bookShelfStateProvider).theme,
        onThemeSelected: (theme) {
          ref.read(bookShelfStateProvider.notifier).setTheme(theme);
          Navigator.pop(context);
        },
      ),
    );
  }
  
  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        currentFilter: ref.read(bookShelfStateProvider).filter,
        onFilterApplied: (filter) {
          ref.read(bookShelfStateProvider.notifier).setFilter(filter);
          Navigator.pop(context);
        },
      ),
    );
  }
  
  void _confirmResetPositions(BookShelfStateNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resetear posiciones'),
        content: Text(
          '¿Quieres volver al ordenamiento automático? '
          'Se perderá tu organización personalizada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.resetPositions();
              Navigator.pop(context);
            },
            child: Text('Resetear'),
          ),
        ],
      ),
    );
  }
  
  void _navigateToBookDetail(BookWithDetails book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(bookId: book.book.id),
      ),
    );
  }
  
  Future<void> _shareBookshelf(int bookCount) async {
    await BookshelfShareService().shareBookshelf(
      context,
      _screenshotController,
      bookCount,
    );
  }
}
```

---

## 7. Widgets Auxiliares

### 7.1 BookshelfHeader

**Ubicación:** `lib/features/bookshelf/widgets/bookshelf_header.dart`

```dart
import 'package:flutter/material.dart';

class BookshelfHeader extends StatelessWidget {
  final int bookCount;
  final ShelfThemeConfig themeConfig;
  
  const BookshelfHeader({
    required this.bookCount,
    required this.themeConfig,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '📚',
            style: TextStyle(fontSize: 48),
          ),
          SizedBox(height: 8),
          Text(
            '$bookCount ${_getPluralText(bookCount)}',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeConfig.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Cada lomo es un recuerdo',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: themeConfig.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getPluralText(int count) {
    if (count == 1) return 'historia vivida';
    return 'historias vividas';
  }
}
```

### 7.2 BookshelfToolbar

**Ubicación:** `lib/features/bookshelf/widgets/bookshelf_toolbar.dart`

```dart
import 'package:flutter/material.dart';

class BookshelfToolbar extends StatelessWidget {
  final BookShelfSortOrder currentSort;
  final Function(BookShelfSortOrder) onSortChanged;
  final ShelfThemeConfig themeConfig;
  final bool isEditMode;
  final VoidCallback onResetPositions;
  
  const BookshelfToolbar({
    required this.currentSort,
    required this.onSortChanged,
    required this.themeConfig,
    required this.isEditMode,
    required this.onResetPositions,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.sort,
            color: themeConfig.textSecondary,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'Ordenar por:',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 14,
              color: themeConfig.textSecondary,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: BookShelfSortOrder.values.map((order) {
                  final isSelected = currentSort == order;
                  
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(order.icon, size: 16),
                          SizedBox(width: 4),
                          Text(order.displayName),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) onSortChanged(order);
                      },
                      backgroundColor: themeConfig.backgroundColor,
                      selectedColor: themeConfig.shelfWoodDark.withOpacity(0.3),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected 
                          ? themeConfig.textPrimary
                          : themeConfig.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Botón de reset (solo visible en modo manual)
          if (currentSort == BookShelfSortOrder.manual && !isEditMode)
            IconButton(
              icon: Icon(Icons.refresh, size: 20),
              tooltip: 'Resetear orden',
              color: themeConfig.textSecondary,
              onPressed: onResetPositions,
            ),
        ],
      ),
    );
  }
}
```

### 7.3 BookSpineWidget

**Ubicación:** `lib/features/bookshelf/widgets/book_spine_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookSpineWidget extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final ShelfThemeConfig themeConfig;
  
  const BookSpineWidget({
    required this.book,
    required this.onTap,
    required this.themeConfig,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final width = _calculateSpineWidth(book.pageCount);
    
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'book_${book.id}',
        child: Container(
          width: width,
          height: 200,
          margin: EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            image: book.coverUrl != null
                ? DecorationImage(
                    image: CachedNetworkImageProvider(book.coverUrl!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.2),
                      BlendMode.darken,
                    ),
                  )
                : null,
            color: book.coverUrl == null ? themeConfig.shelfWoodDark : null,
            border: Border(
              left: BorderSide(
                color: Colors.black.withOpacity(0.3),
                width: 2,
              ),
              right: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(2, 0),
                blurRadius: 3,
              ),
            ],
          ),
          child: RotatedBox(
            quarterTurns: 3,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _calculateFontSize(width),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
                        shadows: [
                          Shadow(
                            color: Colors.black87,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: _calculateFontSize(width) * 0.7,
                        fontFamily: 'Georgia',
                        shadows: [
                          Shadow(
                            color: Colors.black87,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  double _calculateSpineWidth(int? pageCount) {
    if (pageCount == null) return 35.0;
    
    if (pageCount < 100) return 25.0;
    if (pageCount < 200) return 30.0;
    if (pageCount < 400) return 40.0;
    if (pageCount < 600) return 50.0;
    return 60.0;
  }
  
  double _calculateFontSize(double width) {
    return (width * 0.25).clamp(9.0, 14.0);
  }
}
```

### 7.4 ShelfRowWidget

**Ubicación:** `lib/features/bookshelf/widgets/shelf_row_widget.dart`

```dart
import 'package:flutter/material.dart';

class ShelfRowWidget extends StatelessWidget {
  final List<BookWithDetails> books;
  final ShelfThemeConfig themeConfig;
  final int rowIndex;
  final Function(BookWithDetails) onBookTap;
  
  const ShelfRowWidget({
    required this.books,
    required this.themeConfig,
    required this.rowIndex,
    required this.onBookTap,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (rowIndex == 0) SizedBox(height: 20),
        
        // Contenedor de libros
        Container(
          height: 220,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ...books.map((bookWithDetails) => BookSpineWidget(
                book: bookWithDetails.book,
                onTap: () => onBookTap(bookWithDetails),
                themeConfig: themeConfig,
              )),
              
              if (books.length < 15)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFE5DCC8).withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Balda de madera
        Container(
          height: 12,
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                themeConfig.shelfWoodDark,
                themeConfig.shelfWoodLight,
              ],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        
        SizedBox(height: 24),
      ],
    );
  }
}
```

### 7.5 FilterBottomSheet

**Ubicación:** `lib/features/bookshelf/widgets/filter_bottom_sheet.dart`

```dart
import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final BookShelfFilter currentFilter;
  final Function(BookShelfFilter) onFilterApplied;
  
  const FilterBottomSheet({
    required this.currentFilter,
    required this.onFilterApplied,
    Key? key,
  }) : super(key: key);
  
  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late TextEditingController _searchController;
  late List<String> _selectedGenres;
  late int? _minRating;
  late DateTimeRange? _dateRange;
  late int? _minPages;
  late int? _maxPages;
  
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.currentFilter.searchQuery);
    _selectedGenres = widget.currentFilter.genres ?? [];
    _minRating = widget.currentFilter.minRating;
    _dateRange = widget.currentFilter.dateRange;
    _minPages = widget.currentFilter.minPages;
    _maxPages = widget.currentFilter.maxPages;
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtros',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text('Limpiar todo'),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Buscar por título o autor',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    Text(
                      'Géneros',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _availableGenres.map((genre) {
                        final isSelected = _selectedGenres.contains(genre);
                        
                        return FilterChip(
                          label: Text(genre),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedGenres.add(genre);
                              } else {
                                _selectedGenres.remove(genre);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    SizedBox(height: 24),
                    
                    Text(
                      'Valoración mínima',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: List.generate(4, (index) {
                        final rating = index + 1;
                        final isSelected = _minRating == rating;
                        
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Row(
                              children: [
                                Icon(Icons.star, size: 16),
                                SizedBox(width: 4),
                                Text('$rating+'),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _minRating = selected ? rating : null;
                              });
                            },
                          ),
                        );
                      }),
                    ),
                    
                    SizedBox(height: 24),
                    
                    Text(
                      'Fecha de lectura',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: Icon(Icons.calendar_today),
                      label: Text(
                        _dateRange == null
                            ? 'Seleccionar rango'
                            : '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}',
                      ),
                      onPressed: _selectDateRange,
                    ),
                    
                    SizedBox(height: 24),
                    
                    Text(
                      'Número de páginas',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Mínimo',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(
                              text: _minPages?.toString() ?? '',
                            ),
                            onChanged: (value) {
                              _minPages = int.tryParse(value);
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Máximo',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(
                              text: _maxPages?.toString() ?? '',
                            ),
                            onChanged: (value) {
                              _maxPages = int.tryParse(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      child: Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedGenres.clear();
      _minRating = null;
      _dateRange = null;
      _minPages = null;
      _maxPages = null;
    });
  }
  
  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    
    if (range != null) {
      setState(() {
        _dateRange = range;
      });
    }
  }
  
  void _applyFilters() {
    final filter = BookShelfFilter(
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      genres: _selectedGenres.isEmpty ? null : _selectedGenres,
      minRating: _minRating,
      dateRange: _dateRange,
      minPages: _minPages,
      maxPages: _maxPages,
    );
    
    widget.onFilterApplied(filter);
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  List<String> get _availableGenres => [
    'Ficción',
    'No ficción',
    'Ciencia ficción',
    'Fantasía',
    'Romance',
    'Thriller',
    'Histórico',
    'Biografía',
    'Ensayo',
    'Poesía',
  ];
}
```

### 7.6 ThemeSelectorDialog

**Ubicación:** `lib/features/bookshelf/widgets/theme_selector_dialog.dart`

```dart
import 'package:flutter/material.dart';

class ThemeSelectorDialog extends StatelessWidget {
  final ShelfTheme currentTheme;
  final Function(ShelfTheme) onThemeSelected;
  
  const ThemeSelectorDialog({
    required this.currentTheme,
    required this.onThemeSelected,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tema de la estantería'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: ShelfTheme.values.map((theme) {
            final config = ShelfThemeConfig.themes[theme]!;
            final isSelected = theme == currentTheme;
            
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [config.shelfWoodDark, config.shelfWoodLight],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              title: Text(config.displayName),
              trailing: isSelected ? Icon(Icons.check, color: Colors.blue) : null,
              onTap: () => onThemeSelected(theme),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cerrar'),
        ),
      ],
    );
  }
}
```

---

## 8. Servicios Adicionales

### 8.1 BookshelfPreferences

**Ubicación:** `lib/features/bookshelf/services/bookshelf_preferences.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';

class BookshelfPreferences {
  static const String _keyTheme = 'bookshelf_theme';
  static const String _keySortOrder = 'bookshelf_sort_order';
  
  static Future<void> saveTheme(ShelfTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, theme.index);
  }
  
  static Future<ShelfTheme> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_keyTheme);
    
    if (index == null) return ShelfTheme.classicWood;
    
    return ShelfTheme.values[index];
  }
  
  static Future<void> saveSortOrder(BookShelfSortOrder order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySortOrder, order.index);
  }
  
  static Future<BookShelfSortOrder> loadSortOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_keySortOrder);
    
    if (index == null) return BookShelfSortOrder.recent;
    
    return BookShelfSortOrder.values[index];
  }
}
```

### 8.2 BookshelfShareService

**Ubicación:** `lib/features/bookshelf/services/bookshelf_share_service.dart`

```dart
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class BookshelfShareService {
  Future<void> shareBookshelf(
    BuildContext context,
    ScreenshotController screenshotController,
    int bookCount,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparando tu estantería...'),
                ],
              ),
            ),
          ),
        ),
      );
      
      final imageBytes = await screenshotController.capture();
      
      Navigator.pop(context);
      
      if (imageBytes == null) {
        _showError(context, 'No se pudo capturar la imagen');
        return;
      }
      
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = '${directory.path}/mi_estanteria_$timestamp.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);
      
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: _getShareText(bookCount),
        subject: 'Mi Estantería Literaria',
      );
      
    } catch (e) {
      Navigator.pop(context);
      _showError(context, 'Error al compartir: $e');
    }
  }
  
  String _getShareText(int bookCount) {
    final messages = [
      'Mi refugio literario con $bookCount libros leídos 📚',
      '$bookCount historias que han pasado por mis manos 📖',
      'Cada lomo cuenta una aventura. Total: $bookCount libros 🌟',
      'Mi biblioteca personal: $bookCount mundos explorados 🗺️',
    ];
    
    final random = DateTime.now().millisecond % messages.length;
    return '${messages[random]}\n\nCompartido desde PassTheBook';
  }
  
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

---

## 9. Dependencias Necesarias

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Estado
  flutter_riverpod: ^2.5.0
  freezed_annotation: ^2.4.1
  
  # Base de datos
  drift: ^2.16.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.9.0
  
  # UI y multimedia
  cached_network_image: ^3.3.0
  screenshot: ^2.1.0
  share_plus: ^7.2.0
  
  # Imágenes
  image: ^4.1.0
  http: ^1.1.0
  
  # Preferencias
  shared_preferences: ^2.2.0
  
  # UUID
  uuid: ^4.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code generation
  build_runner: ^2.4.0
  drift_dev: ^2.16.0
  freezed: ^2.4.1
  json_serializable: ^6.7.0
  
  # Testing
  mockito: ^5.4.0
```

---

## 10. Estructura de Archivos Completa

```
lib/
├── features/
│   └── bookshelf/
│       ├── screens/
│       │   └── virtual_bookshelf_screen.dart
│       ├── widgets/
│       │   ├── book_spine_widget.dart
│       │   ├── shelf_row_widget.dart
│       │   ├── bookshelf_header.dart
│       │   ├── bookshelf_toolbar.dart
│       │   ├── filter_bottom_sheet.dart
│       │   └── theme_selector_dialog.dart
│       ├── services/
│       │   ├── bookshelf_service.dart
│       │   ├── bookshelf_share_service.dart
│       │   └── bookshelf_preferences.dart
│       ├── providers/
│       │   └── bookshelf_state.dart (+ .freezed.dart generado)
│       └── models/
│           ├── shelf_theme.dart
│           ├── sort_order.dart
│           └── bookshelf_filter.dart
│
├── database/
│   ├── app_database.dart
│   └── tables/
│       └── book_shelf_positions.dart (nueva tabla)
│
└── test/
    └── features/
        └── bookshelf/
            ├── services/
            │   └── bookshelf_service_test.dart
            └── widgets/
                ├── book_spine_widget_test.dart
                └── shelf_row_widget_test.dart
```

---

## 11. Checklist de Implementación

### Fase 1: Base de Datos y Modelos (Día 1)
- [ ] Crear tabla `BookShelfPositions` en Drift
- [ ] Generar código con `build_runner`
- [ ] Crear enums `BookShelfSortOrder` y `ShelfTheme`
- [ ] Crear modelo `BookShelfFilter`
- [ ] Crear configuración `ShelfThemeConfig`

### Fase 2: Servicios (Día 1-2)
- [ ] Implementar `BookshelfService` con queries de filtros
- [ ] Implementar lógica de ordenamiento por color
- [ ] Implementar `saveBookPositions` y `clearBookPositions`
- [ ] Implementar `BookshelfPreferences`
- [ ] Implementar `BookshelfShareService`

### Fase 3: Estado y Providers (Día 2)
- [ ] Crear `BookShelfState` con Freezed
- [ ] Implementar `BookShelfStateNotifier`
- [ ] Configurar providers de Riverpod
- [ ] Integrar carga de preferencias

### Fase 4: Widgets Básicos (Día 2-3)
- [ ] Implementar `BookSpineWidget` con temas
- [ ] Implementar `ShelfRowWidget`
- [ ] Implementar `BookshelfHeader`
- [ ] Implementar `BookshelfToolbar`

### Fase 5: Widgets Avanzados (Día 3)
- [ ] Implementar `FilterBottomSheet` completo
- [ ] Implementar `ThemeSelectorDialog`
- [ ] Implementar modo de reorganización con `ReorderableListView`

### Fase 6: Pantalla Principal (Día 3-4)
- [ ] Implementar `VirtualBookshelfScreen`
- [ ] Integrar todos los widgets
- [ ] Añadir manejo de estados (loading, error, empty)
- [ ] Implementar navegación a detalle
- [ ] Integrar funcionalidad de compartir

### Fase 7: Navegación e Integración (Día 4)
- [ ] Añadir acceso desde `HomeScreen`
- [ ] Añadir acceso desde `ProfileScreen`
- [ ] Configurar Hero animations
- [ ] Testing en dispositivo real

### Fase 8: Testing y Refinamiento (Día 5)
- [ ] Escribir unit tests para servicios
- [ ] Escribir widget tests
- [ ] Testing manual exhaustivo
- [ ] Ajustar animaciones y transiciones
- [ ] Optimizar performance

### Fase 9: Pulido Final (Día 5)
- [ ] Ajustar colores según temas
- [ ] Verificar accesibilidad
- [ ] Probar en diferentes tamaños de pantalla
- [ ] Documentación de código
- [ ] Preparar para merge

---

## 12. Notas Importantes

### Consideraciones de Performance

1. **Lazy Loading:** Si el usuario tiene 200+ libros, usar `ListView.builder` con pagination virtual
2. **Caché de Portadas:** `cached_network_image` reduce uso de datos
3. **Debouncing de Búsqueda:** Esperar 500ms después del último carácter antes de filtrar
4. **Optimización de Screenshot:** Reducir calidad si hay muchos libros (>100)

### Consideraciones de UX

1. **Feedback Visual:** Mostrar loading indicator durante operaciones largas
2. **Confirmaciones:** Pedir confirmación antes de resetear posiciones personalizadas
3. **Undo:** Considerar implementar "deshacer" en reorganización (opcional)
4. **Accesibilidad:** Añadir `Semantics` a todos los widgets interactivos

### Gestión de Errores

- **Portadas sin URL:** Usar color sólido basado en género
- **Libros sin páginas:** Grosor por defecto (35px)
- **Error de red al compartir:** Mostrar mensaje claro con opción de reintentar
- **BD corrupta:** Fallback a ordenamiento por fecha sin posiciones

---

## 13. Resultado Esperado

Al completar esta implementación, el usuario podrá:

✅ Ver todos sus libros leídos como lomos visuales en estanterías
✅ **Reorganizar libros manualmente** arrastrando y soltando
✅ **Filtrar por múltiples criterios** (búsqueda, género, valoración, fechas, páginas)
✅ **Ordenar de 8 formas diferentes** (manual, reciente, alfabético, autor, color, páginas, valoración, año)
✅ **Cambiar el tema visual** de la estantería (5 temas disponibles)
✅ Hacer tap en cualquier lomo para ver detalle del libro
✅ Capturar y compartir su estantería en redes sociales
✅ Disfrutar de animaciones suaves al cargar y reorganizar
✅ Ver su biblioteca de forma contemplativa sin presión
✅ Las preferencias se guardan automáticamente (tema, ordenamiento)

---

**¡Buena suerte con la implementación! 🚀📚**
