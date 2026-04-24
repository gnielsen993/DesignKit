import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct ThemeBackupDocument: Codable {
    public static let currentSchemaVersion = 1

    public var schemaVersion: Int
    public var mode: ThemeMode
    public var preset: ThemePreset
    public var overrides: ThemeOverridesPayload?

    public init(
        schemaVersion: Int = ThemeBackupDocument.currentSchemaVersion,
        mode: ThemeMode,
        preset: ThemePreset,
        overrides: ThemeOverridesPayload? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.mode = mode
        self.preset = preset
        self.overrides = overrides
    }
}

public struct ThemeBackupConfiguration {
    public var mode: ThemeMode
    public var preset: ThemePreset
    public var overrides: ThemeOverrides?

    public init(
        mode: ThemeMode,
        preset: ThemePreset,
        overrides: ThemeOverrides? = nil
    ) {
        self.mode = mode
        self.preset = preset
        self.overrides = overrides
    }
}

public struct ThemeOverridesPayload: Codable {
    public var colors: ThemeColorOverridesPayload?
    public var spacing: SpacingOverridesPayload?
    public var radii: RadiusOverridesPayload?
    public var motion: MotionOverridesPayload?
    public var charts: ChartOverridesPayload?

    public init(
        colors: ThemeColorOverridesPayload? = nil,
        spacing: SpacingOverridesPayload? = nil,
        radii: RadiusOverridesPayload? = nil,
        motion: MotionOverridesPayload? = nil,
        charts: ChartOverridesPayload? = nil
    ) {
        self.colors = colors
        self.spacing = spacing
        self.radii = radii
        self.motion = motion
        self.charts = charts
    }
}

public struct ThemeColorOverridesPayload: Codable {
    public var background: String?
    public var surface: String?
    public var surfaceElevated: String?
    public var border: String?
    public var textPrimary: String?
    public var textSecondary: String?
    public var textTertiary: String?
    public var accentPrimary: String?
    public var accentSecondary: String?
    public var highlight: String?
    public var success: String?
    public var warning: String?
    public var danger: String?
    public var fillPressed: String?
    public var fillSelected: String?
    public var fillDisabled: String?

    public init(
        background: String? = nil,
        surface: String? = nil,
        surfaceElevated: String? = nil,
        border: String? = nil,
        textPrimary: String? = nil,
        textSecondary: String? = nil,
        textTertiary: String? = nil,
        accentPrimary: String? = nil,
        accentSecondary: String? = nil,
        highlight: String? = nil,
        success: String? = nil,
        warning: String? = nil,
        danger: String? = nil,
        fillPressed: String? = nil,
        fillSelected: String? = nil,
        fillDisabled: String? = nil
    ) {
        self.background = background
        self.surface = surface
        self.surfaceElevated = surfaceElevated
        self.border = border
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.textTertiary = textTertiary
        self.accentPrimary = accentPrimary
        self.accentSecondary = accentSecondary
        self.highlight = highlight
        self.success = success
        self.warning = warning
        self.danger = danger
        self.fillPressed = fillPressed
        self.fillSelected = fillSelected
        self.fillDisabled = fillDisabled
    }
}

public struct SpacingOverridesPayload: Codable {
    public var xs: Double
    public var s: Double
    public var m: Double
    public var l: Double
    public var xl: Double
    public var xxl: Double

    public init(xs: Double, s: Double, m: Double, l: Double, xl: Double, xxl: Double) {
        self.xs = xs
        self.s = s
        self.m = m
        self.l = l
        self.xl = xl
        self.xxl = xxl
    }
}

public struct RadiusOverridesPayload: Codable {
    public var card: Double
    public var button: Double
    public var chip: Double
    public var sheet: Double

    public init(card: Double, button: Double, chip: Double, sheet: Double) {
        self.card = card
        self.button = button
        self.chip = chip
        self.sheet = sheet
    }
}

public struct MotionOverridesPayload: Codable {
    public var fast: Double
    public var normal: Double
    public var slow: Double

    public init(fast: Double, normal: Double, slow: Double) {
        self.fast = fast
        self.normal = normal
        self.slow = slow
    }
}

public struct ChartOverridesPayload: Codable {
    public var chart1: String?
    public var chart2: String?
    public var chart3: String?
    public var chart4: String?
    public var chart5: String?
    public var chart6: String?
    public var gridlineOpacity: Double?
    public var axisLabelOpacity: Double?

