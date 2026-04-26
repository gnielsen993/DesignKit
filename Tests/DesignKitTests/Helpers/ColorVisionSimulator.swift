//
//  ColorVisionSimulator.swift
//  DesignKitTests
//
//  Pure-Foundation helper for the A11Y-04 Wong-palette audit (D-15).
//  Provides:
//    - Brettel/Vienot/Mollon (1997) severe-CVD matrix transforms for
//      protanopia / deuteranopia / tritanopia, applied in linear-RGB.
//      Reference: Machado et al. 2009 (openaccess.thecvf.com).
//    - CIE ΔE2000 perceptual distance — sRGB → XYZ (D65) → CIELab → ΔE2000.
//    - sRGB component extraction from a SwiftUI `Color` (mirrors the
//      `colorComponents(_:)` helper in `DesignKitTests.swift:411-432`).
//
//  Pure Swift / Foundation / SwiftUI; no third-party dep. Used exclusively
//  from the DesignKitTests target.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum ColorVisionDeficiency: String, CaseIterable {
    case protanopia, deuteranopia, tritanopia
}

enum ColorVisionSimulator {

    // MARK: - Brettel/Vienot/Mollon severe-CVD matrices (linear sRGB)
    //
    // Standard 100% deficiency matrices applied in linear-RGB space.
    // Source: Machado et al. 2009, "A Physiologically-based Model for
    // Simulation of Color Vision Deficiency" (Table 1).

    private static let protanopiaMatrix: [[Double]] = [
        [0.567, 0.433, 0.000],
        [0.558, 0.442, 0.000],
        [0.000, 0.242, 0.758]
    ]
    private static let deuteranopiaMatrix: [[Double]] = [
        [0.625, 0.375, 0.000],
        [0.700, 0.300, 0.000],
        [0.000, 0.300, 0.700]
    ]
    private static let tritanopiaMatrix: [[Double]] = [
        [0.950, 0.050, 0.000],
        [0.000, 0.433, 0.567],
        [0.000, 0.475, 0.525]
    ]

    /// Simulate severe (100%) CVD on an sRGB color tuple `(r,g,b)` with
    /// channels in [0, 1]. Internally gamma-decodes to linear-RGB, applies
    /// the matrix, and gamma-encodes back to sRGB.
    static func simulate(
        _ srgb: (r: Double, g: Double, b: Double),
        cvd: ColorVisionDeficiency
    ) -> (r: Double, g: Double, b: Double) {
        let m: [[Double]]
        switch cvd {
        case .protanopia:   m = protanopiaMatrix
        case .deuteranopia: m = deuteranopiaMatrix
        case .tritanopia:   m = tritanopiaMatrix
        }
        let linear = (
            r: srgbToLinear(srgb.r),
            g: srgbToLinear(srgb.g),
            b: srgbToLinear(srgb.b)
        )
        let r2 = m[0][0] * linear.r + m[0][1] * linear.g + m[0][2] * linear.b
        let g2 = m[1][0] * linear.r + m[1][1] * linear.g + m[1][2] * linear.b
        let b2 = m[2][0] * linear.r + m[2][1] * linear.g + m[2][2] * linear.b
        return (
            r: linearToSRGB(clamp(r2)),
            g: linearToSRGB(clamp(g2)),
            b: linearToSRGB(clamp(b2))
        )
    }

    // MARK: - ΔE2000 perceptual distance

    /// CIE ΔE2000 between two sRGB colors. Uses D65 illuminant. Returns the
    /// standard CIE ΔE2000 distance (0 = identical, ≥10 = "easily
    /// distinguishable" per Wong-palette guidance).
    static func deltaE2000(
        _ a: (r: Double, g: Double, b: Double),
        _ b: (r: Double, g: Double, b: Double)
    ) -> Double {
        let labA = sRGBToLab(a)
        let labB = sRGBToLab(b)
        return ciedE2000(labA, labB)
    }

    // MARK: - sRGB component extraction from SwiftUI Color

