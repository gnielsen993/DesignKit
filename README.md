# DesignKit

A Swift Package that gives SwiftUI apps a shared design language — tokens
(colors, typography, spacing, radii, motion), themeable components
(`DKCard`, `DKButton`, `DKThemePicker`, …), and a preset theme system
that supports user customization + saved named themes out of the box.

Built for the HabitTracker / FitnessTracker / PantryPlanner ecosystem,
but usable in any SwiftUI app.

---

## Requirements

- iOS 17+ / macOS 14+
- Swift 6.0
- SwiftUI

---

## Install

### Option A — Swift Package Manager (local path)

In your app's `Package.swift` or Xcode project:

```swift
.package(path: "../DesignKit")
```

### Option B — Git URL

```swift
.package(url: "https://github.com/your-org/DesignKit.git", from: "1.0.0")
```

Then add `DesignKit` to your app target's dependencies.

---

## Quickstart (5 lines)

### 1. Create a `ThemeManager` in your `App`

```swift
import SwiftUI
import DesignKit

@main
struct MyApp: App {
    @StateObject private var themeManager = DesignKit.ThemeManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(themeManager)
                .preferredColorScheme(preferredScheme)
        }
    }

    private var preferredScheme: ColorScheme? {
        switch themeManager.mode {
        case .system: nil
        case .light:  .light
        case .dark:   .dark
        }
    }
}
```

That's everything the app shell needs.

### 2. Read the theme in any view

```swift
struct RootView: View {
    @EnvironmentObject private var themeManager: DesignKit.ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var theme: Theme { themeManager.theme(using: colorScheme) }

    var body: some View {
        VStack(spacing: theme.spacing.m) {
            Text("Hello")
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.textPrimary)

            DKButton("Continue", theme: theme) { }
        }
        .padding(theme.spacing.l)
        .background(theme.colors.background)
    }
}
```

**Never hardcode colors.** Every color goes through `theme.colors.X`.

### 3. Let users change the theme

Drop the picker in your settings screen:

```swift
DKThemePicker(
    themeManager: themeManager,
    theme: theme,
    scheme: themeManager.resolvedScheme(using: colorScheme)
)
```

Done. Users get 34 preset themes across 6 categories, a Custom tab, and
can save named custom themes that persist across sessions.

---

## Theming model

There are three layers that combine into the final `Theme`:

| Layer       | What it is                                 | Stored where                    |
|-------------|--------------------------------------------|---------------------------------|
| **mode**    | `system` / `light` / `dark`                | UserDefaults                    |
| **preset**  | One of 34 built-in `ThemePreset` cases     | UserDefaults                    |
| **overrides** | Per-anchor color overrides (optional)    | UserDefaults (JSON)             |
| *saved customs* | Named snapshots of (preset + overrides) | UserDefaults (JSON array)       |

`ThemeManager.theme(using: colorScheme)` resolves these into a `Theme`
struct with fully-derived `ThemeColors`, `ChartTokens`, typography, etc.

### The 6 preset categories

- **Classic** — Forest, Navy, Maroon, Walnut, Stone (5)
- **Sweet** — Bubblegum, Sakura, Rose Gold, Lavender, Coral, Rose Dawn (6)
- **Bright** — Barbie, Lemonade, Mint Chip, Poolside (4) — saturated backgrounds
- **Soft** — Cream, Paper, Sand, Sage, Serika, Matcha, Arctic (7)
- **Moody** — Charcoal, Nord, Dracula, Gruvbox, Forest Night, Midnight, Oxblood (7)
- **Loud** — Ghost Orchid, Voltage, Frostlime, Vaporwave, Ember (5)

---

## Using tokens

`Theme` exposes:

```swift
theme.colors.background
theme.colors.surface
theme.colors.surfaceElevated
theme.colors.border
theme.colors.textPrimary
theme.colors.textSecondary
theme.colors.textTertiary
theme.colors.accentPrimary
theme.colors.accentSecondary
theme.colors.highlight
theme.colors.success / .warning / .danger
theme.colors.fillPressed / .fillSelected / .fillDisabled

theme.typography.title / .headline / .body / .caption / .titleLarge
theme.spacing.xs / .s / .m / .l / .xl / .xxl
theme.radii.card / .button / .chip / .sheet
theme.motion.fast / .normal / .slow

theme.charts.chart1 ... chart6
theme.charts.gridlineOpacity
theme.charts.axisLabelOpacity
```

Always read from `theme.X`. If you find yourself writing `Color(hex:)` or
`Color.red` in app code, stop — add a token to DesignKit instead, or you'll
lose theme responsiveness.

---

## Drop-in components

All components take `theme: Theme` and render entirely from tokens.

