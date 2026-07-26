import SwiftUI

public struct Theme {
    public let colors: ThemeColors
    public let typography: TypographyTokens
    public let spacing: SpacingTokens
    public let radii: RadiusTokens
    public let motion: MotionTokens
    public let charts: ChartTokens

    /// Catalogue accent palette — one of `CataloguePalette.muted` /
    /// `.bright` selected by the active preset's `category`. Consumers
    /// read via `catalogueColor(_:)` (below). Defaults to the bright
    /// palette so themes constructed without a resolver (tests, ad-hoc
    /// previews) still have a populated catalogue.
    public let cataloguePalette: [Color]

    public init(
        colors: ThemeColors,
        typography: TypographyTokens = TypographyTokens(),
        spacing: SpacingTokens = SpacingTokens(),
        radii: RadiusTokens = RadiusTokens(),
        motion: MotionTokens = MotionTokens(),
        charts: ChartTokens,
        cataloguePalette: [Color] = CataloguePalette.bright
    ) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.radii = radii
        self.motion = motion
        self.charts = charts
        self.cataloguePalette = cataloguePalette
    }

    public static func resolve(preset: ThemePreset, scheme: ColorScheme) -> Theme {
        ThemeResolver.resolve(preset: preset, scheme: scheme, overrides: nil)
    }

    public static func resolve(
        preset: ThemePreset,
        scheme: ColorScheme,
        overrides: ThemeOverrides?
    ) -> Theme {
        ThemeResolver.resolve(preset: preset, scheme: scheme, overrides: overrides)
    }
}

public extension Theme {
    /// Adjacency-number color for n in 1...8 (THEME-02 + D-13).
    ///
    /// Prefers the preset's aesthetic `gameNumberPalette`; falls back to
    /// `gameNumberPaletteWongSafe` only when the aesthetic palette is empty.
    /// n < 1 clamps to palette[0]; n > 8 clamps to palette[7]; never traps.
    /// If neither palette is filled (transitional state), falls back to
    /// `colors.textPrimary` so callers never crash.
    ///
    /// P7 polish: the original D-15 contract had this resolver ALWAYS prefer
    /// Wong-safe over aesthetic. That broke every dark preset that shipped
    /// Classic as the Wong-safe override — e.g. Dracula on dark anchors used
    /// `#212121` for "4", which is near-invisible on the `#343746` dark slate
    /// surface. The original intent was that Wong-safe would be the runtime
    /// fallback for users with a CVD accessibility flag enabled, but the
    /// resolver wired Wong-safe as the unconditional override. There is no
    /// CVD toggle in Settings (and none planned for v1.0), so the right
    /// behavior is to use the preset's aesthetic palette — which the preset
    /// authors tuned for their surface — and treat Wong-safe as a true
    /// fallback when no aesthetic palette is provided.
    func gameNumber(_ n: Int) -> Color {
        if !colors.gameNumberPalette.isEmpty {
            let palette = colors.gameNumberPalette
            let i = max(0, min(palette.count - 1, n - 1))
            return palette[i]
        }
        if let safe = colors.gameNumberPaletteWongSafe, !safe.isEmpty {
            let i = max(0, min(safe.count - 1, n - 1))
            return safe[i]
        }
        return colors.textPrimary
    }

    /// Catalogue accent for a game tile / drawer / shelf entry. `slot` is a
    /// 0-indexed position into the active preset's catalogue palette
    /// (`cataloguePalette`) — populated by `ThemeResolver` based on the
    /// preset's `category` (muted vs bright, see `CataloguePalette`).
    ///
    /// Slot < 0 clamps to 0; slot ≥ palette.count wraps modulo so a
    /// growing game catalogue stays renderable even when it outgrows a
    /// preset's palette length. Falls back to the preset's
    /// `gameNumberPalette` if `cataloguePalette` is empty (transitional /
    /// test-only theme constructions).
    func catalogueColor(_ slot: Int) -> Color {
        if !cataloguePalette.isEmpty {
            let i = ((slot % cataloguePalette.count) + cataloguePalette.count) % cataloguePalette.count
            return cataloguePalette[i]
        }
        return gameNumber(slot + 1)
    }
}
