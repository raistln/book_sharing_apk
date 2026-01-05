
# Agent Prompt — PIN Access & First Registration Redesign

## Role
You are a senior Flutter UX/UI + Motion Engineer working on a **personal library management app** with a dark, elegant, editorial theme.
Your task is to redesign and implement the **PIN access screen** and the **first registration screen (name + PIN creation)** so they feel integrated into the app’s narrative and aesthetic, not like generic system screens.

The app already exists and uses:
- Flutter (Material 3 base, custom theming)
- Dark mode by default
- Subtle gradients, rounded cards, calm animations
- Conceptual theme: **library, books, guardianship, knowledge, sharing**

---

## Global Design Principles (Must Follow)

- No default Material dialogs or raw TextFields
- Avoid “system/security” language
- Everything should feel **ritualistic, calm, premium**
- Animations must be subtle and purposeful (no flashy effects)
- All text should reinforce the *library / guardian / key* metaphor

---

## PHASE 1 — PIN ACCESS SCREEN (Unlock Library)

### Concept
Unlocking the app equals **opening a protected library**.
The PIN is a **key**, not just a number.

### Visual Layout
- Full-screen dark gradient background (already defined theme)
- Centered visual element:
  - Closed book OR book + subtle lock icon (SVG or icon)
- Title text:
  > “Desbloquea tu biblioteca”
- Subtitle:
  > “Introduce tu llave para acceder”

### PIN Input
- Custom PIN input (4–6 digits)
- Display as:
  - Circles / dots with soft glow
  - No visible numbers once entered
- Numeric keypad:
  - Custom styled buttons
  - Rounded, low-contrast borders
  - Soft glow or elevation on press

### Animations
- Each digit entered:
  - Circle fills with light
- Correct PIN:
  - Book opens (AnimatedSwitcher / Hero / scale + fade)
  - Transition to library screen
- Incorrect PIN:
  - Short horizontal shake
  - Optional haptic feedback
  - Error text:
    > “La llave no encaja”

### Technical Notes
- Use `AnimatedSwitcher` for book states
- Use `AnimatedContainer` for PIN dots
- Avoid blocking dialogs for errors

---

## PHASE 2 — FIRST REGISTRATION SCREEN (Name + PIN Creation)

### Concept
The user is **naming the guardian** of the library and creating its key.

### Screen Structure
Single screen with progressive sections (not a wizard with routes).

---

### Section 1 — Welcome
Text block at top:
> “Bienvenido a tu biblioteca”  
> “Antes de comenzar…”

---

### Section 2 — Name Input

Label:
> “Nombre del guardián”

Placeholder:
> “Cómo quieres que te llamemos”

Helper text:
> “Este nombre aparecerá en préstamos y grupos”

Design:
- Rounded container
- No visible borders until focused
- Soft highlight on focus

---

### Section 3 — PIN Creation

Step 1:
Title:
> “Elige tu llave”

Custom PIN input (same component as unlock screen)

Step 2:
Title:
> “Confirma la llave”

- If PINs match:
  - Visual confirmation (check / seal animation)
  - Text:
    > “La biblioteca queda protegida”

- If mismatch:
  - Gentle error message
  - Reset confirmation field only

---

### Visual Continuity
- Reuse the book visual from PIN screen
- As PIN is created:
  - Book subtly lights up
- On success:
  - Book closes with soft animation

---

## PHASE 3 — MICRO-INTERACTIONS & POLISH

### Required
- Smooth transitions between states
- Consistent typography scale
- No abrupt layout jumps

### Optional (If Time Allows)
- Soft paper / wood sound on success
- Haptic feedback on confirmation
- Hero animation from book → library screen

---

## Implementation Constraints

- Must integrate with existing app architecture
- No breaking changes to navigation
- Components must be reusable (PIN input shared)
- Keep performance high (no heavy shaders)

---

## Definition of Done

- PIN screen feels like “opening a place”, not unlocking a phone
- Registration feels emotional and intentional
- Visual language matches the rest of the app
- Code is clean, modular, and documented

Deliver production-ready Flutter widgets and animations.
