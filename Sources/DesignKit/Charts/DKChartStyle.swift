import SwiftUI
import Charts

public struct DKChartCardStyle: ViewModifier {
    private let theme: Theme

    public init(theme: Theme) {
        self.theme = theme
    }

    public func body(content: Content) -> some View {
        content
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine().foregroundStyle(theme.colors.textTertiary.opacity(theme.charts.gridlineOpacity))
                    if let date = value.as(Date.self) {
                        AxisValueLabel(date, format: .dateTime.month(.defaultDigits).day())
                            .foregroundStyle(theme.colors.textSecondary.opacity(theme.charts.axisLabelOpacity))
                    } else {
                        AxisValueLabel()
                            .foregroundStyle(theme.colors.textSecondary.opacity(theme.charts.axisLabelOpacity))
                    }
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine().foregroundStyle(theme.colors.textTertiary.opacity(theme.charts.gridlineOpacity))
                    AxisValueLabel().foregroundStyle(theme.colors.textSecondary.opacity(theme.charts.axisLabelOpacity))
                }
            }
    }
}

public extension View {
    func dkChartStyle(theme: Theme) -> some View {
        modifier(DKChartCardStyle(theme: theme))
    }
}
