import SwiftUI

public struct ThemeColors {
    public let background: Color
    public let surface: Color
    public let surfaceElevated: Color
    public let border: Color
    public let textPrimary: Color
    public let textSecondary: Color
    public let textTertiary: Color
    public let accentPrimary: Color
    public let accentSecondary: Color
    public let highlight: Color
    public let success: Color
    public let warning: Color
    public let danger: Color
    public let fillPressed: Color
    public let fillSelected: Color
    public let fillDisabled: Color

    public init(
        background: Color,
        surface: Color,
        surfaceElevated: Color,
        border: Color,
        textPrimary: Color,
        textSecondary: Color,
        textTertiary: Color,
        accentPrimary: Color,
        accentSecondary: Color,
        highlight: Color,
        success: Color,
        warning: Color,
        danger: Color,
        fillPressed: Color,
        fillSelected: Color,
        fillDisabled: Color
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

public struct ChartTokens {
    public let chart1: Color
    public let chart2: Color
    public let chart3: Color
    public let chart4: Color
    public let chart5: Color
    public let chart6: Color
    public let gridlineOpacity: Double
    public let axisLabelOpacity: Double

    public init(
        chart1: Color,
        chart2: Color,
        chart3: Color,
        chart4: Color,
        chart5: Color,
        chart6: Color,
        gridlineOpacity: Double,
        axisLabelOpacity: Double
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