```swift
DKCard(theme: theme) {
    Text("Content").foregroundStyle(theme.colors.textPrimary)
}

DKButton("Save", theme: theme) { save() }
DKButton("Cancel", style: .secondary, theme: theme) { dismiss() }

DKProgressRing(progress: 0.65, label: "Coverage", theme: theme)

DKSectionHeader("Workouts", subtitle: "This week", theme: theme)

DKBadge("New", theme: theme)

DKThemePicker(themeManager: themeManager, theme: theme, scheme: scheme)
```

---

## `DKThemePicker` integration patterns

The picker is designed to fit two slots: *forward-facing* (compact) and
*deep-dive* (full gallery). The ecosystem convention is to do both.

### Pattern A — compact inline (main settings)

Show only the 5 core Classic swatches + a link to the full picker.
Keeps Settings from looking like a theme gallery.

```swift
HStack(spacing: theme.spacing.m) {
    ForEach(PresetCatalog.core) { preset in
        Button { themeManager.preset = ThemePreset(rawValue: preset.id)!
                themeManager.resetOverrides() } label: {
            Circle()
                .fill(preset.anchors(for: colorScheme).accent)
                .frame(width: 32, height: 32)
        }
    }
}

NavigationLink("More themes & custom colors") {
    ThemeExplorerView()
}
```

### Pattern B — full gallery (nav view)

Hosts `DKThemePicker` with the full catalog, uncapped grid, grouped by
category. Add a "Surprise me" randomize button if you want.

```swift
struct ThemeExplorerView: View {
    @EnvironmentObject var themeManager: DesignKit.ThemeManager
    @Environment(\.colorScheme) var colorScheme

    private var theme: Theme { themeManager.theme(using: colorScheme) }

    var body: some View {
        ScrollView {
            DKThemePicker(
                themeManager: themeManager,
                theme: theme,
                scheme: themeManager.resolvedScheme(using: colorScheme),
                catalog: PresetCatalog.all,
                maxGridHeight: nil,    // uncapped — full screen
                grouped: true          // category sections
            )
            .padding(theme.spacing.l)
        }
        .navigationTitle("Themes")
    }
}
```

### Picker parameters

| Parameter        | Default              | Purpose                                 |
|------------------|----------------------|-----------------------------------------|
| `themeManager`   | required             | Source of truth (read & write)          |
| `theme`          | required             | For picker's own chrome styling         |
| `scheme`         | required             | Fallback preview scheme for chips       |
| `catalog`        | `PresetCatalog.all`  | Pass a subset to restrict the gallery   |
| `maxGridHeight`  | `260` pt             | `nil` = uncapped (for full-screen use)  |
| `grouped`        | `true`               | `false` = flat grid, no section headers |

---

## Saved custom themes

Users can tweak the Custom tab (Primary / Background / Surface / Text)
and tap **Save as theme** to name and persist the combo. Saved themes
appear in a **My Themes** section at the top of the Presets tab with
long-press Rename / Delete.

Programmatic API on `ThemeManager`:

```swift
themeManager.saveCurrentAsCustom(name: "My Vibe")   // returns CustomTheme?
themeManager.applyCustomTheme(someCustom)
themeManager.deleteCustomTheme(id: someCustom.id)
themeManager.renameCustomTheme(id: ..., to: "New Name")

themeManager.customThemes                  // [CustomTheme]
themeManager.activeCustomThemeID           // UUID? — non-nil while saved active
```

Per-app storage by default — each app has its own saved library. See
`Plan_EcosystemThemeSharing.md` for the roadmap to share customs across
ecosystem apps via an App Group when the time comes.

---

## Export / import

`ThemeBackupService` round-trips (mode + preset + overrides) through a
versioned JSON document. Wire into a file exporter/importer:

```swift
let service = ThemeBackupService()
let config = ThemeBackupConfiguration(
    mode: themeManager.mode,
    preset: themeManager.preset,
    overrides: themeManager.overrides
)
try service.exportConfiguration(config, to: fileURL)

let imported = try service.importConfiguration(from: fileURL)
themeManager.mode = imported.mode
themeManager.preset = imported.preset
themeManager.overrides = imported.overrides
```

File extension: `.dktheme`. Schema versioned via `ThemeBackupDocument.currentSchemaVersion`.

---

## Extending the catalog

### Adding a new preset

1. Open `Sources/DesignKit/Theme/PresetTheme.swift`
2. Add a new case to `ThemePreset` enum (in `ThemePreset.swift`)
3. Add a new `static let` in the `PresetTheme` extension with 4 anchor
   colors per scheme (background, surface, accent, textPrimary)
4. Append it to `PresetCatalog.all` with a category assignment

