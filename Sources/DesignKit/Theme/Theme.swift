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
