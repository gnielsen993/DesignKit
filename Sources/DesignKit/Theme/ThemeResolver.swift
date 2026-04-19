import SwiftUI

public enum ThemeResolver {
    public static func resolve(
        preset: ThemePreset,
        scheme: ColorScheme,
        overrides: ThemeOverrides? = nil
    ) -> Theme {
        let baseColors = Palette.colors(for: preset, scheme: scheme)
        let baseCharts = Palette.charts(for: preset)

        let resolvedColors = overrides?.colors?.applying(to: baseColors) ?? baseColors
        let resolvedCharts = overrides?.charts?.applying(to: baseCharts) ?? baseCharts

        return Theme(
            colors: resolvedColors,
            typography: overrides?.typography ?? TypographyTokens(),
            spacing: overrides?.spacing ?? SpacingTokens(),
            radii: overrides?.radii ?? RadiusTokens(),
            motion: overrides?.motion ?? MotionTokens(),
            charts: resolvedCharts
        )
    }
}
