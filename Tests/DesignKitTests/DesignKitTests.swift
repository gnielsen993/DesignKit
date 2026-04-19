import XCTest
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
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

    func testThemeModeContractForPersistence() {
        XCTAssertEqual(ThemeMode.system.rawValue, "system")
        XCTAssertEqual(ThemeMode.light.rawValue, "light")
        XCTAssertEqual(ThemeMode.dark.rawValue, "dark")

        XCTAssertTrue(ThemeMode.allCases.contains(.system))
        XCTAssertTrue(ThemeMode.allCases.contains(.light))
        XCTAssertTrue(ThemeMode.allCases.contains(.dark))
    }

    func testThemePresetContractForPersistenceAndUI() {
        XCTAssertEqual(ThemePreset.forest.rawValue, "forest")
        XCTAssertEqual(ThemePreset.navy.rawValue, "navy")
        XCTAssertEqual(ThemePreset.maroon.rawValue, "maroon")
        XCTAssertEqual(ThemePreset.walnut.rawValue, "walnut")
        XCTAssertEqual(ThemePreset.stone.rawValue, "stone")

        XCTAssertEqual(ThemePreset.forest.displayName, "Forest")
        XCTAssertEqual(ThemePreset.navy.displayName, "Navy")
        XCTAssertEqual(ThemePreset.maroon.displayName, "Maroon")
        XCTAssertEqual(ThemePreset.walnut.displayName, "Walnut")
        XCTAssertEqual(ThemePreset.stone.displayName, "Stone")

        XCTAssertTrue(ThemePreset.allCases.contains(.forest))
        XCTAssertTrue(ThemePreset.allCases.contains(.navy))
        XCTAssertTrue(ThemePreset.allCases.contains(.maroon))
        XCTAssertTrue(ThemePreset.allCases.contains(.walnut))
        XCTAssertTrue(ThemePreset.allCases.contains(.stone))
    }

    func testThemeManagerResolvedSchemeMatchesMode() {
        let storage = InMemoryThemeStorage(mode: .system, preset: .forest)
        let manager = ThemeManager(storage: storage)

        manager.mode = .system
        XCTAssertEqual(manager.resolvedScheme(using: .light), .light)
        XCTAssertEqual(manager.resolvedScheme(using: .dark), .dark)

        manager.mode = .light
        XCTAssertEqual(manager.resolvedScheme(using: .dark), .light)

        manager.mode = .dark
        XCTAssertEqual(manager.resolvedScheme(using: .light), .dark)
    }

    // Contract surface used throughout FitnessTracker views.
    func testResolvedThemeExposesFitnessTrackerTokenSurface() {
        let theme = Theme.resolve(preset: .forest, scheme: .light)

        _ = theme.colors.accentPrimary
        _ = theme.colors.background
        _ = theme.colors.border
        _ = theme.colors.danger
        _ = theme.colors.highlight
        _ = theme.colors.success
        _ = theme.colors.surfaceElevated
        _ = theme.colors.textPrimary
        _ = theme.colors.textSecondary
        _ = theme.colors.textTertiary

        _ = theme.typography.body
        _ = theme.typography.caption
        _ = theme.typography.headline
        _ = theme.typography.title
        _ = theme.typography.titleLarge

        _ = theme.spacing.l
        _ = theme.spacing.m
        _ = theme.spacing.s
        _ = theme.spacing.xl
        _ = theme.spacing.xs

        _ = theme.radii.button
        _ = theme.radii.card
        _ = theme.radii.chip

        _ = theme.charts.chart1
        _ = theme.charts.chart2
        _ = theme.charts.chart3
    }

    func testFitnessTrackerUsedComponentsRemainConstructible() {
        let theme = Theme.resolve(preset: .stone, scheme: .dark)

        _ = DKCard(theme: theme) { Text("Card") }
        _ = DKButton("Primary", theme: theme) {}
        _ = DKButton("Secondary", style: .secondary, theme: theme, isEnabled: false) {}
        _ = DKProgressRing(progress: 0.5, label: "Coverage", theme: theme)
        _ = DKSectionHeader("Header", subtitle: "Subheader", theme: theme)
        _ = DKBadge("Badge", theme: theme)
    }

    func testUserDefaultsThemeStorageReadsPersistedValues() {
        let suiteName = "DesignKitTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        defaults.set("dark", forKey: "designkit.theme.mode")
        defaults.set("navy", forKey: "designkit.theme.preset")

        let storage = UserDefaultsThemeStorage(defaults: defaults)

        XCTAssertEqual(storage.loadMode(), .dark)
        XCTAssertEqual(storage.loadPreset(), .navy)
    }

    func testUserDefaultsThemeStorageFallsBackForInvalidValues() {
        let suiteName = "DesignKitTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        defaults.set("unknown_mode", forKey: "designkit.theme.mode")
        defaults.set("unknown_preset", forKey: "designkit.theme.preset")

        let storage = UserDefaultsThemeStorage(defaults: defaults)

        XCTAssertEqual(storage.loadMode(), .system)
        XCTAssertEqual(storage.loadPreset(), .forest)
    }

    func testThemeResolverMatchesPaletteWithoutOverrides() {
        for preset in ThemePreset.allCases {
            for scheme in [ColorScheme.light, .dark] {
                let resolvedLegacy = Theme.resolve(preset: preset, scheme: scheme)
                let resolvedResolver = ThemeResolver.resolve(preset: preset, scheme: scheme, overrides: nil)
                let paletteColors = Palette.colors(for: preset, scheme: scheme)
                let paletteCharts = Palette.charts(for: preset)

                assertThemeColorsEqual(resolvedLegacy.colors, paletteColors)
                assertThemeColorsEqual(resolvedResolver.colors, paletteColors)
                assertChartTokensEqual(resolvedLegacy.charts, paletteCharts)
                assertChartTokensEqual(resolvedResolver.charts, paletteCharts)
            }
        }
    }

    func testThemeResolveOverloadWithNilOverridesMatchesLegacyResolve() {
        let legacy = Theme.resolve(preset: .navy, scheme: .dark)
        let overloaded = Theme.resolve(preset: .navy, scheme: .dark, overrides: nil)

        assertThemeColorsEqual(legacy.colors, overloaded.colors)
        assertChartTokensEqual(legacy.charts, overloaded.charts)
        XCTAssertEqual(legacy.spacing.l, overloaded.spacing.l)
        XCTAssertEqual(legacy.radii.card, overloaded.radii.card)
        XCTAssertEqual(legacy.motion.normal, overloaded.motion.normal)
    }

    func testThemeResolverAppliesOverridesWithoutChangingUntouchedTokens() {
        let base = ThemeResolver.resolve(preset: .forest, scheme: .light, overrides: nil)
        let overrides = ThemeOverrides(
            colors: ThemeColorOverrides(
                textPrimary: Color(hex: "#14532D"),
                accentPrimary: Color(hex: "#4C1D95")
            ),
            spacing: SpacingTokens(xs: 6, s: 10, m: 14, l: 18, xl: 26, xxl: 34),
            radii: RadiusTokens(card: 20, button: 18, chip: 14, sheet: 24),
            motion: MotionTokens(fast: 0.12, normal: 0.22, slow: 0.36),
            charts: ChartOverrides(
                chart3: Color(hex: "#0E7490"),
                gridlineOpacity: 0.32
            )
        )
        let resolved = ThemeResolver.resolve(preset: .forest, scheme: .light, overrides: overrides)

        assertColorEqual(resolved.colors.accentPrimary, Color(hex: "#4C1D95"))
        assertColorEqual(resolved.colors.textPrimary, Color(hex: "#14532D"))
        assertColorEqual(resolved.colors.background, base.colors.background)
        assertColorEqual(resolved.charts.chart3, Color(hex: "#0E7490"))
        assertColorEqual(resolved.charts.chart1, base.charts.chart1)
        XCTAssertEqual(resolved.charts.gridlineOpacity, 0.32, accuracy: 0.0001)
        XCTAssertEqual(resolved.charts.axisLabelOpacity, base.charts.axisLabelOpacity, accuracy: 0.0001)
        XCTAssertEqual(resolved.spacing.xs, 6, accuracy: 0.0001)
        XCTAssertEqual(resolved.spacing.l, 18, accuracy: 0.0001)
        XCTAssertEqual(resolved.radii.card, 20, accuracy: 0.0001)
        XCTAssertEqual(resolved.motion.normal, 0.22, accuracy: 0.0001)
    }

    func testThemeBackupCodecRoundTripPreservesConfiguration() throws {
        let configuration = ThemeBackupConfiguration(
            mode: .dark,
            preset: .maroon,
            overrides: ThemeOverrides(
                colors: ThemeColorOverrides(
                    textPrimary: Color(hex: "#14532D"),
                    accentPrimary: Color(hex: "#4C1D95")
                ),
                spacing: SpacingTokens(xs: 6, s: 10, m: 14, l: 18, xl: 26, xxl: 34),
                radii: RadiusTokens(card: 20, button: 18, chip: 14, sheet: 24),
                motion: MotionTokens(fast: 0.12, normal: 0.22, slow: 0.36),
                charts: ChartOverrides(
                    chart3: Color(hex: "#0E7490"),
                    gridlineOpacity: 0.32
                )
            )
        )

        let data = try ThemeBackupCodec.encodeJSON(configuration)
        let decoded = try ThemeBackupCodec.decodeJSON(data)

        XCTAssertEqual(decoded.mode, .dark)
        XCTAssertEqual(decoded.preset, .maroon)

        let resolved = ThemeResolver.resolve(
            preset: decoded.preset,
            scheme: .dark,
            overrides: decoded.overrides
        )

        assertColorEqual(resolved.colors.accentPrimary, Color(hex: "#4C1D95"))
        assertColorEqual(resolved.colors.textPrimary, Color(hex: "#14532D"))
        assertColorEqual(resolved.charts.chart3, Color(hex: "#0E7490"))
        XCTAssertEqual(resolved.charts.gridlineOpacity, 0.32, accuracy: 0.0001)
        XCTAssertEqual(resolved.spacing.l, 18, accuracy: 0.0001)
        XCTAssertEqual(resolved.radii.card, 20, accuracy: 0.0001)
        XCTAssertEqual(resolved.motion.normal, 0.22, accuracy: 0.0001)
    }

    func testThemeBackupCodecWritesCurrentSchemaVersion() throws {
        let configuration = ThemeBackupConfiguration(mode: .system, preset: .forest, overrides: nil)
        let data = try ThemeBackupCodec.encodeJSON(configuration)
        let document = try JSONDecoder().decode(ThemeBackupDocument.self, from: data)

        XCTAssertEqual(document.schemaVersion, ThemeBackupDocument.currentSchemaVersion)
        XCTAssertEqual(document.mode, .system)
        XCTAssertEqual(document.preset, .forest)
    }

    func testThemeBackupCodecRejectsUnsupportedSchemaVersion() throws {
        let document = ThemeBackupDocument(
            schemaVersion: ThemeBackupDocument.currentSchemaVersion + 1,
            mode: .system,
            preset: .forest,
            overrides: nil
        )
        let data = try JSONEncoder().encode(document)

        XCTAssertThrowsError(try ThemeBackupCodec.decodeJSON(data)) { error in
            guard case let ThemeBackupCodecError.unsupportedSchemaVersion(version) = error else {
                XCTFail("Expected unsupportedSchemaVersion error, got \(error)")
                return
            }
            XCTAssertEqual(version, ThemeBackupDocument.currentSchemaVersion + 1)
        }
    }

    func testThemeBackupCodecRejectsInvalidColorHex() throws {
        let document = ThemeBackupDocument(
            mode: .dark,
            preset: .navy,
            overrides: ThemeOverridesPayload(
                colors: ThemeColorOverridesPayload(accentPrimary: "#not-a-hex")
            )
        )
        let data = try JSONEncoder().encode(document)

        XCTAssertThrowsError(try ThemeBackupCodec.decodeJSON(data)) { error in
            guard case ThemeBackupCodecError.invalidColorHex = error else {
                XCTFail("Expected invalidColorHex error, got \(error)")
                return
            }
        }
    }

    func testThemeBackupServiceCreatesParentDirectoriesAndWritesFile() throws {
        let service = ThemeBackupService()
        let fileManager = FileManager.default
        let root = fileManager.temporaryDirectory.appendingPathComponent("DesignKitTests-\(UUID().uuidString)")
        defer { try? fileManager.removeItem(at: root) }

        let outputURL = root
            .appendingPathComponent("nested")
            .appendingPathComponent("theme")
            .appendingPathComponent("backup.\(ThemeBackupService.fileExtension)")

        let configuration = ThemeBackupConfiguration(mode: .light, preset: .walnut)

        XCTAssertFalse(fileManager.fileExists(atPath: outputURL.path))
        try service.exportConfiguration(configuration, to: outputURL)
        XCTAssertTrue(fileManager.fileExists(atPath: outputURL.path))
    }

    func testThemeBackupServiceExportImportRoundTrip() throws {
        let service = ThemeBackupService()
        let fileManager = FileManager.default
        let root = fileManager.temporaryDirectory.appendingPathComponent("DesignKitTests-\(UUID().uuidString)")
        defer { try? fileManager.removeItem(at: root) }

        let outputURL = root.appendingPathComponent("theme.\(ThemeBackupService.fileExtension)")
        let configuration = ThemeBackupConfiguration(
            mode: .dark,
            preset: .stone,
            overrides: ThemeOverrides(
                colors: ThemeColorOverrides(accentPrimary: Color(hex: "#0EA5E9")),
                spacing: SpacingTokens(xs: 5, s: 9, m: 13, l: 17, xl: 25, xxl: 33),
                motion: MotionTokens(fast: 0.11, normal: 0.21, slow: 0.31)
            )
        )

        try service.exportConfiguration(configuration, to: outputURL)
        let imported = try service.importConfiguration(from: outputURL)

        XCTAssertEqual(imported.mode, .dark)
        XCTAssertEqual(imported.preset, .stone)

        let resolved = ThemeResolver.resolve(preset: .stone, scheme: .dark, overrides: imported.overrides)
        assertColorEqual(resolved.colors.accentPrimary, Color(hex: "#0EA5E9"))
        XCTAssertEqual(resolved.spacing.l, 17, accuracy: 0.0001)
        XCTAssertEqual(resolved.motion.normal, 0.21, accuracy: 0.0001)
    }
}

