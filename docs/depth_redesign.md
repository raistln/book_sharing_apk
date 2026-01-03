# Profundización Visual y Experiencial – App de Préstamo de Libros (Flutter)

## Contexto General

La aplicación es una app Flutter para compartir libros físicos entre amigos.
Actualmente:
- UI oscura, sobria, funcional
- Paleta plana (negros, grises, acentos violetas)
- Cards limpias, jerarquía clara
- Mecánica principal: biblioteca personal + biblioteca compartida + préstamos

Objetivo:
👉 Añadir profundidad, atmósfera y sensación de “lugar”
👉 Sin romper la sobriedad ni sobrecargar la interfaz
👉 Inspiración: bibliotecas, libros físicos, fantasía, ciencia ficción y terror (de forma sutil)

Este documento define qué hacer, cómo hacerlo y en qué orden.

---

## Principios de Diseño (NO NEGOCIABLES)

- No convertir la app en un “parque temático”
- Nada infantil, nada chillón
- La atmósfera es sutil, lenta y envolvente
- Todo debe sentirse:
  - íntimo
  - relajante
  - coherente con la lectura
- Incremental: no rehacer la app, profundizarla

---

## FASE 0 – Auditoría y Preparación

- Auditar widgets base, cards y scaffold
- Centralizar decisiones visuales
- Crear carpeta `/design_system`

---

## FASE 1 – Sistema de Atmósferas

Crear un sistema de “clima visual”:
- Neutral / Biblioteca
- Fantasía
- Ciencia Ficción
- Terror

Variables:
- Colores
- Sombras
- Texturas
- Curvas de animación

---

## FASE 2 – Fondo con Vida

- Texturas sutiles (papel, grano)
- Opacidad 3–5%
- Nunca competir con contenido

---

## FASE 3 – Profundidad Real

Sombras narrativas:
- Libro normal
- Prestado
- Solicitado
- Retrasado

---

## FASE 4 – Cards como Objetos Físicos

- Portadas con sombra propia
- Textura de papel para libros sin portada

---

## FASE 5 – Microanimaciones

- Lentas (300–500 ms)
- Curvas suaves
- Nada elástico

---

## FASE 6 – Préstamos como Narrativa

Estados vacíos con textos evocadores.

---

## FASE 7 – Grupos como Comunidad

- Identidad visual ligera
- Sensación de “entrar en un lugar”

---

## FASE 8 – Ritual de la Gran Biblioteca

- Transición especial
- Feedback háptico suave

---

## FASE 9 – Música y Sonido (Opcional)

- OFF por defecto
- Loops largos
- Volumen bajo

---

## FASE 10 – Pulido Final

- Accesibilidad
- Performance
- Consistencia

---

## Resultado Esperado

Una app sobria, profunda y acogedora.
