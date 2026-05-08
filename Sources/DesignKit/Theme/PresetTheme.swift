import SwiftUI

public struct PresetAnchors: Sendable {
    public let background: Color
    public let surface: Color
    public let accent: Color
    public let textPrimary: Color
    public let customChartColors: [Color]?

    /// Per-preset 8-color palette for Minesweeper adjacency numbers 1–8
    /// (THEME-02 + D-14). nil = inherit the Classic (forest) traditional
    /// Minesweeper palette via the resolver fallback.
    public let gameNumberPalette: [Color]?

    /// Optional Wong-safe override used when `gameNumberPalette` fails the
    /// CVD audit on a loud preset (D-15). nil = the default palette is the
    /// Wong-safe palette (Classic) OR no override needed.
    public let gameNumberPaletteWongSafe: [Color]?

    public init(
        background: Color,
        surface: Color,
        accent: Color,
        textPrimary: Color,
        customChartColors: [Color]? = nil,
        gameNumberPalette: [Color]? = nil,
        gameNumberPaletteWongSafe: [Color]? = nil
    ) {
        self.background = background
        self.surface = surface
        self.accent = accent
        self.textPrimary = textPrimary
        self.customChartColors = customChartColors
        self.gameNumberPalette = gameNumberPalette
        self.gameNumberPaletteWongSafe = gameNumberPaletteWongSafe
    }
}

public enum PresetCategory: String, CaseIterable, Sendable {
    case mine
    case classic
    case soft
    case sweet
    case bright
    case moody
    case loud

    public var displayName: String {
        switch self {
        case .mine:    "My Themes"
        case .classic: "Classic"
        case .soft:    "Soft"
        case .sweet:   "Sweet"
        case .bright:  "Bright"
        case .moody:   "Moody"
        case .loud:    "Loud"
        }
    }

    /// Order presets render in the grouped picker.
    public static let displayOrder: [PresetCategory] = [.mine, .classic, .sweet, .bright, .soft, .moody, .loud]
}

public struct PresetTheme: Identifiable, Sendable {
    public let id: String
    public let displayName: String
    public let category: PresetCategory
    public let light: PresetAnchors
    public let dark: PresetAnchors
    public let preferredScheme: ColorScheme?

    public init(
        id: String,
        displayName: String,
        category: PresetCategory,
        light: PresetAnchors,
        dark: PresetAnchors,
        preferredScheme: ColorScheme? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.category = category
        self.light = light
        self.dark = dark
        self.preferredScheme = preferredScheme
    }

    public func anchors(for scheme: ColorScheme) -> PresetAnchors {
        scheme == .dark ? dark : light
    }

    /// Scheme this preset should render as in chip previews. Falls back to
    /// the passed scheme when the preset has no preferred mode.
    public func previewScheme(fallback: ColorScheme) -> ColorScheme {
        preferredScheme ?? fallback
    }

    /// Three-dot swatch shown in legacy chip rendering.
    public func swatch(for scheme: ColorScheme) -> (Color, Color, Color) {
        let a = anchors(for: scheme)
        return (a.accent, a.surface, a.textPrimary)
    }
}

public extension Array where Element == PresetTheme {
    /// Preserves `PresetCategory.displayOrder`. Empty categories omitted.
    func groupedByCategory() -> [(PresetCategory, [PresetTheme])] {
        PresetCategory.displayOrder.compactMap { cat in
            let list = filter { $0.category == cat }
            return list.isEmpty ? nil : (cat, list)
        }
    }
}

public enum PresetCatalog {
    /// The 6-swatch core picker. Position 0 is the host-app's "Classic" —
    /// registered via `DesignKit.configure(classicPreset:)` (defaults to a
    /// neutral grey if the host has not configured). Positions 1–5 are the
    /// universal classics (Forest / Navy / Maroon / Walnut / Stone) shipped
    /// by DesignKit for every consumer. Hosts that don't want a "Classic"
    /// entry at all (FitnessTracker) call
    /// `DesignKit.disableClassicSlot(firstLaunchDefault:)` and the slot is
    /// omitted entirely — the picker leads with Forest.
    public static var core: [PresetTheme] {
        let universal: [PresetTheme] = [
            .forestEntry,
            .navyEntry,
            .maroonEntry,
            .walnutEntry,
            .stoneEntry
        ]
        guard DesignKitConfig.showClassicSlot else { return universal }
        return [DesignKitConfig.classicPreset] + universal
    }

    public static var all: [PresetTheme] { core + nonClassicEntries }

    public static func theme(for preset: ThemePreset) -> PresetTheme {
        all.first(where: { $0.id == preset.rawValue }) ?? .forestEntry
    }

    public static func isCore(_ preset: ThemePreset) -> Bool {
        core.contains(where: { $0.id == preset.rawValue })
    }

