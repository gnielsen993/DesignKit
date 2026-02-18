import SwiftUI

public enum DKButtonStyle {
    case primary
    case secondary
}

public struct DKButton: View {
    private let title: String
    private let style: DKButtonStyle
    private let theme: Theme
    private let action: () -> Void

    public init(
        _ title: String,
        style: DKButtonStyle = .primary,
        theme: Theme,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.theme = theme
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(theme.typography.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, theme.spacing.m)
        }
        .buttonStyle(.plain)
        .foregroundStyle(foreground)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: theme.radii.button, style: .continuous))
    }

    private var foreground: Color {
        switch style {
        case .primary: theme.colors.surfaceElevated
        case .secondary: theme.colors.textPrimary
        }
    }

    private var background: Color {
        switch style {
        case .primary: theme.colors.accentPrimary
        case .secondary: theme.colors.highlight
        }
    }
}
