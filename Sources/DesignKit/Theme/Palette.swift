import SwiftUI

public enum Palette {
    public static func colors(for preset: ThemePreset, scheme: ColorScheme) -> ThemeColors {
        let theme = PresetCatalog.theme(for: preset)
        return ColorDerivation.colors(from: theme.anchors(for: scheme), scheme: scheme)
    }

    public static func charts(for preset: ThemePreset) -> ChartTokens {
        charts(for: preset, scheme: .light)
    }

    public static func charts(for preset: ThemePreset, scheme: ColorScheme) -> ChartTokens {
        let theme = PresetCatalog.theme(for: preset)
        return ColorDerivation.charts(from: theme.anchors(for: scheme))
    }
}
