import Foundation

public protocol ThemeStorage {
    func loadMode() -> ThemeMode
    func saveMode(_ mode: ThemeMode)
    func loadPreset() -> ThemePreset
    func savePreset(_ preset: ThemePreset)
    func loadOverrides() -> ThemeOverrides?
    func saveOverrides(_ overrides: ThemeOverrides?)
}

public extension ThemeStorage {
    func loadOverrides() -> ThemeOverrides? { nil }
    func saveOverrides(_ overrides: ThemeOverrides?) {}
}

public final class UserDefaultsThemeStorage: ThemeStorage {
    private let defaults: UserDefaults
    private let modeKey: String
    private let presetKey: String
    private let overridesKey: String

    public init(
        defaults: UserDefaults = .standard,
        modeKey: String = "designkit.theme.mode",
        presetKey: String = "designkit.theme.preset",
        overridesKey: String = "designkit.theme.overrides"
    ) {
        self.defaults = defaults
        self.modeKey = modeKey
        self.presetKey = presetKey
        self.overridesKey = overridesKey
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

    public func loadOverrides() -> ThemeOverrides? {
        guard let data = defaults.data(forKey: overridesKey) else { return nil }
        do {
            let payload = try JSONDecoder().decode(ThemeOverridesPayload.self, from: data)
            return try ThemeBackupCodec.overrides(from: payload)
        } catch {
            return nil
        }
    }

    public func saveOverrides(_ overrides: ThemeOverrides?) {
        guard let overrides else {
            defaults.removeObject(forKey: overridesKey)
            return
        }
        do {
            let payload = try ThemeBackupCodec.payload(from: overrides)
            if let payload {
                let data = try JSONEncoder().encode(payload)
                defaults.set(data, forKey: overridesKey)
            } else {
                defaults.removeObject(forKey: overridesKey)
            }
        } catch {
            defaults.removeObject(forKey: overridesKey)
        }
    }
}
