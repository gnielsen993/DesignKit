//
//  ThemeGameNumberTests.swift
//  DesignKitTests
//
//  Token contract for `theme.gameNumber(_:)` (D-13). Verifies:
//    - Clamp to 1...8 (n=0 → palette[0]; n=9 → palette[7])
//    - Every audit-set preset emits a length-8 palette via the resolver path
//    - Resolver path (`Theme.resolve(preset:scheme:)`) is the unit under test —
//      NOT raw `PresetTheme` declarations (RESEARCH Pitfall 6)
//    - Wong-safe override takes precedence when set on a preset's anchors
//
//  XCTest target convention (DesignKitTests uses XCTest, not Swift Testing —
//  see PATTERNS §"Established pattern: Wong-audit XCTest" critical correction).
//

import XCTest
import SwiftUI
@testable import DesignKit

@MainActor
final class ThemeGameNumberTests: XCTestCase {

    // Audit set per UI-SPEC §Theme Matrix
    private static let auditPresets: [ThemePreset] = [
        .forest, .bubblegum, .barbie, .cream, .dracula, .voltage
    ]

    func testEveryAuditPresetEmitsLength8Palette() {
        for preset in Self.auditPresets {
            for scheme in [ColorScheme.light, .dark] {
                let theme = Theme.resolve(preset: preset, scheme: scheme)
                let palette = theme.colors.gameNumberPaletteWongSafe
                    ?? theme.colors.gameNumberPalette
                XCTAssertEqual(
                    palette.count, 8,
                    "\(preset) [\(scheme)] palette must be length 8 — got \(palette.count)"
                )
            }
        }
    }

    func testEveryPresetEmitsLength8PaletteViaResolverFallback() {
        // Even presets that didn't declare their own palette should fall
        // back to ColorDerivation.fallbackGameNumberPalette via the resolver.
        for preset in ThemePreset.allCases {
            let theme = Theme.resolve(preset: preset, scheme: .light)
            let palette = theme.colors.gameNumberPaletteWongSafe
                ?? theme.colors.gameNumberPalette
            XCTAssertEqual(
                palette.count, 8,
                "\(preset) palette must be length 8 — got \(palette.count). " +
                "ColorDerivation must fill any nil anchor palette with the fallback."
            )
        }
    }

    func testGameNumberClampsBelowOne() {
        let theme = Theme.resolve(preset: .forest, scheme: .light)
        guard
            let c0 = ColorVisionSimulator.sRGBComponents(of: theme.gameNumber(0)),
            let c1 = ColorVisionSimulator.sRGBComponents(of: theme.gameNumber(1)),
            let cNeg = ColorVisionSimulator.sRGBComponents(of: theme.gameNumber(-5))
        else {
            return XCTFail("Cannot extract sRGB components — platform unsupported")
        }
        XCTAssertEqual(c0.r, c1.r, accuracy: 0.001, "n=0 must clamp to palette[0]")
        XCTAssertEqual(c0.g, c1.g, accuracy: 0.001)
        XCTAssertEqual(c0.b, c1.b, accuracy: 0.001)
        XCTAssertEqual(cNeg.r, c1.r, accuracy: 0.001, "Negative n must clamp to palette[0]")
        XCTAssertEqual(cNeg.g, c1.g, accuracy: 0.001)
        XCTAssertEqual(cNeg.b, c1.b, accuracy: 0.001)
    }

    func testGameNumberClampsAboveEight() {
        let theme = Theme.resolve(preset: .forest, scheme: .light)
        guard
            let c8 = ColorVisionSimulator.sRGBComponents(of: theme.gameNumber(8)),
            let c9 = ColorVisionSimulator.sRGBComponents(of: theme.gameNumber(9)),
            let c99 = ColorVisionSimulator.sRGBComponents(of: theme.gameNumber(99))
        else {
            return XCTFail("Cannot extract sRGB components — platform unsupported")
        }
        XCTAssertEqual(c9.r, c8.r, accuracy: 0.001, "n=9 must clamp to palette[7]")
        XCTAssertEqual(c9.g, c8.g, accuracy: 0.001)
        XCTAssertEqual(c9.b, c8.b, accuracy: 0.001)
        XCTAssertEqual(c99.r, c8.r, accuracy: 0.001)
        XCTAssertEqual(c99.g, c8.g, accuracy: 0.001)
        XCTAssertEqual(c99.b, c8.b, accuracy: 0.001)
    }

