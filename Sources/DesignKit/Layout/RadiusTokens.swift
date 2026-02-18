import Foundation

public struct RadiusTokens {
    public let card: CGFloat
    public let button: CGFloat
    public let chip: CGFloat
    public let sheet: CGFloat

    public init(
        card: CGFloat = 16,
        button: CGFloat = 14,
        chip: CGFloat = 12,
        sheet: CGFloat = 22
    ) {
        self.card = card
        self.button = button
        self.chip = chip
        self.sheet = sheet
    }
}
