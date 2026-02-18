import SwiftUI

public struct TypographyTokens {
    public let titleLarge: Font
    public let title: Font
    public let headline: Font
    public let body: Font
    public let caption: Font
    public let monoNumber: Font

    public init(
        titleLarge: Font = .system(size: 32, weight: .bold, design: .rounded),
        title: Font = .title2.weight(.semibold),
        headline: Font = .headline,
        body: Font = .body,
        caption: Font = .caption,
        monoNumber: Font = .system(.body, design: .monospaced)
    ) {
        self.titleLarge = titleLarge
        self.title = title
        self.headline = headline
        self.body = body
        self.caption = caption
        self.monoNumber = monoNumber
    }
}
