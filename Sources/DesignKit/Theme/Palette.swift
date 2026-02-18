import SwiftUI

public enum Palette {
    public static func colors(for preset: ThemePreset, scheme: ColorScheme) -> ThemeColors {
        switch scheme {
        case .dark:
            let accent = darkAccent(for: preset)
            return ThemeColors(
                background: Color(hex: "#191B1C"),
                surface: Color(hex: "#222527"),
                surfaceElevated: Color(hex: "#2A2E31"),
                border: Color.white.opacity(0.10),
                textPrimary: Color(hex: "#F1EFE8"),
                textSecondary: Color(hex: "#C4C0B3"),
                textTertiary: Color(hex: "#9A968B"),
                accentPrimary: accent,
                accentSecondary: accent.opacity(0.75),
                highlight: accent.opacity(0.18),
                success: Color(hex: "#6BA97E"),
                warning: Color(hex: "#B99252"),
                danger: Color(hex: "#A15E63"),
                fillPressed: Color.white.opacity(0.06),
                fillSelected: accent.opacity(0.20),
                fillDisabled: Color.white.opacity(0.12)
            )
        default:
            let accent = lightAccent(for: preset)
            return ThemeColors(
                background: Color(hex: "#F6F1E7"),
                surface: Color(hex: "#EFE7D9"),
                surfaceElevated: Color(hex: "#F8F3EA"),
                border: Color.black.opacity(0.08),
                textPrimary: Color(hex: "#22201B"),
                textSecondary: Color(hex: "#524D41"),
                textTertiary: Color(hex: "#7A7364"),
                accentPrimary: accent,
                accentSecondary: accent.opacity(0.75),
                highlight: accent.opacity(0.12),
                success: Color(hex: "#5D8D6D"),
                warning: Color(hex: "#A57E45"),
                danger: Color(hex: "#8F4A52"),
                fillPressed: Color.black.opacity(0.04),
                fillSelected: accent.opacity(0.15),
                fillDisabled: Color.black.opacity(0.10)
            )
        }
    }

    public static func charts(for preset: ThemePreset) -> ChartTokens {
        switch preset {
        case .forest:
            return tokens(base: ["#2C5B45", "#4A7E63", "#7D9E64", "#8B6A4C", "#4B6670", "#6E7F86"])
        case .navy:
            return tokens(base: ["#1F3A5F", "#335C8E", "#587EA8", "#6D7381", "#4B5A66", "#8C9AA9"])
        case .maroon:
            return tokens(base: ["#5A232D", "#7A3541", "#9E5760", "#8A6A5D", "#5E6C7A", "#A0858C"])
        case .walnut:
            return tokens(base: ["#5A4635", "#7A5D45", "#9A7A5D", "#7D8A67", "#5E6D59", "#9B9C86"])
        case .stone:
            return tokens(base: ["#45525C", "#62707B", "#7F8F99", "#6E6B65", "#4E565C", "#97A0A8"])
        }
    }

    private static func tokens(base: [String]) -> ChartTokens {
        ChartTokens(
            chart1: Color(hex: base[0]),
            chart2: Color(hex: base[1]),
            chart3: Color(hex: base[2]),
            chart4: Color(hex: base[3]),
            chart5: Color(hex: base[4]),
            chart6: Color(hex: base[5]),
            gridlineOpacity: 0.20,
            axisLabelOpacity: 0.70
        )
    }

    private static func lightAccent(for preset: ThemePreset) -> Color {
        switch preset {
        case .forest: Color(hex: "#2E5A46")
        case .navy: Color(hex: "#294A74")
        case .maroon: Color(hex: "#6B2A36")
        case .walnut: Color(hex: "#6A4E3A")
        case .stone: Color(hex: "#4E626F")
        }
    }

    private static func darkAccent(for preset: ThemePreset) -> Color {
        switch preset {
        case .forest: Color(hex: "#6FA986")
        case .navy: Color(hex: "#6E93C1")
        case .maroon: Color(hex: "#BC7E8B")
        case .walnut: Color(hex: "#B08E6B")
        case .stone: Color(hex: "#95AAB5")
        }
    }
}
