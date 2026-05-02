import SwiftUI

public struct Theme {
    public let colors: ThemeColors
    public let typography: TypographyTokens
    public let spacing: SpacingTokens
    public let radii: RadiusTokens
    public let motion: MotionTokens
    public let charts: ChartTokens

    public init(
        colors: ThemeColors,
        typography: TypographyTokens = TypographyTokens(),
        spacing: SpacingTokens = SpacingTokens(),
        radii: RadiusTokens = RadiusTokens(),
        motion: MotionTokens = MotionTokens(),
        charts: ChartTokens
    ) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.radii = radii
        self.motion = motion
        self.charts = charts
    }

    public static func resolve(preset: ThemePreset, scheme: ColorScheme) -> Theme {
        ThemeResolver.resolve(preset: preset, scheme: scheme, overrides: nil)
    }

    public static func resolve(
        preset: ThemePreset,
        scheme: ColorScheme,
        overrides: ThemeOverrides?
    ) -> Theme {
        ThemeResolver.resolve(preset: preset, scheme: scheme, overrides: overrides)
    }
}

public extension Theme {
    /// Adjacency-number color for n in 1...8 (THEME-02 + D-13).
    ///
    /// Prefers the preset's aesthetic `gameNumberPalette`; falls back to
    /// `gameNumberPaletteWongSafe` only when the aesthetic palette is empty.
    /// n < 1 clamps to palette[0]; n > 8 clamps to palette[7]; never traps.
    /// If neither palette is filled (transitional state), falls back to
    /// `colors.textPrimary` so callers never crash.
    ///
    /// P7 polish: the original D-15 contract had this resolver ALWAYS prefer
    /// Wong-safe over aesthetic. That broke every dark preset that shipped
    /// Classic as the Wong-safe override — e.g. Dracula on dark anchors used
    /// `#212121` for "4", which is near-invisible on the `#343746` dark slate
    /// surface. The original intent was that Wong-safe would be the runtime
    /// fallback for users with a CVD accessibility flag enabled, but the
    /// resolver wired Wong-safe as the unconditional override. There is no
    /// CVD toggle in Settings (and none planned for v1.0), so the right
    /// behavior is to use the preset's aesthetic palette — which the preset
    /// authors tuned for their surface — and treat Wong-safe as a true
    /// fallback when no aesthetic palette is provided.
    func gameNumber(_ n: Int) -> Color {
        if !colors.gameNumberPalette.isEmpty {
            let palette = colors.gameNumberPalette
            let i = max(0, min(palette.count - 1, n - 1))
            return palette[i]
        }
        if let safe = colors.gameNumberPaletteWongSafe, !safe.isEmpty {
            let i = max(0, min(safe.count - 1, n - 1))
            return safe[i]
        }
        return colors.textPrimary
    }
}