    func testGameNumberReturnsBlueForClassicOne() {
        // Sanity: Classic palette is Minesweeper-traditional.
        // n=1 must be predominantly blue (B > R) under any color extraction.
        let theme = Theme.resolve(preset: .forest, scheme: .light)
        guard let c1 = ColorVisionSimulator.sRGBComponents(of: theme.gameNumber(1)) else {
            return XCTFail("Cannot extract sRGB components — platform unsupported")
        }
        XCTAssertGreaterThan(
            c1.b, c1.r,
            "Classic n=1 should be predominantly blue (B > R) — got r=\(c1.r) b=\(c1.b)"
        )
    }

    func testWongSafeOverrideTakesPrecedenceWhenSet() {
        // Build a synthetic ThemeColors directly so we can pin both palettes
        // and verify gameNumber(_:) reads the override path.
        let primaryPalette = (0..<8).map { Color(red: 0, green: 0, blue: Double($0 + 1) / 8.0) }
        let safePalette = (0..<8).map { Color(red: Double($0 + 1) / 8.0, green: 0, blue: 0) }
        let synthetic = ThemeColors(
            background: .white,
            surface: .white,
            surfaceElevated: .white,
            border: .black,
            textPrimary: .black,
            textSecondary: .gray,
            textTertiary: .gray,
            accentPrimary: .blue,
            accentSecondary: .purple,
            highlight: .yellow,
            success: .green,
            warning: .orange,
            danger: .red,
            fillPressed: .gray,
            fillSelected: .blue,
            fillDisabled: .gray,
            gameNumberPalette: primaryPalette,
            gameNumberPaletteWongSafe: safePalette
        )
        let charts = ChartTokens(
            chart1: .blue, chart2: .green, chart3: .red,
            chart4: .orange, chart5: .purple, chart6: .yellow,
            gridlineOpacity: 0.20, axisLabelOpacity: 0.70
        )
        let theme = Theme(colors: synthetic, charts: charts)

        guard let got = ColorVisionSimulator.sRGBComponents(of: theme.gameNumber(1)) else {
            return XCTFail("Cannot extract sRGB components")
        }
        // Override path is the red-channel synthetic palette: n=1 → red > 0,
        // green ≈ 0, blue ≈ 0.
        XCTAssertGreaterThan(got.r, 0.0, "Override path should produce non-zero red channel")
        XCTAssertEqual(got.g, 0.0, accuracy: 0.01, "Override path should have ~0 green")
        XCTAssertEqual(got.b, 0.0, accuracy: 0.01, "Override path should have ~0 blue")
    }

    func testGameNumberFallsBackToTextPrimaryOnEmptyPalette() {
        // Defensive path: a malformed ThemeColors with empty primary AND no
        // override should never trap — falls back to textPrimary per
        // Theme.gameNumber(_:) defensive guard.
        let synthetic = ThemeColors(
            background: .white, surface: .white, surfaceElevated: .white, border: .black,
            textPrimary: Color(red: 0.5, green: 0.5, blue: 0.5),
            textSecondary: .gray, textTertiary: .gray,
            accentPrimary: .blue, accentSecondary: .purple, highlight: .yellow,
            success: .green, warning: .orange, danger: .red,
            fillPressed: .gray, fillSelected: .blue, fillDisabled: .gray,
            gameNumberPalette: [],
            gameNumberPaletteWongSafe: nil
        )
        let charts = ChartTokens(
            chart1: .blue, chart2: .green, chart3: .red,
            chart4: .orange, chart5: .purple, chart6: .yellow,
            gridlineOpacity: 0.20, axisLabelOpacity: 0.70
        )
        let theme = Theme(colors: synthetic, charts: charts)

        guard let got = ColorVisionSimulator.sRGBComponents(of: theme.gameNumber(1)) else {
            return XCTFail("Cannot extract sRGB components")
        }
        XCTAssertEqual(got.r, 0.5, accuracy: 0.05)
        XCTAssertEqual(got.g, 0.5, accuracy: 0.05)
        XCTAssertEqual(got.b, 0.5, accuracy: 0.05)
    }
}