    /// Non-classic entries — Sweet/Bright/Soft/Moody/Loud presets shipped
    /// by DesignKit for every consumer.
    private static let nonClassicEntries: [PresetTheme] = [
        // Sweet (pink/warm light)
        .bubblegum, .sakura, .roseGold, .lavender, .coral,
        // Bright (saturated backgrounds — new, showcase)
        .barbie, .lemonade, .mintChip, .poolside,
        // Soft (neutrals, pastels, muted)
        .cream, .paper, .sand, .roseDawn, .sage, .serika, .matcha, .arctic,
        // Moody (dark character)
        .charcoal, .nord, .dracula, .gruvbox, .forestNight, .midnight, .oxblood,
        // Loud (out-there combos)
        .ghostOrchid, .voltage, .frostlime, .vaporwave, .ember
    ]
}

private extension PresetTheme {
    // Shared base anchors for the original 5, matching the prior Palette output.
    static let legacyLightBG = Color(hex: "#F8FAFC")
    static let legacyLightSurface = Color(hex: "#FFFFFF")
    static let legacyLightText = Color(hex: "#0F172A")
    static let legacyDarkBG = Color(hex: "#090909")
    static let legacyDarkSurface = Color(hex: "#131313")
    static let legacyDarkText = Color(hex: "#F9FAFB")

    // Game-number palettes (D-14) live in the sibling file
    // `PresetTheme+GameNumberPalettes.swift` to keep this file under the
    // 500-line soft cap (CLAUDE.md §8.5). Referenced below by name as
    // `classicGameNumberPalette`, `bubblegumGameNumberPalette`, etc.

    // The "Classic" entry (id `"classicMuted"`) is host-app-owned —
    // GameDrawer registers Chrome Diner, FitnessTracker registers its own
    // teal-on-cream identity, etc. Each consumer wires it via
    // `DesignKit.configure(classicPreset:)` at App.init. See
    // `DesignKitConfig.swift` for the registration surface and the neutral
    // grey fallback used when a consumer has not configured.

    static let forestEntry = PresetTheme(
        id: "forest",
        displayName: "Forest",
        category: .classic,
        light: PresetAnchors(
            background: legacyLightBG, surface: legacyLightSurface,
            accent: Color(hex: "#0F766E"), textPrimary: legacyLightText,
            customChartColors: ["#2C5B45", "#4A7E63", "#7D9E64", "#8B6A4C", "#4B6670", "#6E7F86"].map(Color.init(hex:)),
            gameNumberPalette: classicGameNumberPalette
        ),
        dark: PresetAnchors(
            background: legacyDarkBG, surface: legacyDarkSurface,
            accent: Color(hex: "#14B8A6"), textPrimary: legacyDarkText,
            customChartColors: ["#2C5B45", "#4A7E63", "#7D9E64", "#8B6A4C", "#4B6670", "#6E7F86"].map(Color.init(hex:)),
            gameNumberPalette: classicGameNumberPalette
        )
    )

    static let navyEntry = PresetTheme(
        id: "navy",
        displayName: "Navy",
        category: .classic,
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
        category: .classic,
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
        category: .classic,
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
        category: .classic,
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
        category: .soft,
        light: PresetAnchors(
            background: Color(hex: "#F4ECD8"),
            surface: Color(hex: "#FAF3E0"),
            accent: Color(hex: "#8C5A2B"),
            textPrimary: Color(hex: "#2B1D0E"),
            gameNumberPalette: creamGameNumberPalette
        ),
        dark: PresetAnchors(
            background: Color(hex: "#1E1A14"),
            surface: Color(hex: "#2A241B"),
            accent: Color(hex: "#D9A771"),
            textPrimary: Color(hex: "#F4ECD8"),
            gameNumberPalette: creamGameNumberPalette
        ),
        preferredScheme: .light
    )

    static let paper = PresetTheme(
        id: "paper",
        displayName: "Paper",
        category: .soft,
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
        category: .soft,
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
        category: .sweet,
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
        category: .soft,
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
        category: .soft,
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
        category: .moody,
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
        category: .moody,
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
        category: .moody,
        light: PresetAnchors(
            background: Color(hex: "#F5F3FB"),
            surface: Color(hex: "#FFFFFF"),
            accent: Color(hex: "#6B3FA0"),
            textPrimary: Color(hex: "#282A36"),
            gameNumberPalette: draculaGameNumberPalette,
            gameNumberPaletteWongSafe: classicGameNumberPalette
        ),
        dark: PresetAnchors(
            background: Color(hex: "#282A36"),
            surface: Color(hex: "#343746"),
            accent: Color(hex: "#BD93F9"),
            textPrimary: Color(hex: "#F8F8F2"),
            gameNumberPalette: draculaGameNumberPalette,
            gameNumberPaletteWongSafe: classicGameNumberPalette
        ),
        preferredScheme: .dark
    )

    static let gruvbox = PresetTheme(
        id: "gruvbox",
        displayName: "Gruvbox",
        category: .moody,
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
        category: .moody,
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
        category: .moody,
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
        category: .moody,
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
        category: .loud,
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
        category: .loud,
        light: PresetAnchors(
            background: Color(hex: "#F4F0FA"),
            surface: Color(hex: "#FBF7FF"),
            accent: Color(hex: "#7C3AED"),
            textPrimary: Color(hex: "#1B0A3E"),
            gameNumberPalette: voltageGameNumberPalette,
            gameNumberPaletteWongSafe: classicGameNumberPalette
        ),
        dark: PresetAnchors(
            background: Color(hex: "#0B0820"),
            surface: Color(hex: "#14102D"),
            accent: Color(hex: "#FACC15"),
            textPrimary: Color(hex: "#EDE9FE"),
            gameNumberPalette: voltageGameNumberPalette,
            gameNumberPaletteWongSafe: classicGameNumberPalette
        ),
        preferredScheme: .dark
    )

