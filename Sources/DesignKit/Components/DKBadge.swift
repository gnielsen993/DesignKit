import SwiftUI

public struct DKBadge: View {
    private let text: String
    private let theme: Theme

    public init(_ text: String, theme: Theme) {
        self.text = text
        self.theme = theme
    }

    public var body: some View {
        Text(text)
            .font(theme.typography.caption.weight(.semibold))
            .foregroundStyle(theme.colors.accentPrimary)
            .padding(.horizontal, theme.spacing.s)
            .padding(.vertical, theme.spacing.xs)
            .background(theme.colors.highlight)
            .clipShape(Capsule())
    }
}