Example:

```swift
static let peach = PresetTheme(
    id: "peach",
    displayName: "Peach",
    category: .sweet,
    light: PresetAnchors(
        background: Color(hex: "#FFE4D6"),
        surface:    Color(hex: "#FFF1E8"),
        accent:     Color(hex: "#D97742"),
        textPrimary: Color(hex: "#3A1808")
    ),
    dark: PresetAnchors(
        background: Color(hex: "#1A0D07"),
        surface:    Color(hex: "#26160E"),
        accent:     Color(hex: "#FB923C"),
        textPrimary: Color(hex: "#FFE4D6")
    ),
    preferredScheme: .light
)
```

Everything else (chart colors, borders, fill states) is auto-derived via
`ColorDerivation`. If you want a curated chart palette, pass
`customChartColors:` in the anchors.

### Adding a new component

Put it in `Sources/DesignKit/Components/`. Take `theme: Theme` as a
parameter. Read only from `theme.X` — never reference
`Color.red` / `.blue` / literal hex. That's the only rule.

---

## File tour

```
Sources/DesignKit/
├── Theme/
│   ├── Theme.swift            ← top-level Theme struct
│   ├── ThemeManager.swift     ← @ObservableObject owner (mode/preset/overrides/customs)
│   ├── ThemePreset.swift      ← enum of 34 preset IDs
│   ├── PresetTheme.swift      ← PresetTheme struct + PresetCatalog registry + PresetCategory
│   ├── CustomTheme.swift      ← user-saved theme struct
│   ├── ThemeMode.swift        ← system / light / dark
│   ├── ThemeResolver.swift    ← composes preset + overrides → Theme
│   ├── ThemeOverrides.swift   ← partial overrides types
│   ├── Palette.swift          ← lookup helpers over PresetCatalog
│   ├── ColorDerivation.swift  ← fills remaining tokens from 4 anchors
│   └── Tokens.swift           ← ThemeColors + ChartTokens
├── Typography/TypographyTokens.swift
├── Layout/SpacingTokens.swift + RadiusTokens.swift
├── Motion/MotionTokens.swift
├── Charts/DKChartStyle.swift
├── Components/
│   ├── DKCard.swift
│   ├── DKButton.swift
│   ├── DKProgressRing.swift
│   ├── DKBadge.swift
│   ├── DKSectionHeader.swift
│   └── DKThemePicker.swift    ← the full Presets|Custom picker
├── Storage/
│   ├── ThemeStorage.swift     ← protocol + UserDefaults impl
│   ├── ThemeBackupCodec.swift ← JSON codec for payload types
│   └── ThemeBackupService.swift  ← file-based export/import
└── Utilities/Color+Hex.swift
```

---

## Gotchas / FAQ

**Q: Can I use `ThemeManager` from a widget extension?**
Yes, but widgets have their own process. If you want saved themes / mode
to be reflected in widgets, all targets must share an App Group (see
`Plan_EcosystemThemeSharing.md`).

**Q: Why does a preset auto-switch light/dark when I tap it?**
Presets with a `preferredScheme` (e.g. Dracula=dark, Barbie=light) will
force the mode on selection so the preview matches the pick. Override
with `themeManager.mode = .system` afterward if you don't want that.

**Q: I want a "colorful" UI element that always reads as accent, even in
overrides.**
Use `theme.colors.accentPrimary`. Overrides stack on top of preset so
accent-using components automatically pick up the user's customization.

**Q: How do I test that my view renders correctly across all presets?**
Iterate `PresetCatalog.all` in previews:

```swift
#Preview {
    ForEach(PresetCatalog.all, id: \.id) { preset in
        let theme = Theme.resolve(
            preset: ThemePreset(rawValue: preset.id)!,
            scheme: .light
        )
        MyView().environment(\.dkTheme, theme) // or pass directly
    }
}
```

**Q: What if a user deletes the app — do saved themes come back on reinstall?**
No. Current storage is UserDefaults (per-app, lost on uninstall). iCloud
sync is planned — see `Plan_EcosystemThemeSharing.md` §6.

**Q: Can I disable the "Custom" tab?**
Not via a parameter currently. If you need to, pass your own catalog
subset and subclass/wrap `DKThemePicker` — or open a PR to add a
`tabs:` parameter.

---

## License

TBD — set by the project owner.

---

## Related docs

- `Plan.md` — original DesignKit plan
- `Plan_EcosystemThemeSharing.md` — deferred plan for cross-app theme sharing
- `Architecture_Constitution.md` — ecosystem-wide architectural rules
- `CLAUDE.md` — AI agent working rules for this repo (safe to ignore if human)
- `AGENTS.md` — same, older variant
