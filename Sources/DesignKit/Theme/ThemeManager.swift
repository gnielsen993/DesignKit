import SwiftUI

@MainActor
public final class ThemeManager: ObservableObject {
    @Published public var mode: ThemeMode {
        didSet { storage.saveMode(mode) }
    }

    @Published public var preset: ThemePreset {
        didSet { storage.savePreset(preset) }
    }

    private let storage: ThemeStorage

    public init(storage: ThemeStorage = UserDefaultsThemeStorage()) {
        self.storage = storage
        self.mode = storage.loadMode()
        self.preset = storage.loadPreset()
    }

    public func resolvedScheme(using systemScheme: ColorScheme) -> ColorScheme {
        switch mode {
        case .system: systemScheme
        case .light: .light
        case .dark: .dark
        }
    }

    public func theme(using systemScheme: ColorScheme) -> Theme {
        Theme.resolve(preset: preset, scheme: resolvedScheme(using: systemScheme))
    }
}
