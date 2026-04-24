import SwiftUI
import Foundation

/// A user-saved named theme — the result of tweaking overrides on a base
/// preset and hitting Save. Persists across sessions so your "my pink one"
/// doesn't disappear when you tap a different preset.
public struct CustomTheme: Identifiable {
    public let id: UUID
    public var name: String
    public var basePresetID: String
    public var overrides: ThemeOverrides
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        basePresetID: String,
        overrides: ThemeOverrides,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.basePresetID = basePresetID
        self.overrides = overrides
        self.createdAt = createdAt
    }

    /// Resolves this custom theme into a virtual `PresetTheme` so it renders
    /// uniformly alongside catalog presets in pickers.
    public func asPresetTheme() -> PresetTheme {
        let basePreset = ThemePreset(rawValue: basePresetID) ?? .forest
        let baseTheme = PresetCatalog.theme(for: basePreset)

        let light = applied(to: baseTheme.light)
        let dark = applied(to: baseTheme.dark)

        return PresetTheme(
            id: "custom:\(id.uuidString)",
            displayName: name,
            category: .mine,
            light: light,
            dark: dark,
            preferredScheme: baseTheme.preferredScheme
        )
    }

    private func applied(to base: PresetAnchors) -> PresetAnchors {
        let c = overrides.colors
        return PresetAnchors(
            background: c?.background ?? base.background,
            surface: c?.surface ?? base.surface,
            accent: c?.accentPrimary ?? base.accent,
            textPrimary: c?.textPrimary ?? base.textPrimary,
            customChartColors: base.customChartColors
        )
    }
}
