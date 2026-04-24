import SwiftUI

public struct PresetAnchors: Sendable {
    public let background: Color
    public let surface: Color
    public let accent: Color
    public let textPrimary: Color
    public let customChartColors: [Color]?

    public init(
        background: Color,
        surface: Color,
        accent: Color,
        textPrimary: Color,
        customChartColors: [Color]? = nil
    ) {
        self.background = background
        self.surface = surface
        self.accent = accent
        self.textPrimary = textPrimary
        self.customChartColors = customChartColors
    }
}

public struct PresetTheme: Identifiable, Sendable {
    public let id: String
    public let displayName: String
    public let light: PresetAnchors
    public let dark: PresetAnchors
    public let preferredScheme: ColorScheme?

    public init(
        id: String,
        displayName: String,
        light: PresetAnchors,
        dark: PresetAnchors,
        preferredScheme: ColorScheme? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.light = light
        self.dark = dark
        self.preferredScheme = preferredScheme
    }

    public func anchors(for scheme: ColorScheme) -> PresetAnchors {
        scheme == .dark ? dark : light
    }

    /// Three-dot swatch shown in the picker chip (accent, surface, textPrimary).
    public func swatch(for scheme: ColorScheme) -> (Color, Color, Color) {
        let a = anchors(for: scheme)
        return (a.accent, a.surface, a.textPrimary)
    }
}

public enum PresetCatalog {
    /// The five Balanced Luxury presets — forward-facing defaults for apps that
    /// want a compact picker. Use `.all` to expose the full catalog in an
    /// "explore more" surface.
    public static let core: [PresetTheme] = [
        .forestEntry,
        .navyEntry,
        .maroonEntry,
        .walnutEntry,
        .stoneEntry
    ]

    public static let all: [PresetTheme] = core + [
        // Light-leaning
        .cream,
        .paper,
        .sand,
        .roseDawn,
        .sage,
        .serika,
        .matcha,
        .arctic,
        // Feminine / warm
        .bubblegum,
        .sakura,
        .roseGold,
        .lavender,
        .coral,
        // Dark-leaning
        .charcoal,
        .nord,
        .dracula,
        .gruvbox,
        .forestNight,
        .midnight,
        .oxblood,
        .ember,
        // Showcase (out-there combos)
        .ghostOrchid,
        .voltage,
        .frostlime,
        .vaporwave
    ]

    public static func theme(for preset: ThemePreset) -> PresetTheme {
        all.first(where: { $0.id == preset.rawValue }) ?? .forestEntry
    }

    public static func isCore(_ preset: ThemePreset) -> Bool {
        core.contains(where: { $0.id == preset.rawValue })
    }
}

private extension PresetTheme {
    // Shared base anchors for the original 5, matching the prior Palette output.
    static let legacyLightBG = Color(hex: "#F8FAFC")
    static let legacyLightSurface = Color(hex: "#FFFFFF")
    static let legacyLightText = Color(hex: "#0F172A")
    static let legacyDarkBG = Color(hex: "#090909")
    static let legacyDarkSurface = Color(hex: "#131313")
    static let legacyDarkText = Color(hex: "#F9FAFB")

    static let forestEntry = PresetTheme(
        id: "forest",
        displayName: "Forest",
        light: PresetAnchors(
            background: legacyLightBG, surface: legacyLightSurface,
            accent: Color(hex: "#0F766E"), textPrimary: legacyLightText,
            customChartColors: ["#2C5B45", "#4A7E63", "#7D9E64", "#8B6A4C", "#4B6670", "#6E7F86"].map(Color.init(hex:))
        ),
        dark: PresetAnchors(
            background: legacyDarkBG, surface: legacyDarkSurface,
            accent: Color(hex: "#14B8A6"), textPrimary: legacyDarkText,
            customChartColors: ["#2C5B45", "#4A7E63", "#7D9E64", "#8B6A4C", "#4B6670", "#6E7F86"].map(Color.init(hex:))
        )
    )

    static let navyEntry = PresetTheme(
        id: "navy",
        displayName: "Navy",
        light: PresetAnchors(
            background: legacyLightBG, surface: legacyLightSurface,
            accent: Color(hex: "#2563EB"), textPrimary: legacyLightText,
            customChartColors: ["#1F3A5F", "#335C8E", "#587EA8", "#6D7381", "#4B5A66", "#8C9AA9"].map(Color.init(hex:))
        ),
        dark: PresetAnchors(
            background: legacyDarkBG, surface: legacyDarkSurface,
            accent: Color(hex: "#60A5FA"), textPrimary: legacyDarkText,
            customChartColors: ["#1F3A5F", "#335C8E", "#587EA8", "#6D7381", "#4B5A66", "#8C9AA9"].map(Color.init(hex:))
        )
    )