    public init(
        chart1: String? = nil,
        chart2: String? = nil,
        chart3: String? = nil,
        chart4: String? = nil,
        chart5: String? = nil,
        chart6: String? = nil,
        gridlineOpacity: Double? = nil,
        axisLabelOpacity: Double? = nil
    ) {
        self.chart1 = chart1
        self.chart2 = chart2
        self.chart3 = chart3
        self.chart4 = chart4
        self.chart5 = chart5
        self.chart6 = chart6
        self.gridlineOpacity = gridlineOpacity
        self.axisLabelOpacity = axisLabelOpacity
    }
}

public enum ThemeBackupCodecError: Error {
    case unsupportedSchemaVersion(Int)
    case invalidColorHex(String)
    case colorEncodingUnsupported
}

public enum ThemeBackupCodec {
    public static func makeDocument(from configuration: ThemeBackupConfiguration) throws -> ThemeBackupDocument {
        ThemeBackupDocument(
            mode: configuration.mode,
            preset: configuration.preset,
            overrides: try payload(from: configuration.overrides)
        )
    }

    public static func encodeJSON(
        _ configuration: ThemeBackupConfiguration,
        encoder: JSONEncoder? = nil
    ) throws -> Data {
        let document = try makeDocument(from: configuration)
        let encoder = encoder ?? makeDefaultEncoder()
        return try encoder.encode(document)
    }

    public static func decodeJSON(
        _ data: Data,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> ThemeBackupConfiguration {
        let document = try decoder.decode(ThemeBackupDocument.self, from: data)
        guard document.schemaVersion == ThemeBackupDocument.currentSchemaVersion else {
            throw ThemeBackupCodecError.unsupportedSchemaVersion(document.schemaVersion)
        }

        return ThemeBackupConfiguration(
            mode: document.mode,
            preset: document.preset,
            overrides: try overrides(from: document.overrides)
        )
    }

    private static func makeDefaultEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }

    static func payload(from overrides: ThemeOverrides?) throws -> ThemeOverridesPayload? {
        guard let overrides else { return nil }

        let colorsPayload: ThemeColorOverridesPayload? = try {
            guard let colors = overrides.colors else { return nil }
            return ThemeColorOverridesPayload(
                background: try hex(from: colors.background),
                surface: try hex(from: colors.surface),
                surfaceElevated: try hex(from: colors.surfaceElevated),
                border: try hex(from: colors.border),
                textPrimary: try hex(from: colors.textPrimary),
                textSecondary: try hex(from: colors.textSecondary),
                textTertiary: try hex(from: colors.textTertiary),
                accentPrimary: try hex(from: colors.accentPrimary),
                accentSecondary: try hex(from: colors.accentSecondary),
                highlight: try hex(from: colors.highlight),
                success: try hex(from: colors.success),
                warning: try hex(from: colors.warning),
                danger: try hex(from: colors.danger),
                fillPressed: try hex(from: colors.fillPressed),
                fillSelected: try hex(from: colors.fillSelected),
                fillDisabled: try hex(from: colors.fillDisabled)
            )
        }()

        let spacingPayload = overrides.spacing.map {
            SpacingOverridesPayload(
                xs: Double($0.xs),
                s: Double($0.s),
                m: Double($0.m),
                l: Double($0.l),
                xl: Double($0.xl),
                xxl: Double($0.xxl)
            )
        }

        let radiiPayload = overrides.radii.map {
            RadiusOverridesPayload(
                card: Double($0.card),
                button: Double($0.button),
                chip: Double($0.chip),
                sheet: Double($0.sheet)
            )
        }

        let motionPayload = overrides.motion.map {
            MotionOverridesPayload(
                fast: $0.fast,
                normal: $0.normal,
                slow: $0.slow
            )
        }

        let chartPayload: ChartOverridesPayload? = try {
            guard let charts = overrides.charts else { return nil }
            return ChartOverridesPayload(
                chart1: try hex(from: charts.chart1),
                chart2: try hex(from: charts.chart2),
                chart3: try hex(from: charts.chart3),
                chart4: try hex(from: charts.chart4),
                chart5: try hex(from: charts.chart5),
                chart6: try hex(from: charts.chart6),
                gridlineOpacity: charts.gridlineOpacity,
                axisLabelOpacity: charts.axisLabelOpacity
            )
        }()

        if colorsPayload == nil &&
            spacingPayload == nil &&
            radiiPayload == nil &&
            motionPayload == nil &&
            chartPayload == nil {
            return nil
        }

        return ThemeOverridesPayload(
            colors: colorsPayload,
            spacing: spacingPayload,
            radii: radiiPayload,
            motion: motionPayload,
            charts: chartPayload
        )
    }