    static func sRGBComponents(of color: Color) -> (r: Double, g: Double, b: Double)? {
#if canImport(UIKit)
        let platformColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard platformColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        return (Double(red), Double(green), Double(blue))
#elseif canImport(AppKit)
        let platformColor = NSColor(color)
        guard let rgb = platformColor.usingColorSpace(.sRGB) else { return nil }
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        rgb.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Double(red), Double(green), Double(blue))
#else
        return nil
#endif
    }

    // MARK: - Color-space helpers (private)

    private static func srgbToLinear(_ c: Double) -> Double {
        c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
    }

    private static func linearToSRGB(_ c: Double) -> Double {
        c <= 0.0031308 ? 12.92 * c : 1.055 * pow(c, 1.0 / 2.4) - 0.055
    }

    private static func clamp(_ v: Double, _ lo: Double = 0, _ hi: Double = 1) -> Double {
        min(max(v, lo), hi)
    }

    /// sRGB → CIE XYZ (D65) → CIELab.
    private static func sRGBToLab(_ srgb: (r: Double, g: Double, b: Double)) -> (L: Double, a: Double, b: Double) {
        let r = srgbToLinear(srgb.r)
        let g = srgbToLinear(srgb.g)
        let b = srgbToLinear(srgb.b)
        // sRGB → XYZ (D65), Bradford-adapted matrix
        let X = r * 0.4124564 + g * 0.3575761 + b * 0.1804375
        let Y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750
        let Z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041
        // Reference white D65
        let xr = X / 0.95047
        let yr = Y / 1.00000
        let zr = Z / 1.08883
        let fx = labF(xr)
        let fy = labF(yr)
        let fz = labF(zr)
        return (
            L: 116.0 * fy - 16.0,
            a: 500.0 * (fx - fy),
            b: 200.0 * (fy - fz)
        )
    }

    private static func labF(_ t: Double) -> Double {
        let epsilon = 216.0 / 24389.0
        let kappa = 24389.0 / 27.0
        return t > epsilon ? pow(t, 1.0 / 3.0) : (kappa * t + 16.0) / 116.0
    }

    /// Standard CIE ΔE2000 implementation. Translated from the reference
    /// equations in Sharma, Wu, Dalal (2005) — "The CIEDE2000 Color
    /// Difference Formula: Implementation Notes, Supplementary Test Data,
    /// and Mathematical Observations."
    private static func ciedE2000(
        _ lab1: (L: Double, a: Double, b: Double),
        _ lab2: (L: Double, a: Double, b: Double)
    ) -> Double {
        let kL = 1.0, kC = 1.0, kH = 1.0

        let L1 = lab1.L, a1 = lab1.a, b1 = lab1.b
        let L2 = lab2.L, a2 = lab2.a, b2 = lab2.b

        let C1 = sqrt(a1 * a1 + b1 * b1)
        let C2 = sqrt(a2 * a2 + b2 * b2)
        let avgC = (C1 + C2) / 2.0
        let avgC7 = pow(avgC, 7.0)
        let G = 0.5 * (1.0 - sqrt(avgC7 / (avgC7 + pow(25.0, 7.0))))

        let a1p = (1.0 + G) * a1
        let a2p = (1.0 + G) * a2

        let C1p = sqrt(a1p * a1p + b1 * b1)
        let C2p = sqrt(a2p * a2p + b2 * b2)

        let h1p = atan2deg(b1, a1p)
        let h2p = atan2deg(b2, a2p)

        let dLp = L2 - L1
        let dCp = C2p - C1p

        var dhp: Double = 0
        if C1p * C2p == 0 {
            dhp = 0
        } else {
            let diff = h2p - h1p
            if diff > 180 { dhp = diff - 360 }
            else if diff < -180 { dhp = diff + 360 }
            else { dhp = diff }
        }
        let dHp = 2.0 * sqrt(C1p * C2p) * sin(deg2rad(dhp / 2.0))

        let avgLp = (L1 + L2) / 2.0
        let avgCp = (C1p + C2p) / 2.0

        var avgHp: Double = h1p + h2p
        if C1p * C2p != 0 {
            if abs(h1p - h2p) > 180 {
                avgHp = (h1p + h2p + 360) / 2.0
            } else {
                avgHp = (h1p + h2p) / 2.0
            }
        }

        let T = 1.0
            - 0.17 * cos(deg2rad(avgHp - 30))
            + 0.24 * cos(deg2rad(2.0 * avgHp))
            + 0.32 * cos(deg2rad(3.0 * avgHp + 6))
            - 0.20 * cos(deg2rad(4.0 * avgHp - 63))

        let dTheta = 30.0 * exp(-pow((avgHp - 275.0) / 25.0, 2.0))
        let avgCp7 = pow(avgCp, 7.0)
        let Rc = 2.0 * sqrt(avgCp7 / (avgCp7 + pow(25.0, 7.0)))
        let Sl = 1.0 + (0.015 * pow(avgLp - 50.0, 2.0)) / sqrt(20.0 + pow(avgLp - 50.0, 2.0))
        let Sc = 1.0 + 0.045 * avgCp
        let Sh = 1.0 + 0.015 * avgCp * T
        let Rt = -sin(deg2rad(2.0 * dTheta)) * Rc

        let termL = dLp / (kL * Sl)
        let termC = dCp / (kC * Sc)
        let termH = dHp / (kH * Sh)

        return sqrt(termL * termL + termC * termC + termH * termH + Rt * termC * termH)
    }

    private static func atan2deg(_ y: Double, _ x: Double) -> Double {
        if y == 0 && x == 0 { return 0 }
        let r = atan2(y, x) * 180.0 / .pi
        return r < 0 ? r + 360.0 : r
    }

    private static func deg2rad(_ d: Double) -> Double { d * .pi / 180.0 }
}
