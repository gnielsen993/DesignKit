//
//  GameNumberPaletteWongTests.swift
//  DesignKitTests
//
//  A11Y-04 verification — adjacency-number palette must be perceptually
//  distinct under protanopia / deuteranopia / tritanopia (D-15).
//
//  - Classic (forest) MUST pass unconditionally — first-launch default.
//  - Loud presets (voltage / barbie / dracula / bubblegum) MAY ship a
//    `gameNumberPaletteWongSafe` override; the resolver-applied palette
//    is the unit under test (RESEARCH Pitfall 6 — read through
//    `theme.colors.gameNumberPaletteWongSafe ?? theme.colors.gameNumberPalette`).
//
//  Reference: Machado et al. 2009, Brettel/Vienot/Mollon 1997, Wong 2011
//  (Nature Methods "Color blindness").
//
//  Threshold: ΔE2000 ≥ 10 between adjacent palette entries — chosen to
//  match Wong-palette guidance ("easily distinguishable" cutoff). We
//  apply the threshold under each CVD simulation, NOT only on the raw
//  sRGB pair, since two visually-distinct sRGB colors may collapse into
//  near-identical CVD perception.
//

import XCTest
import SwiftUI
@testable import DesignKit

@MainActor
final class GameNumberPaletteWongTests: XCTestCase {

    /// Wong-palette ΔE2000 threshold. Hard-coded constant — never lower
    /// to make a failing preset pass; ship a `gameNumberPaletteWongSafe`
    /// override on the preset instead (D-15).
    private static let deltaThreshold: Double = 10.0

    private static let auditPresets: [ThemePreset] = [
        .forest, .bubblegum, .barbie, .cream, .dracula, .voltage
    ]

    /// Classic forest is the default first-launch preset. Per D-15 it MUST
    /// pass the Wong audit unconditionally. This test reads the palette
    /// through the production resolver path so the preset's own override
    /// (if any) is the thing under test.
    func testForestPalettePassesAllThreeCVDsUnconditionally() {
        let theme = Theme.resolve(preset: .forest, scheme: .light)
        let palette = effectivePalette(of: theme)
        XCTAssertEqual(palette.count, 8, "Forest palette must be length 8")

        for cvd in ColorVisionDeficiency.allCases {
            let failures = adjacentPairFailures(palette: palette, cvd: cvd)
            XCTAssertTrue(
                failures.isEmpty,
                "Forest [\(cvd)] adjacent-pair failures (ΔE < \(Self.deltaThreshold)): \(failures)"
            )
        }
    }

    /// Forest must also pass under dark scheme — the dark anchors ship
    /// `classicGameNumberPaletteDark` (lightened for dark surfaces; the
    /// light palette's near-black "4" is illegible there), so this audits
    /// the dark variant with the same unconditional bar as light.
    func testForestPalettePassesAllThreeCVDsInDarkScheme() {
        let theme = Theme.resolve(preset: .forest, scheme: .dark)
        let palette = effectivePalette(of: theme)
        XCTAssertEqual(palette.count, 8)
        for cvd in ColorVisionDeficiency.allCases {
            let failures = adjacentPairFailures(palette: palette, cvd: cvd)
            XCTAssertTrue(
                failures.isEmpty,
                "Forest [dark/\(cvd)] adjacent-pair failures: \(failures)"
            )
        }
    }

    /// Every audit-set preset's resolver-emitted palette (default OR override)
    /// must satisfy ΔE ≥ 10. If the default fails AND no override ships,
    /// this surfaces the gap so the executor adds an override.
    func testEveryAuditPresetResolverOutputIsWongSafe() {
        for preset in Self.auditPresets {
            let scheme = preferredScheme(for: preset)
            let theme = Theme.resolve(preset: preset, scheme: scheme)
            let palette = effectivePalette(of: theme)
            XCTAssertEqual(palette.count, 8, "\(preset) palette length")

            for cvd in ColorVisionDeficiency.allCases {
                let failures = adjacentPairFailures(palette: palette, cvd: cvd)
                XCTAssertTrue(
                    failures.isEmpty,
                    "\(preset) [\(cvd)] adjacent-pair failures: \(failures) — " +
                    "ship `gameNumberPaletteWongSafe` override (D-15)"
                )
            }
        }
    }

    /// Sanity check on the sRGB pair distance (no CVD applied) — guards
    /// against a palette that collapses adjacent entries to identical
    /// colors before we even simulate vision deficiency.
    func testForestPaletteAdjacentPairsAreDistinctInsRGB() {
        assertAdjacentPairsDistinctInsRGB(scheme: .light)
    }

    /// Dark-scheme twin — audits `classicGameNumberPaletteDark`.
    func testForestDarkPaletteAdjacentPairsAreDistinctInsRGB() {
        assertAdjacentPairsDistinctInsRGB(scheme: .dark)
    }

    private func assertAdjacentPairsDistinctInsRGB(scheme: ColorScheme) {
        let theme = Theme.resolve(preset: .forest, scheme: scheme)
        let palette = effectivePalette(of: theme)
        for i in 0..<(palette.count - 1) {
            guard
                let a = ColorVisionSimulator.sRGBComponents(of: palette[i]),
                let b = ColorVisionSimulator.sRGBComponents(of: palette[i + 1])
            else {
                XCTFail("Cannot extract sRGB components for index \(i)")
                continue
            }
            let dE = ColorVisionSimulator.deltaE2000(a, b)
            XCTAssertGreaterThanOrEqual(
                dE, Self.deltaThreshold,
                "Forest [\(scheme)] sRGB adjacent pair \(i + 1)/\(i + 2) ΔE \(dE) below threshold"
            )
        }
    }

    // MARK: - Helpers

    /// Reads palette through the same selection used in
    /// `Theme.gameNumber(_:)` — Wong-safe override has precedence.
    private func effectivePalette(of theme: Theme) -> [Color] {
        theme.colors.gameNumberPaletteWongSafe ?? theme.colors.gameNumberPalette
    }

    /// For each adjacent index pair (i, i+1), simulate the given CVD and
    /// return the (1-indexed digit pair, ΔE) tuples whose ΔE falls below
    /// `Self.deltaThreshold`.
    private func adjacentPairFailures(
        palette: [Color],
        cvd: ColorVisionDeficiency
    ) -> [(Int, Int, Double)] {
        var fails: [(Int, Int, Double)] = []
        for i in 0..<(palette.count - 1) {
            guard
                let a = ColorVisionSimulator.sRGBComponents(of: palette[i]),
                let b = ColorVisionSimulator.sRGBComponents(of: palette[i + 1])
            else { continue }
            let aSim = ColorVisionSimulator.simulate(a, cvd: cvd)
            let bSim = ColorVisionSimulator.simulate(b, cvd: cvd)
            let dE = ColorVisionSimulator.deltaE2000(aSim, bSim)
            if dE < Self.deltaThreshold {
                fails.append((i + 1, i + 2, dE))
            }
        }
        return fails
    }

    /// Loud / Moody presets prefer dark; Sweet / Soft / Bright prefer light;
    /// Classic supports both — pick light for parity. This mirrors the
    /// scheme each preset is intended to render in.
    private func preferredScheme(for preset: ThemePreset) -> ColorScheme {
        switch preset {
        case .dracula, .voltage: return .dark
        default:                  return .light
        }
    }
}