    static let maroonEntry = PresetTheme(
        id: "maroon",
        displayName: "Maroon",
        light: PresetAnchors(
            background: legacyLightBG, surface: legacyLightSurface,
            accent: Color(hex: "#BE123C"), textPrimary: legacyLightText,
            customChartColors: ["#5A232D", "#7A3541", "#9E5760", "#8A6A5D", "#5E6C7A", "#A0858C"].map(Color.init(hex:))
        ),
        dark: PresetAnchors(
            background: legacyDarkBG, surface: legacyDarkSurface,
            accent: Color(hex: "#FB7185"), textPrimary: legacyDarkText,
            customChartColors: ["#5A232D", "#7A3541", "#9E5760", "#8A6A5D", "#5E6C7A", "#A0858C"].map(Color.init(hex:))
        )
    )

    static let walnutEntry = PresetTheme(
        id: "walnut",
        displayName: "Walnut",
        light: PresetAnchors(
            background: legacyLightBG, surface: legacyLightSurface,
            accent: Color(hex: "#B45309"), textPrimary: legacyLightText,
            customChartColors: ["#5A4635", "#7A5D45", "#9A7A5D", "#7D8A67", "#5E6D59", "#9B9C86"].map(Color.init(hex:))
        ),
        dark: PresetAnchors(
            background: legacyDarkBG, surface: legacyDarkSurface,
            accent: Color(hex: "#F59E0B"), textPrimary: legacyDarkText,
            customChartColors: ["#5A4635", "#7A5D45", "#9A7A5D", "#7D8A67", "#5E6D59", "#9B9C86"].map(Color.init(hex:))
        )
    )

    static let stoneEntry = PresetTheme(
        id: "stone",
        displayName: "Stone",
        light: PresetAnchors(
            background: legacyLightBG, surface: legacyLightSurface,
            accent: Color(hex: "#475569"), textPrimary: legacyLightText,
            customChartColors: ["#45525C", "#62707B", "#7F8F99", "#6E6B65", "#4E565C", "#97A0A8"].map(Color.init(hex:))
        ),
        dark: PresetAnchors(
            background: legacyDarkBG, surface: legacyDarkSurface,
            accent: Color(hex: "#94A3B8"), textPrimary: legacyDarkText,
            customChartColors: ["#45525C", "#62707B", "#7F8F99", "#6E6B65", "#4E565C", "#97A0A8"].map(Color.init(hex:))
        )
    )

    // MARK: - New curated presets

    static let cream = PresetTheme(
        id: "cream",
        displayName: "Cream",
        light: PresetAnchors(
            background: Color(hex: "#F4ECD8"),
            surface: Color(hex: "#FAF3E0"),
            accent: Color(hex: "#8C5A2B"),
            textPrimary: Color(hex: "#2B1D0E")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#1E1A14"),
            surface: Color(hex: "#2A241B"),
            accent: Color(hex: "#D9A771"),
            textPrimary: Color(hex: "#F4ECD8")
        ),
        preferredScheme: .light
    )

    static let paper = PresetTheme(
        id: "paper",
        displayName: "Paper",
        light: PresetAnchors(
            background: Color(hex: "#FFFFFF"),
            surface: Color(hex: "#F7F7F7"),
            accent: Color(hex: "#111111"),
            textPrimary: Color(hex: "#111111")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#0B0B0B"),
            surface: Color(hex: "#161616"),
            accent: Color(hex: "#FFFFFF"),
            textPrimary: Color(hex: "#F2F2F2")
        )
    )

    static let sand = PresetTheme(
        id: "sand",
        displayName: "Sand",
        light: PresetAnchors(
            background: Color(hex: "#EDE3D2"),
            surface: Color(hex: "#F6EEDF"),
            accent: Color(hex: "#B25B3D"),
            textPrimary: Color(hex: "#2F231A")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#201913"),
            surface: Color(hex: "#2B221B"),
            accent: Color(hex: "#E0855F"),
            textPrimary: Color(hex: "#EDE3D2")
        ),
        preferredScheme: .light
    )

