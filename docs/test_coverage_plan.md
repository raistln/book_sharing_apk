# Plan de Mejora de Cobertura de Tests para Book Sharing App

## Resumen Ejecutivo
La aplicación Book Sharing App tiene una cobertura de tests baja (22.79% total). Este plan detalla los pasos para corregir tests fallidos, agregar nuevos tests y aumentar la cobertura a niveles aceptables (objetivo: 80%+ en categorías críticas).

## Datos Actuales de Cobertura (Actualizado)
- **Cobertura total**: 22.77%
- **Archivos analizados**: 60
- **Líneas totales**: 22,151
- **Líneas cubiertas**: 5,043

### Cobertura por Categoría
| Categoría      | Archivos | Líneas Totales | Líneas Cubiertas | Cobertura % |
|----------------|----------|----------------|------------------|-------------|
| data          | 27      | 19,130        | 3,594           | 18.79%    |
| design_system | 1       | 58            | 27              | 46.55%    |
| dev           | 1       | 31            | 12              | 38.71%    |
| models        | 3       | 178           | 28              | 15.73%    |
| services      | 20      | 2,205         | 930             | 42.18%    |
| ui            | 6       | 433           | 383             | 88.45%    |
| utils         | 2       | 116           | 69              | 59.48%    |

## Progreso
- ✅ Corregidos tests fallidos: supabase_user_sync_repository_test.dart y reading_rhythm_chart_test.dart
- ✅ Agregados tests para book_repository.dart (data)
- ✅ Agregados tests para modelos (in_app_notification_type.dart y in_app_notification_status.dart)
- ✅ Agregados tests para user_repository.dart (data)
- ✅ Agregados tests para reading_repository.dart (data)
- ✅ Agregados tests para loan_repository.dart (data)
- ✅ Agregados tests para wishlist_repository.dart (data)
- ✅ Agregados tests para notification_repository.dart (data)
- ✅ Agregados tests para group_push_repository.dart (data)
- ✅ Agregados tests para supabase_config_service.dart (services)
- ✅ Agregados tests para supabase_user_service.dart (services)
- 📈 Cobertura total: 22.77%
- 📈 Cobertura data: 18.79%

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
