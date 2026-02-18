import Foundation

public protocol ThemeStorage {
    func loadMode() -> ThemeMode
    func saveMode(_ mode: ThemeMode)
    func loadPreset() -> ThemePreset
    func savePreset(_ preset: ThemePreset)
}

public final class UserDefaultsThemeStorage: ThemeStorage {
    private let defaults: UserDefaults
    private let modeKey: String
    private let presetKey: String

    public init(
        defaults: UserDefaults = .standard,
        modeKey: String = "designkit.theme.mode",
        presetKey: String = "designkit.theme.preset"
    ) {
        self.defaults = defaults
        self.modeKey = modeKey
        self.presetKey = presetKey
    }

    public func loadMode() -> ThemeMode {
        guard let raw = defaults.string(forKey: modeKey), let mode = ThemeMode(rawValue: raw) else {
            return .system
        }
        return mode
    }

    public func saveMode(_ mode: ThemeMode) {
        defaults.set(mode.rawValue, forKey: modeKey)
    }

    public func loadPreset() -> ThemePreset {
        guard let raw = defaults.string(forKey: presetKey), let preset = ThemePreset(rawValue: raw) else {
            return .forest
        }
        return preset
    }

    public func savePreset(_ preset: ThemePreset) {
        defaults.set(preset.rawValue, forKey: presetKey)
    }
}
