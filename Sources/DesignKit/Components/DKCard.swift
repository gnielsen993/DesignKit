import SwiftUI

public struct DKCard<Content: View>: View {
    private let theme: Theme
    private let content: Content

    public init(theme: Theme, @ViewBuilder content: () -> Content) {
        self.theme = theme
        self.content = content()
    }

    public var body: some View {
        content
            .padding(theme.spacing.l)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.radii.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.card, style: .continuous)
                    .stroke(theme.colors.border, lineWidth: 1)
            )
    }
}
