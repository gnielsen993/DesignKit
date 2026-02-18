import SwiftUI

public struct DKSectionHeader: View {
    private let title: String
    private let subtitle: String?
    private let theme: Theme

    public init(_ title: String, subtitle: String? = nil, theme: Theme) {
        self.title = title
        self.subtitle = subtitle
        self.theme = theme
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(title)
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
    }
}
