import SwiftUI

@MainActor
public final class ThemeManager: ObservableObject {
    @Published public var mode: ThemeMode {
        didSet { storage.saveMode(mode) }
    }

    @Published public var preset: ThemePreset {
        didSet {
            storage.savePreset(preset)
            if !isApplyingCustom {
                activeCustomThemeID = nil
            }
        }
    }

    @Published public var overrides: ThemeOverrides? {
        didSet {
            storage.saveOverrides(overrides)
            if !isApplyingCustom {
                activeCustomThemeID = nil
            }
        }
    }

    @Published public var customThemes: [CustomTheme] {
        didSet { storage.saveCustomThemes(customThemes) }
    }

    /// Non-nil while a saved custom is applied and its anchors haven't been
    /// manually changed since. Lets the picker highlight the active saved chip.
    @Published public var activeCustomThemeID: UUID?

    private let storage: ThemeStorage
    private var isApplyingCustom = false

    public init(storage: ThemeStorage = UserDefaultsThemeStorage()) {
        self.storage = storage
        self.mode = storage.loadMode()
        self.preset = storage.loadPreset()
        self.overrides = storage.loadOverrides()
        self.customThemes = storage.loadCustomThemes()
        self.activeCustomThemeID = nil
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

    // MARK: - Saved custom themes

    /// Save the current preset + overrides snapshot as a named custom theme.
    /// Returns `nil` if there's nothing to save (no overrides set).
    @discardableResult
    public func saveCurrentAsCustom(name: String) -> CustomTheme? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard let snapshot = overrides, hasCustomOverrides else { return nil }

        let custom = CustomTheme(
            name: trimmed,
            basePresetID: preset.rawValue,
            overrides: snapshot
        )
        customThemes.append(custom)
        activeCustomThemeID = custom.id
        return custom
    }

    /// Apply a saved custom theme — restores its base preset + overrides.
    public func applyCustomTheme(_ custom: CustomTheme) {
        isApplyingCustom = true
        if let raw = ThemePreset(rawValue: custom.basePresetID) {
            preset = raw
        }
        overrides = custom.overrides
        isApplyingCustom = false
        activeCustomThemeID = custom.id
    }

    /// Delete a saved custom theme. If it was the active one, clears the active flag.
    public func deleteCustomTheme(id: UUID) {
        customThemes.removeAll { $0.id == id }
        if activeCustomThemeID == id {
            activeCustomThemeID = nil
        }
    }

    /// Rename an existing saved custom theme.
    public func renameCustomTheme(id: UUID, to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let idx = customThemes.firstIndex(where: { $0.id == id }) else { return }
        customThemes[idx].name = trimmed
    }
}
