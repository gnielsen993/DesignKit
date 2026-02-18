import Foundation

public enum ThemePreset: String, CaseIterable, Codable, Identifiable {
    case forest
    case navy
    case maroon
    case walnut
    case stone

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .forest: "Forest"
        case .navy: "Navy"
        case .maroon: "Maroon"
        case .walnut: "Walnut"
        case .stone: "Stone"
        }
    }
}
