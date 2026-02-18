import Foundation

public enum ThemeMode: String, CaseIterable, Codable, Identifiable {
    case system
    case light
    case dark

    public var id: String { rawValue }
}