    static let roseDawn = PresetTheme(
        id: "roseDawn",
        displayName: "Rose Dawn",
        light: PresetAnchors(
            background: Color(hex: "#FAF4ED"),
            surface: Color(hex: "#FFFAF3"),
            accent: Color(hex: "#B4637A"),
            textPrimary: Color(hex: "#575279")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#191724"),
            surface: Color(hex: "#1F1D2E"),
            accent: Color(hex: "#EB6F92"),
            textPrimary: Color(hex: "#E0DEF4")
        ),
        preferredScheme: .light
    )

    static let sage = PresetTheme(
        id: "sage",
        displayName: "Sage",
        light: PresetAnchors(
            background: Color(hex: "#E7EBE3"),
            surface: Color(hex: "#F2F4EE"),
            accent: Color(hex: "#516B52"),
            textPrimary: Color(hex: "#1F2A22")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#131814"),
            surface: Color(hex: "#1C221D"),
            accent: Color(hex: "#8FB08B"),
            textPrimary: Color(hex: "#E7EBE3")
        )
    )

    static let serika = PresetTheme(
        id: "serika",
        displayName: "Serika",
        light: PresetAnchors(
            background: Color(hex: "#E1E1E3"),
            surface: Color(hex: "#F4F4F6"),
            accent: Color(hex: "#E2B714"),
            textPrimary: Color(hex: "#323437")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#323437"),
            surface: Color(hex: "#3A3D40"),
            accent: Color(hex: "#E2B714"),
            textPrimary: Color(hex: "#D1D0C5")
        )
    )

    static let charcoal = PresetTheme(
        id: "charcoal",
        displayName: "Charcoal",
        light: PresetAnchors(
            background: Color(hex: "#F3F4F6"),
            surface: Color(hex: "#FFFFFF"),
            accent: Color(hex: "#3F3F46"),
            textPrimary: Color(hex: "#18181B")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#101012"),
            surface: Color(hex: "#18181B"),
            accent: Color(hex: "#E4E4E7"),
            textPrimary: Color(hex: "#FAFAFA")
        )
    )

    static let nord = PresetTheme(
        id: "nord",
        displayName: "Nord",
        light: PresetAnchors(
            background: Color(hex: "#ECEFF4"),
            surface: Color(hex: "#E5E9F0"),
            accent: Color(hex: "#5E81AC"),
            textPrimary: Color(hex: "#2E3440")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#2E3440"),
            surface: Color(hex: "#3B4252"),
            accent: Color(hex: "#88C0D0"),
            textPrimary: Color(hex: "#ECEFF4")
        ),
        preferredScheme: .dark
    )

    static let dracula = PresetTheme(
        id: "dracula",
        displayName: "Dracula",
        light: PresetAnchors(
            background: Color(hex: "#F5F3FB"),
            surface: Color(hex: "#FFFFFF"),
            accent: Color(hex: "#6B3FA0"),
            textPrimary: Color(hex: "#282A36")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#282A36"),
            surface: Color(hex: "#343746"),
            accent: Color(hex: "#BD93F9"),
            textPrimary: Color(hex: "#F8F8F2")
        ),
        preferredScheme: .dark
    )

    static let gruvbox = PresetTheme(
        id: "gruvbox",
        displayName: "Gruvbox",
        light: PresetAnchors(
            background: Color(hex: "#FBF1C7"),
            surface: Color(hex: "#F2E5BC"),
            accent: Color(hex: "#D65D0E"),
            textPrimary: Color(hex: "#3C3836")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#282828"),
            surface: Color(hex: "#32302F"),
            accent: Color(hex: "#FE8019"),
            textPrimary: Color(hex: "#EBDBB2")
        )
    )

    static let forestNight = PresetTheme(
        id: "forestNight",
        displayName: "Forest Night",
        light: PresetAnchors(
            background: Color(hex: "#E6EDE3"),
            surface: Color(hex: "#F2F6EF"),
            accent: Color(hex: "#2F5D3A"),
            textPrimary: Color(hex: "#1A2B1F")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#0E1712"),
            surface: Color(hex: "#152018"),
            accent: Color(hex: "#68B37B"),
            textPrimary: Color(hex: "#E6EDE3")
        ),
        preferredScheme: .dark
    )