    /// Mint/lime on near-black. Icy electric pop.
    static let frostlime = PresetTheme(
        id: "frostlime",
        displayName: "Frostlime",
        category: .loud,
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
        category: .sweet,
        light: PresetAnchors(
            background: Color(hex: "#FFF1F5"),
            surface: Color(hex: "#FFF8FA"),
            accent: Color(hex: "#EC4899"),
            textPrimary: Color(hex: "#500724"),
            gameNumberPalette: bubblegumGameNumberPalette,
            gameNumberPaletteWongSafe: classicGameNumberPalette
        ),
        dark: PresetAnchors(
            background: Color(hex: "#1A0C12"),
            surface: Color(hex: "#25121B"),
            accent: Color(hex: "#F472B6"),
            textPrimary: Color(hex: "#FFE4ED"),
            gameNumberPalette: bubblegumGameNumberPalette,
            gameNumberPaletteWongSafe: classicGameNumberPalette
        ),
        preferredScheme: .light
    )

    // MARK: - Feminine / warm extensions

    /// Cherry blossom — delicate pink on soft blush.
    static let sakura = PresetTheme(
        id: "sakura",
        displayName: "Sakura",
        category: .sweet,
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
        category: .sweet,
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
        category: .sweet,
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
        category: .sweet,
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
        category: .loud,
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
        category: .soft,
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
        category: .soft,
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
        category: .loud,
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

    // MARK: - Bright (saturated background — the "I'd wear this" showcase)
    //
    // Unlike Soft/Sweet presets (tinted near-white bg), Bright presets use the
    // saturated color AS the background. Surface = lighter tinted card so
    // content stays readable. Dark variants invert: desaturated bg, accent
    // reappears as pop.

    /// Hot pink bg, blush cards, wine accent. Maximum Barbie energy.
    static let barbie = PresetTheme(
        id: "barbie",
        displayName: "Barbie",
        category: .bright,
        light: PresetAnchors(
            background: Color(hex: "#F472B6"),
            surface: Color(hex: "#FBCFE8"),
            accent: Color(hex: "#831843"),
            textPrimary: Color(hex: "#3D0E28"),
            gameNumberPalette: barbieGameNumberPalette,
            gameNumberPaletteWongSafe: classicGameNumberPalette
        ),
        dark: PresetAnchors(
            background: Color(hex: "#4A0C2A"),
            surface: Color(hex: "#5E1638"),
            accent: Color(hex: "#F9A8D4"),
            textPrimary: Color(hex: "#FDD5E8"),
            gameNumberPalette: barbieGameNumberPalette,
            gameNumberPaletteWongSafe: classicGameNumberPalette
        ),
        preferredScheme: .light
    )

    /// Saturated lemon yellow bg, plum accent. Summer-picnic loud.
    static let lemonade = PresetTheme(
        id: "lemonade",
        displayName: "Lemonade",
        category: .bright,
        light: PresetAnchors(
            background: Color(hex: "#FDE047"),
            surface: Color(hex: "#FFF7CC"),
            accent: Color(hex: "#7E22CE"),
            textPrimary: Color(hex: "#422006")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#3F2D00"),
            surface: Color(hex: "#52400B"),
            accent: Color(hex: "#FDE047"),
            textPrimary: Color(hex: "#FFF4B3")
        ),
        preferredScheme: .light
    )

    /// Bright mint bg, pale surface, deep forest accent. Gelato-shop bright.
    static let mintChip = PresetTheme(
        id: "mintChip",
        displayName: "Mint Chip",
        category: .bright,
        light: PresetAnchors(
            background: Color(hex: "#6EE7B7"),
            surface: Color(hex: "#D1FAE5"),
            accent: Color(hex: "#065F46"),
            textPrimary: Color(hex: "#042F1A")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#0A3D2D"),
            surface: Color(hex: "#125540"),
            accent: Color(hex: "#6EE7B7"),
            textPrimary: Color(hex: "#D1FAE5")
        ),
        preferredScheme: .light
    )

    /// Bright cyan bg, paler cards, deep teal accent. Saltwater pool vibe.
    static let poolside = PresetTheme(
        id: "poolside",
        displayName: "Poolside",
        category: .bright,
        light: PresetAnchors(
            background: Color(hex: "#67E8F9"),
            surface: Color(hex: "#CFFAFE"),
            accent: Color(hex: "#0C4A6E"),
            textPrimary: Color(hex: "#083344")
        ),
        dark: PresetAnchors(
            background: Color(hex: "#083344"),
            surface: Color(hex: "#0F4759"),
            accent: Color(hex: "#67E8F9"),
            textPrimary: Color(hex: "#CFFAFE")
        ),
        preferredScheme: .light
    )
}
