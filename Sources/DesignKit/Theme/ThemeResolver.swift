import SwiftUI

public enum ThemeResolver {
    public static func resolve(
        preset: ThemePreset,
        scheme: ColorScheme,
        overrides: ThemeOverrides? = nil
    ) -> Theme {
        let baseColors = Palette.colors(for: preset, scheme: scheme)

        // If any of the 4 anchor colors are overridden, re-derive all dependent
        // tokens (textSecondary, textTertiary, border, highlight, accentSecondary,
        // etc.) from the new anchors so the full palette stays coherent. Then
        // apply any explicit per-token overrides on top, which lets callers pin
        // individual derived values if needed.
        let resolvedColors: ThemeColors
        if let co = overrides?.colors,
           co.accentPrimary != nil || co.background != nil || co.surface != nil || co.textPrimary != nil {
            let newAnchors = PresetAnchors(
                background:  co.background    ?? baseColors.background,
                surface:     co.surface       ?? baseColors.surface,
                accent:      co.accentPrimary ?? baseColors.accentPrimary,
                textPrimary: co.textPrimary   ?? baseColors.textPrimary
            )
            let rederived = ColorDerivation.colors(from: newAnchors, scheme: scheme)
            resolvedColors = co.applying(to: rederived)
        } else {
            resolvedColors = overrides?.colors?.applying(to: baseColors) ?? baseColors
        }

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
            charts: resolvedCharts,
            cataloguePalette: CataloguePalette.palette(for: preset.paletteMood)
        )
    }
}
