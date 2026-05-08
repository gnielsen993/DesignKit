import SwiftUI

// DesignKitConfig — host-app configuration seam.
//
// The five "generic" classics (Forest / Navy / Maroon / Walnut / Stone) ship
// inside DesignKit and are universal across consumers. The "Classic" entry
// itself (id `"classicMuted"`) is the host-app's brand-flavored Classic and
// IS host-overridable — that's the slot in `PresetCatalog.core[0]`.
//
// GameDrawer registers Chrome Diner (cream + diner-red).
// FitnessTracker registers its teal-on-cream identity.
// Sister apps that haven't migrated get the neutral-grey fallback.
//
// Contract (CRITICAL):
//   - Call `DesignKit.configure(classicPreset:)` ONCE in App.init, BEFORE
//     `ThemeManager()` is constructed.
//   - The registered preset's category MUST be `.classic`.
//   - Its id MUST be `"classicMuted"` so storage compat is preserved.
//
// Concurrency: uses `nonisolated(unsafe)` because the storage is set ONCE
// at app launch, before any concurrent reads happen. Not safe to mutate
// after first paint.

public enum DesignKitConfig {
    nonisolated(unsafe) private static var _classicPreset: PresetTheme = DesignKitConfig.fallbackClassic
    nonisolated(unsafe) private static var _showClassicSlot: Bool = true
    nonisolated(unsafe) private static var _firstLaunchDefaultPreset: ThemePreset = .classicMuted

    /// The "Classic" entry shown in the picker — host-app-overridable.
    public static var classicPreset: PresetTheme { _classicPreset }

    /// Whether the picker exposes the "Classic" slot at all. Hosts that
    /// don't have a brand-flavored Classic identity (FitnessTracker etc.)
    /// hide it; the picker then leads with Forest/Navy/Maroon/Walnut/Stone.
    public static var showClassicSlot: Bool { _showClassicSlot }

    /// Preset returned by `UserDefaultsThemeStorage.loadPreset()` when no
    /// value has been saved yet. Pinned per host so first launch lands on
    /// the right brand identity.
    public static var firstLaunchDefaultPreset: ThemePreset { _firstLaunchDefaultPreset }

    /// Register the host app's "Classic" identity. Each app calls this at
    /// launch. Re-calling overwrites. Entry must be `category == .classic`
    /// and `id == "classicMuted"` (preserves storage compat).
    public static func configure(classicPreset preset: PresetTheme) {
        precondition(
            preset.category == .classic,
            "DesignKit.configure(classicPreset:) — preset must have category == .classic"
        )
        precondition(
            preset.id == "classicMuted",
            "DesignKit.configure(classicPreset:) — preset id must be \"classicMuted\" to preserve storage compat"
        )
        _classicPreset = preset
        _showClassicSlot = true
    }

    /// Hide the Classic picker slot entirely and pin the first-launch
    /// default to a different preset. For hosts that don't want a "Classic"
    /// entry at all (FitnessTracker — their identity lives in Forest, the
    /// Classic slot is GameKit/GameDrawer-specific). Call ONCE in App.init
    /// before `ThemeManager()` is constructed.
    public static func disableClassicSlot(firstLaunchDefault: ThemePreset) {
        _showClassicSlot = false
        _firstLaunchDefaultPreset = firstLaunchDefault
    }

    /// Reset to the neutral fallback. Test-only; do not call from app code.
    public static func _resetForTesting() {
        _classicPreset = DesignKitConfig.fallbackClassic
        _showClassicSlot = true
        _firstLaunchDefaultPreset = .classicMuted
    }

    // MARK: - Neutral fallback

    private static let fallbackLight: PresetAnchors = PresetAnchors(
        background: Color(hex: "#F4F4F5"),
        surface: Color(hex: "#FFFFFF"),
        accent: Color(hex: "#475569"),
        textPrimary: Color(hex: "#0F172A"),
        gameNumberPalette: PresetTheme.classicGameNumberPalette
    )

    private static let fallbackDark: PresetAnchors = PresetAnchors(
        background: Color(hex: "#0A0A0A"),
        surface: Color(hex: "#141416"),
        accent: Color(hex: "#94A3B8"),
        textPrimary: Color(hex: "#F4F4F5"),
        gameNumberPalette: PresetTheme.classicGameNumberPalette
    )

    /// Single neutral grey "Classic" used when host has not registered.
    /// Reuses the Wong-safe game-number palette so Minesweeper-style consumers
    /// stay legible. Id `"classicMuted"` preserves storage compat.
    static let fallbackClassic: PresetTheme = PresetTheme(
        id: "classicMuted",
        displayName: "Classic",
        category: .classic,
        light: fallbackLight,
        dark: fallbackDark
    )
}

/// Top-level convenience so host apps write `DesignKit.configure(...)` rather
/// than `DesignKitConfig.configure(...)`.
///
/// Note: declaring this enum with the same name as the module shadows the
/// module name for member access — `DesignKit.ThemeManager` no longer
/// resolves to the module's `ThemeManager` class. Consumers that need to
/// disambiguate from a same-named local type must use `DKThemeManager`
/// (defined below) or define a local typealias.
public enum DesignKit {
    public static func configure(classicPreset preset: PresetTheme) {
        DesignKitConfig.configure(classicPreset: preset)
    }

    /// Hide the Classic picker slot and pin first-launch default to a
    /// different preset. For hosts that don't want a "Classic" entry at all.
    public static func disableClassicSlot(firstLaunchDefault: ThemePreset) {
        DesignKitConfig.disableClassicSlot(firstLaunchDefault: firstLaunchDefault)
    }
}

/// Disambiguating alias for consumers that define a local `ThemeManager`
/// (e.g. a wrapper that republishes for SwiftUI). Pre-9d30bab they wrote
/// `DesignKit.ThemeManager`; the convenience enum above now shadows that
/// path. Use `DKThemeManager` instead.
public typealias DKThemeManager = ThemeManager
