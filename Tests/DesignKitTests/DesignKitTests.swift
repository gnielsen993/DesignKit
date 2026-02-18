import XCTest
import SwiftUI
@testable import DesignKit

@MainActor
final class DesignKitTests: XCTestCase {
    func testThemeDefaultsLoad() {
        let storage = InMemoryThemeStorage(mode: .system, preset: .forest)
        let manager = ThemeManager(storage: storage)

        XCTAssertEqual(manager.mode, .system)
        XCTAssertEqual(manager.preset, .forest)
    }

    func testThemeResolvesLightBackground() {
        let theme = Theme.resolve(preset: .navy, scheme: .light)
        XCTAssertNotNil(theme.colors.background)
    }

    func testThemeStorageSavesModeAndPreset() {
        let storage = InMemoryThemeStorage(mode: .system, preset: .forest)
        let manager = ThemeManager(storage: storage)

        manager.mode = .dark
        manager.preset = .walnut

        XCTAssertEqual(storage.mode, .dark)
        XCTAssertEqual(storage.preset, .walnut)
    }
}

private final class InMemoryThemeStorage: ThemeStorage {
    var mode: ThemeMode
    var preset: ThemePreset

    init(mode: ThemeMode, preset: ThemePreset) {
        self.mode = mode
        self.preset = preset
    }

    func loadMode() -> ThemeMode { mode }
    func saveMode(_ mode: ThemeMode) { self.mode = mode }

    func loadPreset() -> ThemePreset { preset }
    func savePreset(_ preset: ThemePreset) { self.preset = preset }
}
