# Project: DesignKit (Shared UI System for the App Ecosystem)
## Balanced Luxury Theme Engine + Reusable Components (SwiftUI)

---

# 0) Purpose

DesignKit is a shared package used by all ecosystem apps (Habit Tracker, Fitness Tracker, Pantry Planner, etc.) to ensure:

- consistent “Balanced Luxury” look & feel
- **no hard-coded colors** in app UIs
- shared typography, spacing, corner radius, motion
- consistent chart styling (Swift Charts)
- ability to switch themes (system/light/dark + presets)
- future ability to support a “Design Dashboard” (custom per-category colors/icons)

DesignKit is the implementation layer.  
Each app also contains `DESIGN_PHILOSOPHY.md` as the human-facing guideline.

---

# 1) What “Token List” Means

A **token list** is a set of named design values (design tokens) that the UI uses instead of raw values.

Instead of:
- `.foregroundColor(.green)`
- `.padding(14)`
- `.cornerRadius(18)`

You use:
- `.foregroundStyle(theme.colors.accent)`
- `.padding(theme.spacing.m)`
- `.clipShape(RoundedRectangle(cornerRadius: theme.radii.card))`

Tokens are:
- semantic (meaning-based): `background`, `surface`, `accent`, `success`
- consistent across apps
- easy to change globally

---

# 2) Packaging / Structure

Recommended: Swift Package (so every app imports the same source)

Repo layout (monorepo-friendly):
Ecosystem/
  Packages/
    DesignKit/
      Package.swift
      Sources/DesignKit/
        Theme/
          Theme.swift
          ThemeMode.swift
          ThemePreset.swift
          ThemeManager.swift
          Palette.swift
          Tokens.swift
        Typography/
          TypographyTokens.swift
        Layout/
          SpacingTokens.swift
          RadiusTokens.swift
        Motion/
          MotionTokens.swift
        Components/
          DKCard.swift
          DKButton.swift
          DKProgressRing.swift
          DKSectionHeader.swift
        Charts/
          DKChartStyle.swift
        Storage/
          ThemeStorage.swift
        Utilities/
          Color+Hex.swift

Apps import:
import DesignKit

---

# 3) Core Deliverables (MVP for DesignKit)

## 3.1 Theme System
- ThemeMode:
  - system
  - light
  - dark

- ThemePreset (luxury constrained):
  - Forest
  - Navy
  - Maroon
  - Walnut
  - Stone

- Theme:
  - colors (semantic tokens)
  - typography tokens
  - spacing tokens
  - radius tokens
  - motion tokens
  - chart palette tokens

- ThemeManager:
  - currentPreset
  - currentMode
  - resolves final theme based on system appearance + override
  - persists selection locally (UserDefaults or SwiftData in app)

## 3.2 “Cream First” Light Mode
Light mode background must be a **warm cream**, not pure white.
Dark mode uses charcoal (not pure black).

## 3.3 Chart Style Tokens
- chart palette = 5–7 curated tones derived from preset
- consistent axis styling, gridline opacity, label style
- never use random colors

## 3.4 Reusable Components (small set)
- DKCard (surface + shadow + padding)
- DKButton (primary/secondary)
- DKProgressRing (habit completion, pantry health, etc.)
- DKBadge (streak / status)
- DKSectionHeader

These components should accept a Theme and render consistently.

---

# 4) The Token List (MVP)

## 4.1 Color Tokens (Semantic)
These are the “no hard-coded colors” foundation.

### Neutrals
- background         (cream in light, charcoal in dark)
- surface            (card background)
- surfaceElevated    (modal/raised card)
- border             (thin separators)
- textPrimary
- textSecondary
- textTertiary

### Accents
- accentPrimary      (forest/navy/maroon depending on preset)
- accentSecondary    (supporting tone)
- highlight          (subtle emphasis)
- success            (muted, luxury-safe)
- warning            (muted)
- danger             (muted)

### Interactive States
- fillPressed
- fillSelected
- fillDisabled

## 4.2 Chart Tokens
- chart1
- chart2
- chart3
- chart4
- chart5
- chart6 (optional)

- gridlineOpacity
- axisLabelOpacity

## 4.3 Typography Tokens
- titleLarge
- title
- headline
- body
- caption
- monoNumber (for stats / timers)

Optional:
- sectionHeaderTracking (letter spacing)
- uppercaseSectionHeaders toggle

## 4.4 Spacing Tokens (Scale)
- xs = 4
- s  = 8
- m  = 12
- l  = 16
- xl = 24
- xxl= 32

## 4.5 Radius Tokens
- card = 16
- button = 14
- chip = 12
- sheet = 22

## 4.6 Motion Tokens
- fast = 0.18s
- normal = 0.28s
- slow = 0.40s
- curve = easeInOut (or a consistent spring config)

---

# 5) Theme Presets (Concept)

Each preset defines:
- accentPrimary
- accentSecondary
- chart palette (tones derived from the preset)
- optional “signature” tint for rings/badges

Presets:
- Forest: deep green + cream + warm neutrals
- Navy: navy + cream + slate
- Maroon: oxblood + cream + charcoal
- Walnut: warm brown + cream + olive undertones
- Stone: gray-blue + cream + charcoal

All presets share:
- same neutral system
- same semantic token names
- same typography/spacing/radii

---

# 6) Future: Design Dashboard Support (Planned)
DesignKit should support (later) optional overrides:

## 6.1 CategoryStyleOverrides
- per-category color override (within allowed palette bounds)
- per-category icon override
- per-category “badge color”

Important:
- still constrained to luxury-safe colors (no neon)

## 6.2 Export/Import Theme
- Export Theme JSON
- Import Theme JSON
- multiple saved themes

DesignKit needs:
- Codable ThemePreset/Overrides model
- versioning for theme schema

---

# 7) Implementation Notes (Practical)
- Keep tokens in Swift structs (Codable where needed)
- Resolve dynamic colors based on:
  - system appearance (light/dark)
  - override mode
  - selected preset
- Widgets:
  - read theme snapshot from shared storage (App Group) if you want cross-app consistency
  - or allow per-app theme selection for simplicity

---

# 8) Testing
Unit tests:
- theme resolution (system vs light/dark override)
- preset mapping correctness
- token availability (no nil / missing tokens)
- encode/decode theme JSON version

Snapshot tests (optional):
- DKCard
- DKButton
- DKProgressRing

---

# 9) Milestones (Build Order)

Phase 1: Tokens + ThemeManager
- define token structs
- create presets
- theme resolution (system/light/dark)
- persist selection

Phase 2: Components
- DKCard, DKButton, DKProgressRing, DKBadge

Phase 3: Charts
- DKChartStyle helper for consistent Swift Charts

Phase 4: Integration
- wire into one app (Habit Tracker)
- ensure no hard-coded colors remain

Phase 5: Future Hooks
- category overrides model
- export/import (optional)

---

# 10) Success Criteria
- A single theme switch updates the entire app consistently.
- No literal colors in UI code.
- Apps feel like one ecosystem, with unique defaults per app.
- Light mode always feels “cream luxury”, not iOS default white.
- Easy to evolve without refactoring every view.