private func assertThemeColorsEqual(
    _ lhs: ThemeColors,
    _ rhs: ThemeColors,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    assertColorEqual(lhs.background, rhs.background, file: file, line: line)
    assertColorEqual(lhs.surface, rhs.surface, file: file, line: line)
    assertColorEqual(lhs.surfaceElevated, rhs.surfaceElevated, file: file, line: line)
    assertColorEqual(lhs.border, rhs.border, file: file, line: line)
    assertColorEqual(lhs.textPrimary, rhs.textPrimary, file: file, line: line)
    assertColorEqual(lhs.textSecondary, rhs.textSecondary, file: file, line: line)
    assertColorEqual(lhs.textTertiary, rhs.textTertiary, file: file, line: line)
    assertColorEqual(lhs.accentPrimary, rhs.accentPrimary, file: file, line: line)
    assertColorEqual(lhs.accentSecondary, rhs.accentSecondary, file: file, line: line)
    assertColorEqual(lhs.highlight, rhs.highlight, file: file, line: line)
    assertColorEqual(lhs.success, rhs.success, file: file, line: line)
    assertColorEqual(lhs.warning, rhs.warning, file: file, line: line)
    assertColorEqual(lhs.danger, rhs.danger, file: file, line: line)
    assertColorEqual(lhs.fillPressed, rhs.fillPressed, file: file, line: line)
    assertColorEqual(lhs.fillSelected, rhs.fillSelected, file: file, line: line)
    assertColorEqual(lhs.fillDisabled, rhs.fillDisabled, file: file, line: line)
}

