import XCTest
import SwiftUI
@testable import DesignKit

/// Signal colours keep their hue in every preset (the 2026-07-29 held-state
/// decision) and adapt only their shade, and only on grounds the fixed palette
/// never anticipated — the `bright` family, which uses its loud colour AS the
/// background.
///
/// The property that matters most here is the **no-op**: every classic, soft
/// and moody preset, in this app and in the sibling apps, must come out
/// byte-identical to before.
final class SignalColorAdaptationTests: XCTestCase {

    /// Cross-platform so the suite runs under `swift test` on macOS in seconds
    /// rather than needing a simulator, where xcodebuild's `DVTDeviceOperation`
    /// retries turned this into a ten-minute run (§9.24: a live PID is not
    /// progress).
    private func hsb(_ color: Color) -> (h: Double, s: Double, b: Double) {
#if canImport(UIKit)
        let ui = UIColor(color)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (Double(h), Double(s), Double(b))
#else
        let ns = NSColor(color).usingColorSpace(.sRGB) ?? NSColor(color)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ns.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (Double(h), Double(s), Double(b))
#endif
    }

    private let warningLight = Color(hex: "#D97706")
    private let successLight = Color(hex: "#16A34A")

    // MARK: - The no-op

    func testNeutralGroundLeavesTheSignalExactlyAlone() {
        // Forest's light background, chroma ~0.005.
        let adapted = ColorDerivation.adaptedSignal(warningLight, on: Color(hex: "#F8FAFC"))
        let before = hsb(warningLight), after = hsb(adapted)

        XCTAssertEqual(before.h, after.h, accuracy: 0.0001)
        XCTAssertEqual(before.s, after.s, accuracy: 0.0001)
        XCTAssertEqual(before.b, after.b, accuracy: 0.0001)
    }

    /// The catalog is the fixture. A calm preset that starts triggering the
    /// adaptation means either its ground got loud or the threshold drifted,
    /// and both are worth stopping — this is what caught the first attempt,
    /// which keyed on HSB saturation and fired on five near-black grounds.
    func testEveryCalmPresetGroundIsBelowTheTrigger() {
        for preset in PresetCatalog.all where ![.bright, .loud].contains(preset.category) {
            for (name, anchors) in [("light", preset.light), ("dark", preset.dark)] {
                let c = ColorDerivation.chroma(anchors.background) ?? 0
                XCTAssertLessThan(
                    c, ColorDerivation.signalGroundChromaTrigger,
                    "\(preset.id) \(name) ground chroma \(c) would trigger signal adaptation"
                )
            }
        }
    }

    func testTheLoudLightGroundsDoTrigger() {
        // The four the finding was actually about.
        for id in ["barbie", "lemonade", "mintChip", "poolside"] {
            guard let preset = PresetCatalog.all.first(where: { $0.id == id }) else {
                return XCTFail("preset \(id) is gone; this test needs repointing")
            }
            let c = ColorDerivation.chroma(preset.light.background) ?? 0
            XCTAssertGreaterThan(c, ColorDerivation.signalGroundChromaTrigger, "\(id) should adapt")
        }
    }

    // MARK: - The adaptation

    func testLoudLightGroundDeepensTheSignalWithoutChangingItsHue() {
        // Barbie's light background: hot pink, chroma 0.175.
        let adapted = ColorDerivation.adaptedSignal(warningLight, on: Color(hex: "#F472B6"))
        let before = hsb(warningLight), after = hsb(adapted)

        XCTAssertEqual(before.h, after.h, accuracy: 0.01, "amber must stay amber")
        XCTAssertLessThan(after.b, before.b, "a light loud ground should deepen the signal")
    }

    func testLoudDarkGroundLiftsTheSignal() {
        // Barbie's dark background: deep maroon, chroma 0.096.
        let adapted = ColorDerivation.adaptedSignal(successLight, on: Color(hex: "#4A0C2A"))
        let before = hsb(successLight), after = hsb(adapted)

        XCTAssertEqual(before.h, after.h, accuracy: 0.01, "green must stay green")
        XCTAssertGreaterThan(after.b, before.b, "a dark loud ground should lift the signal")
    }

    func testAdaptationScalesWithHowLoudTheGroundIs() {
        // By chroma, Barbie's pink (0.175) is louder than Lemonade's yellow
        // (0.166), so Barbie moves further. Under HSB saturation the ordering
        // was the other way round — one more reason that measure was wrong.
        let barbie = hsb(ColorDerivation.adaptedSignal(warningLight, on: Color(hex: "#F472B6")))
        let lemonade = hsb(ColorDerivation.adaptedSignal(warningLight, on: Color(hex: "#FDE047")))

        XCTAssertLessThan(barbie.b, lemonade.b)
    }

    func testTheShiftIsBoundedSoASignalNeverGoesBlackOrWhite() {
        for ground in ["#F472B6", "#FDE047", "#67E8F9", "#6EE7B7", "#4A0C2A"] {
            for signal in [warningLight, successLight, Color(hex: "#DC2626")] {
                let after = hsb(ColorDerivation.adaptedSignal(signal, on: Color(hex: ground)))
                XCTAssertGreaterThan(after.b, 0.15, "signal went too dark on \(ground)")
                XCTAssertLessThan(after.b, 1.0, "signal blew out on \(ground)")
            }
        }
    }
}
