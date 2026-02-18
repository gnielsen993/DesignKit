import SwiftUI

public struct DKProgressRing: View {
    private let progress: Double
    private let lineWidth: CGFloat
    private let theme: Theme
    private let label: String

    public init(progress: Double, lineWidth: CGFloat = 10, label: String, theme: Theme) {
        self.progress = min(max(progress, 0), 1)
        self.lineWidth = lineWidth
        self.label = label
        self.theme = theme
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(theme.colors.highlight, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(theme.colors.accentPrimary, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(theme.motion.ease, value: progress)

            VStack(spacing: theme.spacing.xs) {
                Text("\(Int(progress * 100))%")
                    .font(theme.typography.title)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(label)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
    }
}