private func assertChartTokensEqual(
    _ lhs: ChartTokens,
    _ rhs: ChartTokens,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    assertColorEqual(lhs.chart1, rhs.chart1, file: file, line: line)
    assertColorEqual(lhs.chart2, rhs.chart2, file: file, line: line)
    assertColorEqual(lhs.chart3, rhs.chart3, file: file, line: line)
    assertColorEqual(lhs.chart4, rhs.chart4, file: file, line: line)
    assertColorEqual(lhs.chart5, rhs.chart5, file: file, line: line)
    assertColorEqual(lhs.chart6, rhs.chart6, file: file, line: line)
    XCTAssertEqual(lhs.gridlineOpacity, rhs.gridlineOpacity, accuracy: 0.0001, file: file, line: line)
    XCTAssertEqual(lhs.axisLabelOpacity, rhs.axisLabelOpacity, accuracy: 0.0001, file: file, line: line)
}

private func assertColorEqual(
    _ lhs: Color,
    _ rhs: Color,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    guard let lhsComponents = colorComponents(lhs) else {
        XCTFail("Failed to extract color components for lhs", file: file, line: line)
        return
    }
    guard let rhsComponents = colorComponents(rhs) else {
        XCTFail("Failed to extract color components for rhs", file: file, line: line)
        return
    }

    XCTAssertEqual(lhsComponents.r, rhsComponents.r, accuracy: 0.001, file: file, line: line)
    XCTAssertEqual(lhsComponents.g, rhsComponents.g, accuracy: 0.001, file: file, line: line)
    XCTAssertEqual(lhsComponents.b, rhsComponents.b, accuracy: 0.001, file: file, line: line)
    XCTAssertEqual(lhsComponents.a, rhsComponents.a, accuracy: 0.001, file: file, line: line)
}

private func colorComponents(_ color: Color) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? {
#if canImport(UIKit)
    let platformColor = UIColor(color)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    guard platformColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
    return (red, green, blue, alpha)
#elseif canImport(AppKit)
    let platformColor = NSColor(color)
    guard let rgbColor = platformColor.usingColorSpace(.sRGB) else { return nil }
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return (red, green, blue, alpha)
#else
    return nil
#endif
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
