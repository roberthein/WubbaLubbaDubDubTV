import SwiftUI

struct Padding {
    static let outer: CGFloat = 24
    static let outerDouble: CGFloat = outer * 2
    static let outerHalf: CGFloat = outer / 2

    static let inner: CGFloat = 8
    static let innerDouble: CGFloat = inner * 2
    static let innerHalf: CGFloat = inner / 2
}

struct CustomFont {
    static let primaryTitle: Font = .system(size: 16, weight: .black, design: .rounded)
    static let primarySubtitle: Font = .system(size: 14, weight: .semibold, design: .rounded)
    static let secondaryTitle: Font = .system(size: 24, weight: .black, design: .rounded)
    static let secondarySubtitle: Font = .system(size: 18, weight: .semibold, design: .rounded)
}
