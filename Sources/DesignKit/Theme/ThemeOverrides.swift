import SwiftUI

public struct ThemeColorOverrides {
    public var background: Color?
    public var surface: Color?
    public var surfaceElevated: Color?
    public var border: Color?
    public var textPrimary: Color?
    public var textSecondary: Color?
    public var textTertiary: Color?
    public var accentPrimary: Color?
    public var accentSecondary: Color?
    public var highlight: Color?
    public var success: Color?
    public var warning: Color?
    public var danger: Color?
    public var fillPressed: Color?
    public var fillSelected: Color?
    public var fillDisabled: Color?

    public init(
        background: Color? = nil,
        surface: Color? = nil,
        surfaceElevated: Color? = nil,
        border: Color? = nil,
        textPrimary: Color? = nil,
        textSecondary: Color? = nil,
        textTertiary: Color? = nil,
        accentPrimary: Color? = nil,
        accentSecondary: Color? = nil,
        highlight: Color? = nil,
        success: Color? = nil,
        warning: Color? = nil,
        danger: Color? = nil,
        fillPressed: Color? = nil,
        fillSelected: Color? = nil,
        fillDisabled: Color? = nil
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

    func applying(to base: ThemeColors) -> ThemeColors {
        ThemeColors(
            background: background ?? base.background,
            surface: surface ?? base.surface,
            surfaceElevated: surfaceElevated ?? base.surfaceElevated,
            border: border ?? base.border,
            textPrimary: textPrimary ?? base.textPrimary,
            textSecondary: textSecondary ?? base.textSecondary,
            textTertiary: textTertiary ?? base.textTertiary,
            accentPrimary: accentPrimary ?? base.accentPrimary,
            accentSecondary: accentSecondary ?? base.accentSecondary,
            highlight: highlight ?? base.highlight,
            success: success ?? base.success,
            warning: warning ?? base.warning,
            danger: danger ?? base.danger,
            fillPressed: fillPressed ?? base.fillPressed,
            fillSelected: fillSelected ?? base.fillSelected,
            fillDisabled: fillDisabled ?? base.fillDisabled
        )
    }
}

public struct ChartOverrides {
    public var chart1: Color?
    public var chart2: Color?
    public var chart3: Color?
    public var chart4: Color?
    public var chart5: Color?
    public var chart6: Color?
    public var gridlineOpacity: Double?
    public var axisLabelOpacity: Double?

    public init(
        chart1: Color? = nil,
        chart2: Color? = nil,
        chart3: Color? = nil,
        chart4: Color? = nil,
        chart5: Color? = nil,
        chart6: Color? = nil,
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

    func applying(to base: ChartTokens) -> ChartTokens {
        ChartTokens(
            chart1: chart1 ?? base.chart1,
            chart2: chart2 ?? base.chart2,
            chart3: chart3 ?? base.chart3,
            chart4: chart4 ?? base.chart4,
            chart5: chart5 ?? base.chart5,
            chart6: chart6 ?? base.chart6,
            gridlineOpacity: gridlineOpacity ?? base.gridlineOpacity,
            axisLabelOpacity: axisLabelOpacity ?? base.axisLabelOpacity
        )
    }
}

public struct ThemeOverrides {
    public var colors: ThemeColorOverrides?
    public var typography: TypographyTokens?
    public var spacing: SpacingTokens?
    public var radii: RadiusTokens?
    public var motion: MotionTokens?
    public var charts: ChartOverrides?

    public init(
        colors: ThemeColorOverrides? = nil,
        typography: TypographyTokens? = nil,
        spacing: SpacingTokens? = nil,
        radii: RadiusTokens? = nil,
        motion: MotionTokens? = nil,
        charts: ChartOverrides? = nil
    ) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.radii = radii
        self.motion = motion
        self.charts = charts
    }
}
