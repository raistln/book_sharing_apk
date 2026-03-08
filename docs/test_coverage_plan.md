# Plan de Mejora de Cobertura de Tests para Book Sharing App

## Resumen Ejecutivo
La aplicación Book Sharing App tiene una cobertura de tests baja (22.79% total). Este plan detalla los pasos para corregir tests fallidos, agregar nuevos tests y aumentar la cobertura a niveles aceptables (objetivo: 80%+ en categorías críticas).

## Datos Actuales de Cobertura (Actualizado)
- **Cobertura total**: 21.35%
- **Archivos analizados**: 100
- **Líneas totales**: 26,566
- **Líneas cubiertas**: 5,673

### Cobertura por Categoría
| Categoría      | Archivos | Líneas Totales | Líneas Cubiertas | Cobertura % |
|----------------|----------|----------------|------------------|-------------|
| data          | 35      | 21,060        | 3,601           | 17.10%    |
| design_system | 1       | 58            | 27              | 46.55%    |
| dev           | 1       | 31             | 12              | 38.71%    |
| models        | 11      | 372           | 323             | 86.83%    |
| providers     | 6       | 629            | 71              | 11.29%     |
| services      | 38      | 3,867         | 1,177           | 30.44%    |
| ui            | 6       | 433           | 383             | 88.45%    |
| utils         | 2       | 116           | 101             | 87.07%    |

## Archivos de Test Existentes

- test/data/models/in_app_notification_status_test.dart
- test/data/models/in_app_notification_type_test.dart
- test/data/repositories/book_repository_test.dart
- test/data/repositories/group_push_repository_test.dart
- test/data/repositories/loan_repository_test.dart
- test/data/repositories/notification_repository_test.dart
- test/data/repositories/reading_repository_test.dart
- test/data/repositories/supabase_club_book_sync_repository_test.dart
- test/data/repositories/supabase_notification_sync_repository_test.dart
- test/data/repositories/supabase_user_sync_repository_test.dart
- test/data/repositories/user_repository_test.dart
- test/data/repositories/wishlist_repository_test.dart
- test/helpers/test_helper.dart
- test/integration/basic_integration_test.dart
- test/models/book_genre_test.dart
- test/models/bulletin_test.dart
- test/models/global_sync_state_test.dart
- test/models/reading_section_test.dart
- test/models/reading_status_test.dart
- test/models/user_profile_test.dart
- test/models/bookshelf_models_test.dart
- test/models/club_enums_test.dart
- test/models/recommendation_level_test.dart
- test/models/release_note_test.dart
- test/models/sync_config_test.dart
- test/repositories/book_repository_test.dart
- test/repositories/borrowed_books_test.dart
- test/repositories/loan_repository_test.dart
- test/repositories/notification_repository_test.dart
- test/repositories/user_repository_test.dart
- test/run_diagnostics_test.dart
- test/services/auth_service_test.dart
- test/services/book_import_service_test.dart
- test/services/bulletin_service_test.dart
- test/services/cover_image_service_stub_test.dart
- test/services/cover_image_service_test_fixed.dart
- test/services/google_books_api_service_test.dart
- test/services/google_books_client_test.dart
- test/services/group_push_controller_test.dart
- test/services/group_push_controller_test_fixed.dart
- test/services/loan_controller_test.dart
- test/services/notification_trigger_test.dart
- test/services/open_library_client_test.dart
- test/services/reading_rhythm_analyzer_test.dart
- test/services/stats_service_test.dart
- test/services/supabase_book_service_test.dart
- test/services/supabase_club_service_test.dart
- test/services/supabase_config_service_test.dart
- test/services/supabase_group_service_test.dart
- test/services/supabase_notification_service_test.dart
- test/services/supabase_user_service_test.dart
- test/services/unified_sync_coordinator_test.dart
- test/services/group_sync_controller_test.dart
- test/services/inactivity_service_test.dart
- test/services/loan_export_service_test.dart
- test/services/loan_sync_controller_test.dart
- test/services/notification_service_test.dart
- test/services/onboarding_service_test.dart
- test/services/permission_service_test.dart
- test/services/reading_timeline_service_test.dart
- test/services/release_notes_service_test.dart
- test/services/section_comment_service_test.dart
- test/providers/api_providers_test.dart
- test/providers/auth_providers_test.dart
- test/providers/auto_backup_providers_test.dart
- test/providers/book_providers_test.dart
- test/providers/bookshelf_providers_test.dart
- test/providers/bulletin_providers_test.dart
- test/providers/clubs_provider_test.dart
- test/providers/cover_refresh_providers_test.dart
- test/providers/import_providers_test.dart
- test/providers/library_filters_providers_test.dart
- test/ui/widgets/profile/reading_rhythm_chart_test.dart
- test/utils/isbn_utils_test.dart
- test/utils/reading_rhythm_helper_test.dart
- test/widget/coach_mark_sequences_test.dart
- test/widget/empty_state_test.dart
- test/widget/library_search_bar_test.dart
- test/widget_test.dart

