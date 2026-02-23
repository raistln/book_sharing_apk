import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/release_note.dart';

final releaseNotesServiceProvider = Provider((ref) => ReleaseNotesService());

class ReleaseNotesService {
  static const _seenVersionKey = 'last_seen_release_version';

  // La versión actual de la aplicación que queremos destacar
  static const currentVersion = '1.8.0';

  final List<ReleaseNote> _releaseNotes = [
    ReleaseNote(
      version: '1.8.0',
      date: DateTime(2026, 2, 22),
      changes: [
        'Nueva Pestaña de Lectura: Panel centralizado para el seguimiento de lecturas, objetivos y estadísticas.',
        'Reordenación de Navegación: Nueva estructura de pestañas (Lectura, Biblioteca, Préstamos, Configuración).',
        'Modo Enfoque (Zen Mode): Integración con "No Molestar" y retroalimentación háptica en sesiones.',
        'Perfil de Usuario Premium: Pantalla completa dedicada con biografía y libros favoritos.',
        'Sincronización en la Nube: Sincronización bidireccional para Sesiones de Lectura y Lista de Deseos.',
        'Clubes de Lectura: Ahora puedes unirte a clubes directamente mediante código UUID.',
        'Mantenimiento Automatizado: Limpieza automática de registros antiguos y logs del sistema.',
        'Dashboard Dinámico: Mejoras en el ritmo de lectura con soporte para más libros y rangos automáticos.',
        'Backups Mejorados: Copias de seguridad automáticas en la carpeta pública de Descargas.',
        'Estantería Virtual: Personalización estética de paredes y baldas de libros.',
      ],
      thankYouMessage:
          '¡Gracias a todos los que seguís compartiendo vuestras lecturas! Esta actualización v1.8 supone un gran salto en la experiencia de usuario. ¡A disfrutar!',
    ),
    ReleaseNote(
      version: '1.3.0',
      date: DateTime(2026, 2, 9),
      changes: [
        'Copia de seguridad en la nube: Tus libros digitales y personales ahora se respaldan en Supabase.',
        'Sincronización automática: Recupera tu biblioteca al instalar la app o tras una reinstalación.',
        'Backup manual y rotativo: Control total sobre tus copias de seguridad con rotación semanal.',
        'Boletín Literario: Consulta las noticias y eventos culturales de tu provincia cada mes.',
        'Clubes de Lectura: Únete o crea comunidades para compartir lecturas con otros miembros.',
        'Mejoras de estabilidad y corrección de errores reportados por la comunidad.',
      ],
      thankYouMessage:
          'Quiero dar las gracias a mis primeros testers: Pili, David y Pablo. Sin ellos esto no hubiese sido posible. Sus ideas y entusiasmo están haciendo que esta aplicación sea verdaderamente por y para lectores. Espero que sigáis así. ¡Gracias!',
    ),
    ReleaseNote(
      version: '1.1.0',
      date: DateTime(2026, 1, 21),
      changes: [
        'Cambios en la visualización: nuevos filtros por géneros y estado de lectura (leídos/no leídos).',
        'Ordenamiento avanzado: ahora puedes ordenar por nombre, autor y fecha.',
        'Organización: nueva pestaña para separar tus libros propios de los prestados.',
        'Página de detalles: mejoras visuales y funcionales en la ficha de cada libro.',
        'Línea de tiempo: seguimiento detallado del progreso y estados de lectura.',
        'Sistema de valoración: sustituido el sistema de estrellas por uno más personal y literario.',
        'Formatos: distinción clara entre ejemplares físicos y digitales.',
        'Comparte tu pasión: posibilidad de recomendar libros por WhatsApp al terminarlos.',
        'Lista de deseos: guarda los libros que quieres leer a continuación.',
        'Pequeños ajustes y mejoras de estabilidad en grupos y perfil de usuario.',
      ],
      thankYouMessage:
          'Quiero dar las gracias a mis primeros testers: Pili, David y Pablo. Sin ellos esto no hubiese sido posible. Sus ideas y entusiasmo están haciendo que esta aplicación sea verdaderamente por y para lectores. Espero que sigáis así. ¡Gracias!',
    ),
  ];

  Future<bool> shouldShowReleaseNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSeenVersion = prefs.getString(_seenVersionKey);
    return lastSeenVersion != currentVersion;
  }

  Future<void> markReleaseNotesAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_seenVersionKey, currentVersion);
  }

  ReleaseNote? getLatestReleaseNote() {
    if (_releaseNotes.isEmpty) return null;
    return _releaseNotes.firstWhere((note) => note.version == currentVersion,
        orElse: () => _releaseNotes.first);
  }
}
