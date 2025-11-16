# Plan de mitigación para grupos grandes

## Objetivos
- Garantizar tiempos de carga aceptables cuando un grupo contiene cientos de libros/préstamos.
- Reducir el tráfico y el consumo de memoria en la app.
- Mantener la experiencia de usuario fluida con herramientas de búsqueda y filtros.

## Líneas de acción

### 1. Optimización de consultas y paginación
- Introducir paginación/scroll infinito en la lista de libros compartidos (`LoanDetail`) dentro del Discover tab.
- Añadir filtros por estado (disponible, reservado, prestado) y por texto (título/autor) para limitar los resultados.
- Aprovechar capabilities de Drift para `LIMIT/OFFSET` y, en la parte remota, añadir índices en Supabase para columnas usadas en filtros.

### 2. Cache e invalidación granular
- Mantener cache local de la última página cargada y refrescar por lote en segundo plano.
- Usar `watch` solo para subconjuntos críticos (préstamos activos) y recurrir a `fetch` puntual para históricos.
- Al recibir actualizaciones, invalidar únicamente los elementos afectados en lugar de recargar toda la colección.

### 3. Mejoras de UI/UX
- Añadir control de búsqueda y chips de estado en la cabecera del listado.
- Agrupar la vista en secciones (disponibles, reservas activas, préstamos) cuando el dataset es grande.
- Mostrar estadísticas rápidas del grupo para ofrecer contexto sin requerir cargar todas las filas.

### 4. Monitorización
- Registrar métricas básicas (tiempo de consulta, número de elementos cargados) en modo debug para identificar cuellos de botella.
- Definir umbrales de volumen; al superarlos, activar automáticamente vistas resumidas o paginación más agresiva.

## Iteraciones sugeridas
1. **MVP de paginación + filtros de estado** (iteración actual).
2. Cache de páginas y actualización granular.
3. Instrumentación de métricas y ajustes automáticos.
