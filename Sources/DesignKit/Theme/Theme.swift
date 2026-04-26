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
    /// Reads `colors.gameNumberPaletteWongSafe ?? colors.gameNumberPalette` so
    /// presets that opt into the Wong-safe override (D-15) get it transparently.
    /// n < 1 clamps to palette[0]; n > 8 clamps to palette[7]; never traps.
    /// If the resolver hasn't filled a palette yet (transitional state), falls
    /// back to `colors.textPrimary` so callers never crash.
    func gameNumber(_ n: Int) -> Color {
        let palette = colors.gameNumberPaletteWongSafe ?? colors.gameNumberPalette
        guard !palette.isEmpty else { return colors.textPrimary }
        let i = max(0, min(palette.count - 1, n - 1))
        return palette[i]
    }
}