## Progreso
- ✅ Corregidos tests fallidos: supabase_user_sync_repository_test.dart y reading_rhythm_chart_test.dart
- ✅ Agregados tests para book_repository.dart (data)
- ✅ Agregados tests para modelos (in_app_notification_type.dart, in_app_notification_status.dart y global_sync_state.dart)
- ✅ Agregados tests para user_repository.dart (data)
- ✅ Agregados tests para reading_repository.dart (data)
- ✅ Agregados tests para loan_repository.dart (data)
- ✅ Agregados tests para wishlist_repository.dart (data)
- ✅ Agregados tests para notification_repository.dart (data)
- ✅ Agregados tests para group_push_repository.dart (data)
- ✅ Agregados tests para supabase_config_service.dart (services)
- ✅ Agregados tests para supabase_user_service.dart (services)
- ✅ Agregados tests para supabase_book_service.dart (services)
- ✅ Agregados tests para supabase_group_service.dart (services)
- ✅ Agregados tests para modelos adicionales (bookshelf_models, club_enums, recommendation_level, release_note, sync_config)
- ✅ Agregados tests para servicios adicionales (group_sync_controller, inactivity_service, loan_export_service, loan_sync_controller, notification_service, onboarding_service, permission_service, reading_timeline_service, release_notes_service, section_comment_service)
- ✅ Agregados tests para proveedores (api_providers, auth_providers, auto_backup_providers, book_providers, bookshelf_providers, bulletin_providers, clubs_provider, cover_refresh_providers, import_providers, library_filters_providers)
- 📈 Cobertura total: 21.35%
- 📈 Cobertura data: 17.10%
- 📈 Cobertura providers: 11.29%
- 📈 Cobertura services: 30.44%

## Objetivos
- Corregir todos los tests fallidos.
- Aumentar cobertura total a al menos 60%.
- Categorías críticas (data, models, services) a 70%+.
- Mantener cobertura alta en UI (actual 88%).

## Plan de Acción

### Fase 1: Corrección de Tests Fallidos
1. **Identificar todos los tests fallidos**: Ejecutar `flutter test` y recopilar lista completa.
2. **Corregir uno por uno**:
   - Analizar el fallo.
   - Depurar el código.
   - Ejecutar el test individual para verificar corrección.
3. **Verificar que no se rompan otros tests**: Después de cada corrección, ejecutar suite completa.

### Fase 2: Aumento de Cobertura en Áreas de Baja Cobertura
1. **Categoría Data (18.67%)**:
   - Identificar archivos en `lib/data/` sin tests.
   - Crear tests unitarios para repositorios (e.g., `BookRepository`, `UserRepository`).
   - Enfocarse en métodos CRUD, sincronización y manejo de errores.

2. **Categoría Models (15.73%)**:
   - Crear tests para clases de modelo en `lib/models/`.
   - Probar validaciones, serialización/deserialización JSON, métodos auxiliares.

3. **Categoría Services (43.80%)**:
   - Revisar y expandir tests en `test/services/`.
   - Asegurar cobertura de lógica de negocio, integración con APIs externas.

4. **Otras Categorías**:
   - Mantener y mejorar utils (59.48%).
   - Asegurar design_system y dev estén bien cubiertos.

### Fase 3: Mejoras Generales
1. **Herramientas de Cobertura**: Usar `genhtml` para reportes HTML detallados.
2. **Mocking y Fixtures**: Utilizar `mocktail` para mocks de dependencias externas.
3. **Integración Continua**: Configurar CI para ejecutar tests y verificar cobertura mínima.
4. **Documentación**: Actualizar este plan con progreso semanal.

## Métricas de Éxito
- Todos los tests pasan.
- Cobertura total ≥ 60%.
- Cobertura en data ≥ 70%, models ≥ 70%, services ≥ 70%.
- Reporte de cobertura generado automáticamente.

## Riesgos y Mitigaciones
- **Tests complejos en data**: Usar mocks para dependencias como Supabase.
- **Cambios en código**: Ejecutar tests después de cada cambio.
- **Tiempo**: Priorizar categorías críticas primero.

## Cronograma Estimado
- Semana 1: Corrección de tests fallidos.
- Semana 2-4: Aumento de cobertura en data y models.
- Semana 5: Mejoras en services y otras.
- Continua: Mantenimiento y monitoreo.

Este plan se actualizará conforme avancemos en las tareas.
