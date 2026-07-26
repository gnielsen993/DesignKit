import SwiftUI

// MARK: - PaletteMood
//
// Sorts every preset into one of two mood buckets that drive the
// catalogue accent palette (Theme.catalogueColor). Catalogue surfaces —
// game tiles, drawer faces, shelf entries — read with a coherent feel
// across the active preset by sharing the same accent palette within a
// bucket, rather than each preset defining its own catalogue colors.
//
//   `.muted`  → sophisticated / restrained presets (Classic, Soft,
//                Moody groupings). Catalogue uses dusty mids — sage,
//                dust-navy, muted maroon, warm umber, slate plum, deep
//                teal.
//   `.bright` → playful / saturated presets (Sweet, Bright, Loud
//                groupings). Catalogue uses vivid mids — saturated
//                blue, spring green, hot red, sun amber, violet, cyan.
//
// Derived from the existing `PresetCategory` so the picker grouping
// (.classic / .sweet / .bright / .soft / .moody / .loud / .mine) stays
// the single source of truth for preset classification — the mood is a
// view over that categorization, not a parallel taxonomy.
//
// Each palette is 6 colors — enough for the playable game catalogue
// plus an Upcoming slot, sized to comfortably grow into the rest of
// the v1.0 game list. Both palettes are tuned for adjacent-pair
// distinction (no two neighbors collapse to the same hue) and rough
// WCAG legibility under white text — that is the contract catalogue
// faces depend on.
//

public enum PaletteMood: String, Sendable {
    case muted
    case bright
}

public extension PresetCategory {
    /// Mood bucket this category resolves to for catalogue palette
    /// selection. Classic / Soft / Moody / Mine read as muted /
    /// sophisticated; Sweet / Bright / Loud read as playful / saturated.
    var paletteMood: PaletteMood {
        switch self {
        case .classic, .soft, .moody, .mine: return .muted
        case .sweet, .bright, .loud:         return .bright
        }
    }
}

/// Static catalogue accent palettes selected by `PaletteMood`.
/// Resolved into `Theme.cataloguePalette` by `ThemeResolver`; consumers
/// read via `Theme.catalogueColor(_:)`.
public enum CataloguePalette {
    /// Sophisticated / restrained mids. Used by forest, navy, maroon,
    /// walnut, stone, charcoal, gruvbox, and the rest of the muted
    /// bucket. Each pair survives adjacency-distinction by hue family
    /// shift, not by saturation alone, so they stay distinguishable on
    /// the dusty surfaces those presets ship.
    public static let muted: [Color] = [
        Color(hex: "#3F7A5C"),  // 0 — forest green (lifted from sage)
        Color(hex: "#3B6296"),  // 1 — indigo navy (lifted from dust)
        Color(hex: "#A4413F"),  // 2 — sienna maroon (lifted)
        Color(hex: "#B07A33"),  // 3 — bronze umber (lifted)
        Color(hex: "#6B4F94"),  // 4 — royal plum (lifted from slate)
        Color(hex: "#347F7F")   // 5 — deep teal (lifted)
    ]

    /// Playful / saturated mids. Used by dracula, voltage, frostlime,
    /// bubblegum, sakura, ember, barbie, lemonade, mintChip, poolside,
    /// and the rest of the bright bucket. Tuned to read clearly against
    /// the saturated backgrounds those presets ship and to support
    /// white text overlays.
    public static let bright: [Color] = [
        Color(hex: "#3B82F6"),  // 0 — vivid blue
        Color(hex: "#22C55E"),  // 1 — spring green
        Color(hex: "#EF4444"),  // 2 — hot red
        Color(hex: "#F59E0B"),  // 3 — sun amber
        Color(hex: "#A855F7"),  // 4 — violet
        Color(hex: "#06B6D4")   // 5 — cyan
    ]

    /// Resolves a mood to its palette.
    public static func palette(for mood: PaletteMood) -> [Color] {
        switch mood {
        case .muted:  return muted
        case .bright: return bright
        }
    }
}