    static let midnight = PresetTheme(
        id: "midnight",
        displayName: "Midnight",
        light: PresetAnchors(
            background: Color(hex: "#EAF0F6"),
            surface: Color(hex: "#F3F7FB"),
            accent: Color(hex: "#1E3A8A"),
            textPrimary: Color(hex: "#0F172A")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#060A14"),
            surface: Color(hex: "#0E1525"),
            accent: Color(hex: "#38BDF8"),
            textPrimary: Color(hex: "#E2E8F0")
        ),
        preferredScheme: .dark
    )

    static let oxblood = PresetTheme(
        id: "oxblood",
        displayName: "Oxblood",
        light: PresetAnchors(
            background: Color(hex: "#F6ECEC"),
            surface: Color(hex: "#FBF4F4"),
            accent: Color(hex: "#7A1E2B"),
            textPrimary: Color(hex: "#2A1215")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#120909"),
            surface: Color(hex: "#1B1010"),
            accent: Color(hex: "#C94F5F"),
            textPrimary: Color(hex: "#F6E4E4")
        ),
        preferredScheme: .dark
    )

    // MARK: - Showcase presets (intentionally loud — demonstrate DesignKit range)

    /// Hot magenta/orchid on a deep plum-black. Dark, dramatic, very not-luxury.
    static let ghostOrchid = PresetTheme(
        id: "ghostOrchid",
        displayName: "Ghost Orchid",
        light: PresetAnchors(
            background: Color(hex: "#F7EEF6"),
            surface: Color(hex: "#FDF6FC"),
            accent: Color(hex: "#C026D3"),
            textPrimary: Color(hex: "#2E0A30")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#120A1A"),
            surface: Color(hex: "#1C1028"),
            accent: Color(hex: "#E879F9"),
            textPrimary: Color(hex: "#F3E8FF")
        ),
        preferredScheme: .dark
    )

    /// Acid-yellow electric accent on violet-black. Pure energy.
    static let voltage = PresetTheme(
        id: "voltage",
        displayName: "Voltage",
        light: PresetAnchors(
            background: Color(hex: "#F4F0FA"),
            surface: Color(hex: "#FBF7FF"),
            accent: Color(hex: "#7C3AED"),
            textPrimary: Color(hex: "#1B0A3E")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#0B0820"),
            surface: Color(hex: "#14102D"),
            accent: Color(hex: "#FACC15"),
            textPrimary: Color(hex: "#EDE9FE")
        ),
        preferredScheme: .dark
    )

    /// Mint/lime on near-black. DesignKit's answer to MT's frozen-llama vibe.
    static let frostlime = PresetTheme(
        id: "frostlime",
        displayName: "Frostlime",
        light: PresetAnchors(
            background: Color(hex: "#EFFBF4"),
            surface: Color(hex: "#F7FEFA"),
            accent: Color(hex: "#059669"),
            textPrimary: Color(hex: "#052E1B")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#06110C"),
            surface: Color(hex: "#0B1B14"),
            accent: Color(hex: "#86EFAC"),
            textPrimary: Color(hex: "#D1FAE5")
        ),
        preferredScheme: .dark
    )

    /// Hot pink on pastel cream — loud, playful, and unapologetically light.
    static let bubblegum = PresetTheme(
        id: "bubblegum",
        displayName: "Bubblegum",
        light: PresetAnchors(
            background: Color(hex: "#FFF1F5"),
            surface: Color(hex: "#FFF8FA"),
            accent: Color(hex: "#EC4899"),
            textPrimary: Color(hex: "#500724")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#1A0C12"),
            surface: Color(hex: "#25121B"),
            accent: Color(hex: "#F472B6"),
            textPrimary: Color(hex: "#FFE4ED")
        ),
        preferredScheme: .light
    )

    // MARK: - Feminine / warm extensions

    /// Cherry blossom — delicate pink on soft blush.
    static let sakura = PresetTheme(
        id: "sakura",
        displayName: "Sakura",
        light: PresetAnchors(
            background: Color(hex: "#FFF5F7"),
            surface: Color(hex: "#FFFAFB"),
            accent: Color(hex: "#D6587E"),
            textPrimary: Color(hex: "#4A1023")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#1C1015"),
            surface: Color(hex: "#271620"),
            accent: Color(hex: "#F9A8B8"),
            textPrimary: Color(hex: "#FFE6EC")
        ),
        preferredScheme: .light
    )

