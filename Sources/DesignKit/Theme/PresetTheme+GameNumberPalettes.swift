import SwiftUI

// MARK: - Game-number palettes (D-14)
//
// Minesweeper adjacency numbers 1–8. The Classic (Forest) palette is the
// traditional Minesweeper colors tuned to satisfy the Wong audit (D-15)
// unconditionally — first-launch default must read cleanly under
// protanopia / deuteranopia / tritanopia. Loud presets ship aesthetic
// defaults plus the Classic palette as `gameNumberPaletteWongSafe`.
//
// Extracted from `PresetTheme.swift` to keep that file under the 500-line
// soft cap (CLAUDE.md §8.5). All palette constants are private to the
// DesignKit module — they are referenced from `PresetTheme` declarations
// and from `ColorDerivation.fallbackGameNumberPalette` for the resolver
// fallback path.

extension PresetTheme {
    /// Classic / Wong-safe Minesweeper palette. Verified by
    /// `GameNumberPaletteWongTests.testForestPalettePassesAllThreeCVDsUnconditionally`.
    static let classicGameNumberPalette: [Color] = [
        Color(hex: "#1976D2"),  // 1 = blue
        Color(hex: "#2E7D32"),  // 2 = green
        Color(hex: "#D32F2F"),  // 3 = red
        Color(hex: "#212121"),  // 4 = near-black (cool-leaning so it survives CVD)
        Color(hex: "#7B1FA2"),  // 5 = purple
        Color(hex: "#0097A7"),  // 6 = cyan
        Color(hex: "#FFC107"),  // 7 = amber (replaces traditional black for CVD)
        Color(hex: "#616161")   // 8 = grey
    ]

    /// Cream — soft warm preset reuses the Classic palette unchanged. The
    /// surface tone is cream-on-white in light mode; classic palette reads
    /// well against it without re-tuning.
    static let creamGameNumberPalette: [Color] = classicGameNumberPalette

    /// Bubblegum — sweet/pink. Lifted saturation on cool channels so they
    /// hold against the warm pink surface. Wong-safe override falls back to
    /// Classic if any adjacent pair fails ΔE under CVD simulation.
    static let bubblegumGameNumberPalette: [Color] = [
        Color(hex: "#1565C0"),  // 1 = saturated blue
        Color(hex: "#2E7D32"),  // 2 = forest green
        Color(hex: "#C2185B"),  // 3 = rose-red
        Color(hex: "#311B92"),  // 4 = deep indigo
        Color(hex: "#6A1B9A"),  // 5 = plum
        Color(hex: "#00838F"),  // 6 = teal
        Color(hex: "#F57F17"),  // 7 = warm amber
        Color(hex: "#424242")   // 8 = charcoal
    ]

    /// Dracula — dark moody. Brighter / fluorescent variants tuned to the
    /// dark surface (#282A36).
    static let draculaGameNumberPalette: [Color] = [
        Color(hex: "#8BE9FD"),  // 1 = cyan
        Color(hex: "#50FA7B"),  // 2 = green
        Color(hex: "#FF5555"),  // 3 = red
        Color(hex: "#BD93F9"),  // 4 = purple
        Color(hex: "#FF79C6"),  // 5 = pink
        Color(hex: "#F1FA8C"),  // 6 = yellow
        Color(hex: "#FFB86C"),  // 7 = orange
        Color(hex: "#F8F8F2")   // 8 = foreground white
    ]

    /// Barbie — bright pink background; flagged HIGH RISK in UI-SPEC §Theme
    /// Matrix. Default ships a tuned palette aesthetically; Wong-safe override
    /// falls back to Classic for CVD users.
    static let barbieGameNumberPalette: [Color] = [
        Color(hex: "#0D47A1"),  // 1 = deep blue (high contrast vs pink bg)
        Color(hex: "#1B5E20"),  // 2 = deep green
        Color(hex: "#831843"),  // 3 = wine (matches preset accent)
        Color(hex: "#1A237E"),  // 4 = navy
        Color(hex: "#4A148C"),  // 5 = deep purple
        Color(hex: "#006064"),  // 6 = deep teal
        Color(hex: "#E65100"),  // 7 = burnt orange
        Color(hex: "#3D0E28")   // 8 = darkest plum (matches text)
    ]

    /// Voltage — acid-yellow on violet-black; flagged HIGH RISK. Default
    /// ships neon variants tuned for the dark violet surface; Wong-safe
    /// override falls back to Classic.
    static let voltageGameNumberPalette: [Color] = [
        Color(hex: "#60A5FA"),  // 1 = sky blue
        Color(hex: "#4ADE80"),  // 2 = lime
        Color(hex: "#FB7185"),  // 3 = coral
        Color(hex: "#A78BFA"),  // 4 = lavender
        Color(hex: "#F472B6"),  // 5 = pink
        Color(hex: "#22D3EE"),  // 6 = cyan
        Color(hex: "#FACC15"),  // 7 = electric yellow (preset accent)
        Color(hex: "#F1F5F9")   // 8 = near-white
    ]
}
