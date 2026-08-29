import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum ColorDerivation {

    /// Fallback game-number palette for any preset that hasn't declared its
    /// own. Mirrors the Classic / Forest Wong-safe Minesweeper palette so
    /// every resolved theme emits a length-8 Wong-safe palette by default.
    /// Keep in sync with `PresetTheme.classicGameNumberPalette`.
    static let fallbackGameNumberPalette: [Color] = [
        Color(hex: "#1976D2"),  // 1 = blue
        Color(hex: "#2E7D32"),  // 2 = green
        Color(hex: "#D32F2F"),  // 3 = red
        Color(hex: "#212121"),  // 4 = near-black
        Color(hex: "#E65100"),  // 5 = deep orange
        Color(hex: "#0097A7"),  // 6 = cyan
        Color(hex: "#F9A825"),  // 7 = bright amber
        Color(hex: "#616161")   // 8 = grey
    ]

    /// Dark-scheme fallback. Keep in sync with
    /// `PresetTheme.classicGameNumberPaletteDark` — the light fallback's
    /// near-black "4" and dim grey "8" are illegible on dark surfaces.
    static let fallbackGameNumberPaletteDark: [Color] = [
        Color(hex: "#64B5F6"),  // 1 = light blue
        Color(hex: "#81C784"),  // 2 = light green
        Color(hex: "#E57373"),  // 3 = light red
        Color(hex: "#E0E0E0"),  // 4 = near-white
        Color(hex: "#FFB74D"),  // 5 = light orange
        Color(hex: "#4DD0E1"),  // 6 = light cyan
        Color(hex: "#F9A825"),  // 7 = bright amber
        Color(hex: "#9E9E9E")   // 8 = mid grey
    ]

    static func colors(from anchors: PresetAnchors, scheme: ColorScheme) -> ThemeColors {
        let isDark = scheme == .dark

        let surfaceElevated = blend(anchors.surface, with: isDark ? .white : .black, ratio: isDark ? 0.04 : 0.02)
        let border = isDark
            ? Color.white.opacity(0.12)
            : blend(anchors.textPrimary, with: anchors.background, ratio: 0.85)
        let textSecondary = blend(anchors.textPrimary, with: anchors.background, ratio: isDark ? 0.28 : 0.32)
        let textTertiary = blend(anchors.textPrimary, with: anchors.background, ratio: isDark ? 0.50 : 0.55)
        let accentSecondary = anchors.accent.opacity(isDark ? 0.78 : 0.82)
        let highlight = anchors.accent.opacity(isDark ? 0.20 : 0.14)
        let fillPressed = isDark ? Color.white.opacity(0.07) : Color.black.opacity(0.05)
        let fillSelected = anchors.accent.opacity(isDark ? 0.24 : 0.16)
        let fillDisabled = isDark ? Color.white.opacity(0.14) : Color.black.opacity(0.10)

        // Fallback: any preset that hasn't declared its own palette inherits
        // the Classic Minesweeper colors so every resolved theme always emits
        // a length-8 Wong-safe palette (D-15 + D-16). Scheme-aware — the
        // light palette's near-black "4" is illegible on dark surfaces.
        let gameNumberPalette = anchors.gameNumberPalette
            ?? (isDark ? fallbackGameNumberPaletteDark : fallbackGameNumberPalette)

        return ThemeColors(
            background: anchors.background,
            surface: anchors.surface,
            surfaceElevated: surfaceElevated,
            border: border,
            textPrimary: anchors.textPrimary,
            textSecondary: textSecondary,
            textTertiary: textTertiary,
            accentPrimary: anchors.accent,
            accentSecondary: accentSecondary,
            highlight: highlight,
            success: adaptedSignal(isDark ? Color(hex: "#22C55E") : Color(hex: "#16A34A"), on: anchors.background),
            warning: adaptedSignal(isDark ? Color(hex: "#F59E0B") : Color(hex: "#D97706"), on: anchors.background),
            danger: adaptedSignal(isDark ? Color(hex: "#EF4444") : Color(hex: "#DC2626"), on: anchors.background),
            fillPressed: fillPressed,
            fillSelected: fillSelected,
            fillDisabled: fillDisabled,
            gameNumberPalette: gameNumberPalette,
            gameNumberPaletteWongSafe: anchors.gameNumberPaletteWongSafe
        )
    }

    static func charts(from anchors: PresetAnchors) -> ChartTokens {
        if let custom = anchors.customChartColors, custom.count >= 6 {
            return ChartTokens(
                chart1: custom[0],
                chart2: custom[1],
                chart3: custom[2],
                chart4: custom[3],
                chart5: custom[4],
                chart6: custom[5],
                gridlineOpacity: 0.20,
                axisLabelOpacity: 0.70
            )
        }
        return derivedCharts(from: anchors.accent)
    }

    private static func derivedCharts(from accent: Color) -> ChartTokens {
        let hsb = hsbComponents(accent) ?? (h: 0.5, s: 0.5, b: 0.5)
        let c1 = accent
        let c2 = Color(hue: wrap(hsb.h + 0.08), saturation: clamp(hsb.s * 0.90), brightness: clamp(hsb.b * 1.05))
        let c3 = Color(hue: wrap(hsb.h - 0.08), saturation: clamp(hsb.s * 0.80), brightness: clamp(hsb.b * 0.92))
        let c4 = Color(hue: wrap(hsb.h + 0.17), saturation: clamp(hsb.s * 0.65), brightness: clamp(hsb.b * 0.95))
        let c5 = Color(hue: wrap(hsb.h - 0.17), saturation: clamp(hsb.s * 0.55), brightness: clamp(hsb.b * 1.05))
        let c6 = Color(hue: wrap(hsb.h + 0.33), saturation: clamp(hsb.s * 0.50), brightness: clamp(hsb.b * 0.98))
        return ChartTokens(
            chart1: c1, chart2: c2, chart3: c3, chart4: c4, chart5: c5, chart6: c6,
            gridlineOpacity: 0.20,
            axisLabelOpacity: 0.70
        )
    }

    // MARK: - Color math

    static func blend(_ a: Color, with b: Color, ratio: Double) -> Color {
        guard
            let ca = rgbComponents(a),
            let cb = rgbComponents(b)
        else { return a }
        let r = ca.r * (1 - ratio) + cb.r * ratio
        let g = ca.g * (1 - ratio) + cb.g * ratio
        let bl = ca.b * (1 - ratio) + cb.b * ratio
        let al = ca.a * (1 - ratio) + cb.a * ratio
        return Color(.sRGB, red: r, green: g, blue: bl, opacity: al)
    }

    /// Perceptual chroma (OKLab) at which a background stops being a neutral
    /// ground and starts competing with the colours drawn on it.
    ///
    /// **HSB saturation cannot be used here**, and a first attempt that did was
    /// caught by `testEveryNeutralGroundIsBelowTheTrigger`: HSB measures
    /// saturation relative to brightness, so Bubblegum's near-black `#1A0C12`
    /// reports 0.54 while being visually almost neutral. Five soft and sweet
    /// presets tripped a saturation trigger that no eye would agree with.
    ///
    /// 0.085 sits in a real gap in the shipped catalog — the loud light grounds
    /// are 0.115 to 0.175 and Barbie's dark is 0.096, while the next value down
    /// is Vaporwave's dark at 0.070 and every classic, soft and moody ground is
    /// below 0.056.
    static let signalGroundChromaTrigger: Double = 0.085

    /// Chroma at which the adaptation reaches full strength — the loudest
    /// ground the catalog ships (Barbie light, 0.175).
    private static let signalGroundChromaCeiling: Double = 0.175

    /// OKLab chroma. Lightness-independent, which is the whole reason it is
    /// used instead of HSB saturation.
    static func chroma(_ color: Color) -> Double? {
        guard let c = rgbComponents(color) else { return nil }
        func lin(_ v: Double) -> Double {
            v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }
        let r = lin(c.r), g = lin(c.g), b = lin(c.b)
        let l = cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
        let m = cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
        let s = cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)
        let a = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
        let bb = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
        return (a * a + bb * bb).squareRoot()
    }

    /// Keeps a signal colour's **hue** and moves only its shade, so amber stays
    /// amber and green stays green in every preset.
    ///
    /// The fixed signal colours (2026-07-29: state colours do not follow the
    /// theme) were chosen against a near-neutral ground, which is what every
    /// preset had until the `bright` family made its loud colour the background.
    /// On those, an unchanged amber reads as a second competing colour rather
    /// than a signal.
    ///
    /// **This is a no-op wherever the ground is already neutral** — which is
    /// almost everywhere, including every preset in the sibling apps. It cannot
    /// change a theme that did not have the problem.
    ///
    /// Deliberately not contrast-driven: on Barbie the amber has perfectly
    /// adequate contrast against the pale card it sits on. The complaint was
    /// never legibility, it was that the whole field reads as saturated, so the
    /// trigger is the ground's chroma and the response is to push the signal
    /// away from it in value.
    static func adaptedSignal(_ signal: Color, on ground: Color) -> Color {
        guard let groundChroma = chroma(ground), groundChroma >= signalGroundChromaTrigger,
              let g = hsbComponents(ground), let s = hsbComponents(signal) else { return signal }

        // How far past the trigger the ground sits, 0...1.
        let span = signalGroundChromaCeiling - signalGroundChromaTrigger
        let excess = min(1, max(0, (groundChroma - signalGroundChromaTrigger) / span))
        let shift = 0.18 * excess

        // Move away from the ground: deepen on a light ground, lift on a dark
        // one. A signal that drifts toward the ground's own value is the thing
        // that disappears into it.
        let groundIsLight = g.b > 0.5
        let brightness = clamp(groundIsLight ? s.b - shift : s.b + shift)
        let saturation = clamp(groundIsLight ? s.s + 0.05 * excess : s.s - 0.05 * excess)

        return Color(hue: wrap(s.h), saturation: saturation, brightness: brightness)
    }

    private static func rgbComponents(_ color: Color) -> (r: Double, g: Double, b: Double, a: Double)? {
#if canImport(UIKit)
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return (Double(r), Double(g), Double(b), Double(a))
#elseif canImport(AppKit)
        let ns = NSColor(color).usingColorSpace(.sRGB) ?? NSColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ns.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b), Double(a))
#else
        return nil
#endif
    }

    private static func hsbComponents(_ color: Color) -> (h: Double, s: Double, b: Double)? {
#if canImport(UIKit)
        let ui = UIColor(color)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return nil }
        return (Double(h), Double(s), Double(b))
#elseif canImport(AppKit)
        let ns = NSColor(color).usingColorSpace(.sRGB) ?? NSColor(color)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ns.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (Double(h), Double(s), Double(b))
#else
        return nil
#endif
    }

    private static func wrap(_ h: Double) -> Double {
        var v = h.truncatingRemainder(dividingBy: 1.0)
        if v < 0 { v += 1.0 }
        return v
    }

    private static func clamp(_ v: Double, _ lo: Double = 0, _ hi: Double = 1) -> Double {
        min(max(v, lo), hi)
    }
}