    static func overrides(from payload: ThemeOverridesPayload?) throws -> ThemeOverrides? {
        guard let payload else { return nil }

        let colors = try payload.colors.map { colorsPayload in
            ThemeColorOverrides(
                background: try color(from: colorsPayload.background),
                surface: try color(from: colorsPayload.surface),
                surfaceElevated: try color(from: colorsPayload.surfaceElevated),
                border: try color(from: colorsPayload.border),
                textPrimary: try color(from: colorsPayload.textPrimary),
                textSecondary: try color(from: colorsPayload.textSecondary),
                textTertiary: try color(from: colorsPayload.textTertiary),
                accentPrimary: try color(from: colorsPayload.accentPrimary),
                accentSecondary: try color(from: colorsPayload.accentSecondary),
                highlight: try color(from: colorsPayload.highlight),
                success: try color(from: colorsPayload.success),
                warning: try color(from: colorsPayload.warning),
                danger: try color(from: colorsPayload.danger),
                fillPressed: try color(from: colorsPayload.fillPressed),
                fillSelected: try color(from: colorsPayload.fillSelected),
                fillDisabled: try color(from: colorsPayload.fillDisabled)
            )
        }

        let spacing = payload.spacing.map {
            SpacingTokens(
                xs: CGFloat($0.xs),
                s: CGFloat($0.s),
                m: CGFloat($0.m),
                l: CGFloat($0.l),
                xl: CGFloat($0.xl),
                xxl: CGFloat($0.xxl)
            )
        }

        let radii = payload.radii.map {
            RadiusTokens(
                card: CGFloat($0.card),
                button: CGFloat($0.button),
                chip: CGFloat($0.chip),
                sheet: CGFloat($0.sheet)
            )
        }

        let motion = payload.motion.map {
            MotionTokens(
                fast: $0.fast,
                normal: $0.normal,
                slow: $0.slow
            )
        }

        let charts = try payload.charts.map { chartPayload in
            ChartOverrides(
                chart1: try color(from: chartPayload.chart1),
                chart2: try color(from: chartPayload.chart2),
                chart3: try color(from: chartPayload.chart3),
                chart4: try color(from: chartPayload.chart4),
                chart5: try color(from: chartPayload.chart5),
                chart6: try color(from: chartPayload.chart6),
                gridlineOpacity: chartPayload.gridlineOpacity,
                axisLabelOpacity: chartPayload.axisLabelOpacity
            )
        }

        if colors == nil &&
            spacing == nil &&
            radii == nil &&
            motion == nil &&
            charts == nil {
            return nil
        }

        return ThemeOverrides(
            colors: colors,
            spacing: spacing,
            radii: radii,
            motion: motion,
            charts: charts
        )
    }

    private static func color(from hex: String?) throws -> Color? {
        guard let hex else { return nil }
        return try parseHex(hex)
    }

    private static func hex(from color: Color?) throws -> String? {
        guard let color else { return nil }
        return try serializeHex(color)
    }

    private static func parseHex(_ hex: String) throws -> Color {
        let normalized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "#"))

        var raw: UInt64 = 0
        switch normalized.count {
        case 6, 8:
            guard Scanner(string: normalized).scanHexInt64(&raw) else {
                throw ThemeBackupCodecError.invalidColorHex(hex)
            }
        default:
            throw ThemeBackupCodecError.invalidColorHex(hex)
        }

        let a, r, g, b: UInt64
        if normalized.count == 6 {
            (a, r, g, b) = (255, raw >> 16, raw >> 8 & 0xFF, raw & 0xFF)
        } else {
            (a, r, g, b) = (raw >> 24, raw >> 16 & 0xFF, raw >> 8 & 0xFF, raw & 0xFF)
        }

        return Color(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }

    private static func serializeHex(_ color: Color) throws -> String {
        guard let components = colorComponents(color) else {
            throw ThemeBackupCodecError.colorEncodingUnsupported
        }

        let r = UInt8((components.r * 255).rounded())
        let g = UInt8((components.g * 255).rounded())
        let b = UInt8((components.b * 255).rounded())
        let a = UInt8((components.a * 255).rounded())

        return String(format: "#%02X%02X%02X%02X", a, r, g, b)
    }

    private static func colorComponents(_ color: Color) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? {
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
}