    /// Rose Gold — luxe metallic pink-gold on warm cream.
    static let roseGold = PresetTheme(
        id: "roseGold",
        displayName: "Rose Gold",
        light: PresetAnchors(
            background: Color(hex: "#FBF0EA"),
            surface: Color(hex: "#FFF7F3"),
            accent: Color(hex: "#B76E79"),
            textPrimary: Color(hex: "#3E1F1A")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#1A100E"),
            surface: Color(hex: "#261913"),
            accent: Color(hex: "#E8A9A4"),
            textPrimary: Color(hex: "#F6E4DE")
        ),
        preferredScheme: .light
    )

    /// Lavender Mist — soft violet on lilac-white.
    static let lavender = PresetTheme(
        id: "lavender",
        displayName: "Lavender",
        light: PresetAnchors(
            background: Color(hex: "#F4F0FB"),
            surface: Color(hex: "#FBF8FF"),
            accent: Color(hex: "#8B5CF6"),
            textPrimary: Color(hex: "#2E1B4B")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#140F20"),
            surface: Color(hex: "#1D1830"),
            accent: Color(hex: "#C4B5FD"),
            textPrimary: Color(hex: "#EDE9FE")
        ),
        preferredScheme: .light
    )

    /// Coral Reef — warm coral/salmon on peach-cream.
    static let coral = PresetTheme(
        id: "coral",
        displayName: "Coral",
        light: PresetAnchors(
            background: Color(hex: "#FFF2EE"),
            surface: Color(hex: "#FFF8F5"),
            accent: Color(hex: "#F97361"),
            textPrimary: Color(hex: "#4A1A12")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#1A0F0B"),
            surface: Color(hex: "#251612"),
            accent: Color(hex: "#FB9A8A"),
            textPrimary: Color(hex: "#FFE2DA")
        ),
        preferredScheme: .light
    )

    // MARK: - Bold / cool extensions

    /// Ember — glowing orange on deep char. Masculine-bold.
    static let ember = PresetTheme(
        id: "ember",
        displayName: "Ember",
        light: PresetAnchors(
            background: Color(hex: "#FBF2E9"),
            surface: Color(hex: "#FFF8F0"),
            accent: Color(hex: "#D54A13"),
            textPrimary: Color(hex: "#2B1108")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#110907"),
            surface: Color(hex: "#1D0F0A"),
            accent: Color(hex: "#FB923C"),
            textPrimary: Color(hex: "#FEE9D6")
        ),
        preferredScheme: .dark
    )

    /// Arctic — icy cyan on pure snow. Cold, clean, clinical.
    static let arctic = PresetTheme(
        id: "arctic",
        displayName: "Arctic",
        light: PresetAnchors(
            background: Color(hex: "#F0F9FC"),
            surface: Color(hex: "#F9FDFE"),
            accent: Color(hex: "#0891B2"),
            textPrimary: Color(hex: "#082F3A")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#081317"),
            surface: Color(hex: "#0F1D22"),
            accent: Color(hex: "#67E8F9"),
            textPrimary: Color(hex: "#CFFAFE")
        ),
        preferredScheme: .light
    )

    /// Matcha — muted green tea on bone. Calm, grounded, zen.
    static let matcha = PresetTheme(
        id: "matcha",
        displayName: "Matcha",
        light: PresetAnchors(
            background: Color(hex: "#F3F4E9"),
            surface: Color(hex: "#F9FAF1"),
            accent: Color(hex: "#7A8C4C"),
            textPrimary: Color(hex: "#2A2E1A")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#101308"),
            surface: Color(hex: "#191D10"),
            accent: Color(hex: "#B8CB78"),
            textPrimary: Color(hex: "#E7EBDA")
        ),
        preferredScheme: .light
    )

    /// Vaporwave — magenta + cyan on deep violet. Retro showcase.
    static let vaporwave = PresetTheme(
        id: "vaporwave",
        displayName: "Vaporwave",
        light: PresetAnchors(
            background: Color(hex: "#F5EEFB"),
            surface: Color(hex: "#FBF6FF"),
            accent: Color(hex: "#D946EF"),
            textPrimary: Color(hex: "#2A0945")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#10062A"),
            surface: Color(hex: "#1A0B3D"),
            accent: Color(hex: "#F472B6"),
            textPrimary: Color(hex: "#E0F2FE"),
            customChartColors: [
                Color(hex: "#F472B6"), Color(hex: "#38BDF8"), Color(hex: "#A78BFA"),
                Color(hex: "#FB923C"), Color(hex: "#34D399"), Color(hex: "#FBBF24")
            ]
        ),
        preferredScheme: .dark
    )
}
