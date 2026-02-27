import SwiftUI

public enum Palette {
    public static func colors(for preset: ThemePreset, scheme: ColorScheme) -> ThemeColors {
        switch scheme {
        case .dark:
            let accent = darkAccent(for: preset)
            return ThemeColors(
                background: Color(hex: "#0B0E14"),
                surface: Color(hex: "#111827"),
                surfaceElevated: Color(hex: "#1F2937"),
                border: Color.white.opacity(0.12),
                textPrimary: Color(hex: "#F9FAFB"),
                textSecondary: Color(hex: "#D1D5DB"),
                textTertiary: Color(hex: "#9CA3AF"),
                accentPrimary: accent,
                accentSecondary: accent.opacity(0.78),
                highlight: accent.opacity(0.20),
                success: Color(hex: "#22C55E"),
                warning: Color(hex: "#F59E0B"),
                danger: Color(hex: "#EF4444"),
                fillPressed: Color.white.opacity(0.07),
                fillSelected: accent.opacity(0.24),
                fillDisabled: Color.white.opacity(0.14)
            )
        default:
            let accent = lightAccent(for: preset)
            return ThemeColors(
                background: Color(hex: "#F8FAFC"),
                surface: Color(hex: "#FFFFFF"),
                surfaceElevated: Color(hex: "#FFFFFF"),
                border: Color(hex: "#E2E8F0"),
                textPrimary: Color(hex: "#0F172A"),
                textSecondary: Color(hex: "#334155"),
                textTertiary: Color(hex: "#64748B"),
                accentPrimary: accent,
                accentSecondary: accent.opacity(0.82),
                highlight: accent.opacity(0.12),
                success: Color(hex: "#16A34A"),
                warning: Color(hex: "#D97706"),
                danger: Color(hex: "#DC2626"),
                fillPressed: Color.black.opacity(0.05),
                fillSelected: accent.opacity(0.16),
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
        case .forest: Color(hex: "#0F766E")
        case .navy: Color(hex: "#2563EB")
        case .maroon: Color(hex: "#BE123C")
        case .walnut: Color(hex: "#B45309")
        case .stone: Color(hex: "#475569")
        }
    }

    private static func darkAccent(for preset: ThemePreset) -> Color {
        switch preset {
        case .forest: Color(hex: "#14B8A6")
        case .navy: Color(hex: "#60A5FA")
        case .maroon: Color(hex: "#FB7185")
        case .walnut: Color(hex: "#F59E0B")
        case .stone: Color(hex: "#94A3B8")
        }
    }
}
