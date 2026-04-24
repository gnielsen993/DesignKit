import SwiftUI

@MainActor
public final class ThemeManager: ObservableObject {
    @Published public var mode: ThemeMode {
        didSet { storage.saveMode(mode) }
    }

    @Published public var preset: ThemePreset {
        didSet { storage.savePreset(preset) }
    }

    @Published public var overrides: ThemeOverrides? {
        didSet { storage.saveOverrides(overrides) }
    }

    private let storage: ThemeStorage

    public init(storage: ThemeStorage = UserDefaultsThemeStorage()) {
        self.storage = storage
        self.mode = storage.loadMode()
        self.preset = storage.loadPreset()
        self.overrides = storage.loadOverrides()
    }

    public func resolvedScheme(using systemScheme: ColorScheme) -> ColorScheme {
        switch mode {
        case .system: systemScheme
        case .light: .light
        case .dark: .dark
        }
    }

    public func theme(using systemScheme: ColorScheme) -> Theme {
        theme(using: systemScheme, overrides: overrides)
    }

    public func theme(using systemScheme: ColorScheme, overrides: ThemeOverrides?) -> Theme {
        Theme.resolve(
            preset: preset,
            scheme: resolvedScheme(using: systemScheme),
            overrides: overrides
        )
    }

    /// True if any color anchor has been overridden.
    public var hasCustomOverrides: Bool {
        guard let colors = overrides?.colors else { return false }
        return colors.accentPrimary != nil
            || colors.background != nil
            || colors.surface != nil
            || colors.textPrimary != nil
            || colors.accentSecondary != nil
    }

    /// Clear all custom color overrides, returning to the pure preset palette.
    public func resetOverrides() {
        overrides = nil
    }

    /// Set or clear a single anchor override. Pass `nil` to clear that anchor.
    public func setOverrideAnchor(
        accent: Color? = nil,
        background: Color? = nil,
        surface: Color? = nil,
        textPrimary: Color? = nil,
        clearAccent: Bool = false,
        clearBackground: Bool = false,
        clearSurface: Bool = false,
        clearTextPrimary: Bool = false
    ) {
        var current = overrides?.colors ?? ThemeColorOverrides()
        if clearAccent { current.accentPrimary = nil } else if let accent { current.accentPrimary = accent }
        if clearBackground { current.background = nil } else if let background { current.background = background }
        if clearSurface { current.surface = nil } else if let surface { current.surface = surface }
        if clearTextPrimary { current.textPrimary = nil } else if let textPrimary { current.textPrimary = textPrimary }

        let empty = current.accentPrimary == nil
            && current.background == nil
            && current.surface == nil
            && current.textPrimary == nil
            && current.accentSecondary == nil
            && current.border == nil
            && current.surfaceElevated == nil
            && current.textSecondary == nil
            && current.textTertiary == nil
            && current.highlight == nil
            && current.success == nil
            && current.warning == nil
            && current.danger == nil
            && current.fillPressed == nil
            && current.fillSelected == nil
            && current.fillDisabled == nil

        if empty {
            overrides = nil
        } else {
            overrides = ThemeOverrides(
                colors: current,
                typography: overrides?.typography,
                spacing: overrides?.spacing,
                radii: overrides?.radii,
                motion: overrides?.motion,
                charts: overrides?.charts
            )
        }
    }
}
