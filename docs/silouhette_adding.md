# Agent Prompt — Shadow Silhouettes Atmospheric System

## Role
You are a senior Flutter UI + Motion Engineer implementing an ambient shadow silhouette system
for a calm, premium mobile app focused on books, libraries, and sharing.

The goal is to add subtle, atmospheric background silhouettes (Chinese shadow–style) that reinforce
narrative and emotion without distracting from content or impacting performance.

This system must feel editorial, intentional, and almost subconscious.

---

## Core Principles

- Shadows are background atmosphere, never foreground
- Movement must be extremely subtle
- No randomness that breaks visual identity
- One coherent visual language across the app
- Performance impact must be near-zero

---

## System Overview

- Total silhouettes: 8
- Style: monochrome black silhouettes
- Format: SVG preferred
- Opacity range: 2%–6%
- Rendered behind all UI in a Stack
- Wrapped in IgnorePointer + RepaintBoundary

Each main screen has assigned silhouettes, never random rotation.

---

## Screen-to-Silhouette Mapping

### 1. PIN Access Screen
- Silhouette: lone reader behind a partially open book or door
- Emotion: secrecy, protection, calm
- Movement:
  - Vertical drift ±10px over 30s
  - Opacity breathing (3% → 5%)

---

### 2. First Registration Screen
- Silhouette: figure writing or holding an open book
- Emotion: beginning, intention
- Movement:
  - Light fade-in on screen load
  - No continuous motion

---

### 3. Library Screen
- Silhouettes (2):
  - Large bookshelf
  - Seated reader
- Emotion: permanence, safety
- Movement:
  - Almost static
  - Optional parallax ±5px

---

### 4. Loans Screen
- Silhouette:
  - Two figures exchanging a book
- Emotion: trust, exchange
- Movement:
  - Slow horizontal drift ±8px

---

### 5. Groups Screen
- Silhouettes (2):
  - Group of readers
  - Books arranged in a circle
- Emotion: community
- Movement:
  - Alternating opacity (very slow)
  - No position movement

---

### 6. Settings Screen
- Silhouette:
  - Closed book or abstract symbol
- Emotion: order, control
- Movement:
  - Static

---

## Animation Constraints

- Use long-duration AnimationController (20–40s)
- Prefer Transform.translate and Opacity
- No shaders, particles, or blur filters
- Respect TickerMode for lifecycle

---

## Implementation Requirements

- Create a reusable AmbientShadowBackground widget
- Widget accepts:
  - SVG asset path
  - Animation preset enum
  - Base opacity
- Must be easily disabled globally

---

## Definition of Done

- Shadows are barely noticeable but emotionally present
- No performance drops on low-end devices
- Visuals reinforce narrative without distraction
- Code is modular, documented, and reusable

Deliver production-ready Flutter code.


## 🎯 Shadow Silhouette Positions and Usage

### Purpose
Assign each of the 8 ambient silhouettes to fixed positions on their respective screens. 
Positions are given as Flutter `Alignment(x, y)` values (range -1 to 1), with suggested relative sizes. 
Opacity must remain subtle (2–6%) to reinforce atmosphere without distracting.

---

### Silhouette Map

| Nº | Screen / Use                       | Alignment (x, y)  | Relative Size | Visual Notes |
|----|-----------------------------------|-----------------|---------------|-------------|
| 1  | Intro / Splash                     | (-0.8, 0.6)     | 0.45          | Bottom left, strong anchor |
| 2  | Intro / Splash                     | (0.75, 0.65)    | 0.40          | Bottom right, balances #1 |
| 3  | PIN Access                         | (0.0, -0.75)    | 0.35          | Top center, “watching” |
| 4  | PIN Access                         | (-0.85, -0.1)   | 0.30          | Left side, subtle presence |
| 5  | Registration (Name + PIN)          | (0.85, -0.15)   | 0.32          | Right side, accompanies form |
| 6  | Registration (Confirm PIN)         | (0.0, 0.8)      | 0.38          | Bottom center, closure feel |
| 7  | Library / Home                     | (-0.9, 0.9)     | 0.28          | Top left corner, very subtle |
| 8  | Wizard / Transition Screens        | (0.9, -0.9)     | 0.28          | Bottom right corner, can rotate slowly |

---

### General Guidelines

- Max 2 silhouettes visible per screen to avoid clutter.
- Opacity: keep between 0.02 and 0.06 (2–6%).
- Do not overlap interactive elements (inputs, buttons).
- Use subtle animation if desired:
  - Vertical drift ±5–10px over 20–40 seconds
  - Horizontal drift ±5–8px if relevant
  - Opacity breathing (±1–2%) optionally
- Wrap each silhouette in `IgnorePointer` + `RepaintBoundary` to minimize performance impact.
- Silhouettes should remain **static or slightly animated**, never flashing or distracting.

---

