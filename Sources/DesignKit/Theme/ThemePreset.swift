import Foundation
import SwiftUI

public enum ThemePreset: String, CaseIterable, Codable, Identifiable {
    // Toned-down classic — quiet greys + muted moss accent.
    case classicMuted
    // Originals
    case forest
    case navy
    case maroon
    case walnut
    case stone
    // Expanded catalog
    case cream
    case paper
    case sand
    case roseDawn
    case sage
    case serika
    case charcoal
    case nord
    case dracula
    case gruvbox
    case forestNight
    case midnight
    case oxblood
    // Showcase (loud by design)
    case ghostOrchid
    case voltage
    case frostlime
    case bubblegum
    case vaporwave
    // Feminine / warm
    case sakura
    case roseGold
    case lavender
    case coral
    // Bold / cool
    case ember
    case arctic
    case matcha
    // Bright (saturated-bg showcase)
    case barbie
    case lemonade
    case mintChip
    case poolside

    public var id: String { rawValue }

    public var displayName: String {
        PresetCatalog.theme(for: self).displayName
    }

    /// Scheme the preset is designed for. `nil` = preset works in both light/dark; follow system.
    public var preferredScheme: ColorScheme? {
        PresetCatalog.theme(for: self).preferredScheme
    }

    /// Mood bucket driving which catalogue accent palette this preset
    /// uses (see `CataloguePalette`). Derived from the preset's existing
    /// `PresetCategory` (Classic/Sweet/Bright/Soft/Moody/Loud) so the
    /// picker grouping stays the single source of truth.
    public var paletteMood: PaletteMood {
        PresetCatalog.theme(for: self).category.paletteMood
    }
}
