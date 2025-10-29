import SwiftUI

/// A custom parallax scrolling effect that creates depth and visual interest.
///
/// This view implements a sophisticated parallax system that:
/// - Renders multiple layers of elements at different scroll speeds
/// - Uses Canvas for high-performance drawing
/// - Implements infinite scrolling with position wrapping
/// - Caches generated elements for optimal performance
/// - Supports customizable element counts, sizes, and spread patterns
///
/// The parallax effect is achieved by moving elements at different speeds relative
/// to the scroll offset, creating the illusion of depth and movement.
struct ParallaxView: View {
    var contentOffset: CGFloat
    let elementCount: Int
    let sizeRange: ClosedRange<CGFloat>
    let spreadFactor: CGFloat
    let clearCenter: Bool

    init(
        contentOffset: CGFloat = .zero,
        elementCount: Int = 32,
        sizeRange: ClosedRange<CGFloat> = 150...300,
        spreadFactor: CGFloat = 1,
        clearCenter: Bool = false
    ) {
        self.contentOffset = contentOffset
        self.elementCount = elementCount
        self.sizeRange = sizeRange
        self.spreadFactor = spreadFactor
        self.clearCenter = clearCenter
    }

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let elements = ParallaxElements.shared.getElements(
                    for: size,
                    count: elementCount,
                    sizeRange: sizeRange,
                    spreadFactor: spreadFactor
                )

                for element in elements {
                    let offsetY = -contentOffset * element.parallaxSpeed

                    let wrappedY = wrapPosition(
                        originalY: element.position.y,
                        offset: offsetY,
                        screenHeight: size.height,
                        squareSize: element.size
                    )

                    let scale = element.size / 250
                    let isLeft = (geometry.size.width / 2) > element.position.x
                    var x = element.position.x - ((element.size * scale) / 4)
                    let y = wrappedY

                    if clearCenter {
                        x += isLeft ? -100 : 100
                    }

                    if let image = context.resolveSymbol(id: element.id) {
                        var contextCopy = context

                        contextCopy.translateBy(x: x, y: y)
                        contextCopy.rotate(by: element.rotation)
                        contextCopy.scaleBy(x: scale, y: scale)

                        contextCopy.draw(
                            image,
                            at: .zero,
                            anchor: .center
                        )
                    }
                }
            } symbols: {
                let elements = ParallaxElements.shared.getElements(
                    for: geometry.size,
                    count: elementCount,
                    sizeRange: sizeRange,
                    spreadFactor: spreadFactor
                )

                ForEach(elements) { element in
                    RandomImageView()
                        .tag(element.id)
                }
            }
        }
    }

    /// Implements infinite scrolling by wrapping element positions around the screen bounds.
    ///
    /// This method ensures that parallax elements seamlessly wrap from bottom to top
    /// and vice versa, creating the illusion of infinite content scrolling.
    ///
    /// - Parameters:
    ///   - originalY: The original Y position of the element
    ///   - offset: The current scroll offset
    ///   - screenHeight: The height of the visible screen
    ///   - squareSize: The size of the element for proper wrapping calculations
    /// - Returns: The wrapped Y position that creates seamless infinite scrolling
    private func wrapPosition(originalY: CGFloat, offset: CGFloat, screenHeight: CGFloat, squareSize: CGFloat) -> CGFloat {
        let totalHeight = screenHeight + squareSize * 2
        var y = originalY + offset

        y = y.truncatingRemainder(dividingBy: totalHeight)
        if y < 0 {
            y += totalHeight
        }

        return y - squareSize
    }
}

/// A singleton class that manages parallax element generation and caching.
///
/// This class optimizes performance by:
/// - Caching generated elements based on screen size and parameters
/// - Generating elements with randomized properties for visual variety
/// - Using a grid-based layout system for consistent distribution
/// - Providing a shared instance to avoid duplicate element generation
class ParallaxElements {
    static let shared = ParallaxElements()

    private var elementsCache: [String: [ParallexElement]] = [:]

    func getElements(
        for size: CGSize,
        count: Int,
        sizeRange: ClosedRange<CGFloat>,
        spreadFactor: CGFloat
    ) -> [ParallexElement] {
        let key = "\(size.width)x\(size.height)_\(count)_\(sizeRange.lowerBound)-\(sizeRange.upperBound)_\(spreadFactor)"

        if let cached = elementsCache[key] {
            return cached
        }

        let elements = generateParallaxElements(
            for: size,
            count: count,
            sizeRange: sizeRange,
            spreadFactor: spreadFactor
        )
        elementsCache[key] = elements
        return elements
    }

    private func generateParallaxElements(
        for screenSize: CGSize,
        count: Int,
        sizeRange: ClosedRange<CGFloat>,
        spreadFactor: CGFloat
    ) -> [ParallexElement] {
        var elements: [ParallexElement] = []

        let symbolNames = [
            "star.fill", "heart.fill", "circle.fill", "square.fill",
            "triangle.fill", "diamond.fill", "hexagon.fill", "pentagon.fill",
            "cloud.fill", "sun.max.fill", "moon.fill", "sparkles",
            "bolt.fill", "flame.fill", "drop.fill", "snowflake"
        ]

        let columns = Int(sqrt(Double(count)) * 0.5)
        let rows = Int(ceil(Double(count) / Double(columns)))

        let cellWidth = screenSize.width / CGFloat(columns)
        let cellHeight = (screenSize.height * 1.5) / CGFloat(rows)

        var elementId = 0

        for row in 0..<rows {
            for col in 0..<columns {
                if elementId >= count { break }

                let baseCellX = CGFloat(col) * cellWidth
                let baseCellY = CGFloat(row) * cellHeight - screenSize.height * 0.25

                let padding: CGFloat = 20 / spreadFactor
                let spreadX = (cellWidth - padding * 2) * spreadFactor
                let spreadY = (cellHeight - padding * 2) * spreadFactor

                let x = baseCellX + padding + CGFloat.random(in: 0...max(1, spreadX))
                let y = baseCellY + padding + CGFloat.random(in: 0...max(1, spreadY))

                let size = CGFloat.random(in: sizeRange)

                let parallaxSpeed = CGFloat.random(in: 0.7...0.95)

                let rotation = Angle(degrees: Double.random(in: -45...45))

                let opacity = Double.random(in: 0.5...0.95)

                let cornerRadius = CGFloat.random(in: 5...25)

                let color = Color(
                    red: Double.random(in: 0.6...1),
                    green: Double.random(in: 0.6...1),
                    blue: Double.random(in: 0.6...1)
                )

                let symbolName = symbolNames.randomElement() ?? "star.fill"

                let element = ParallexElement(
                    id: elementId,
                    position: CGPoint(x: x, y: y),
                    size: size,
                    parallaxSpeed: parallaxSpeed,
                    rotation: rotation,
                    color: color,
                    opacity: opacity,
                    cornerRadius: cornerRadius,
                    symbolName: symbolName
                )

                elements.append(element)
                elementId += 1
            }
        }

        return elements
    }
}

struct ParallexElement: Identifiable {
    let id: Int
    let position: CGPoint
    let size: CGFloat
    let parallaxSpeed: CGFloat
    let rotation: Angle
    let color: Color
    let opacity: Double
    let cornerRadius: CGFloat
    let symbolName: String
}

#Preview {
    VStack {
        ParallaxView()
    }
}
