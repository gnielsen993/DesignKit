import SwiftUI

public enum ThemeResolver {
    public static func resolve(
        preset: ThemePreset,
        scheme: ColorScheme,
        overrides: ThemeOverrides? = nil
    ) -> Theme {
        let baseColors = Palette.colors(for: preset, scheme: scheme)
        let resolvedColors = overrides?.colors?.applying(to: baseColors) ?? baseColors

        // Chart palette follows the resolved accent. When the user has overridden
        // accent (custom mode), derive a fresh chart palette from the new accent
        // instead of keeping the base preset's hardcoded customChartColors — those
        // were tuned for the preset's original accent and visually conflict once
        // the accent is replaced.
        let baseCharts: ChartTokens
        if overrides?.colors?.accentPrimary != nil {
            let derivedAnchors = PresetAnchors(
                background: resolvedColors.background,
                surface: resolvedColors.surface,
                accent: resolvedColors.accentPrimary,
                textPrimary: resolvedColors.textPrimary,
                customChartColors: nil
            )
            baseCharts = ColorDerivation.charts(from: derivedAnchors)
        } else {
            baseCharts = Palette.charts(for: preset)
        }
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
