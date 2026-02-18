import SwiftUI

public struct MotionTokens {
    public let fast: Double
    public let normal: Double
    public let slow: Double

    public init(
        fast: Double = 0.18,
        normal: Double = 0.28,
        slow: Double = 0.40
    ) {
        self.fast = fast
        self.normal = normal
        self.slow = slow
    }

    public var ease: Animation { .easeInOut(duration: normal) }
}
