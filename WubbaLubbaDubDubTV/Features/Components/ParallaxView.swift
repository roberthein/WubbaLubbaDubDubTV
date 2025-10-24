import SwiftUI

struct ParallaxView: View {
    var contentOffset: CGFloat
    let elementCount: Int
    let sizeRange: ClosedRange<CGFloat>
    let spreadFactor: CGFloat

    init(
        contentOffset: CGFloat = .zero,
        elementCount: Int = 32,
        sizeRange: ClosedRange<CGFloat> = 150...300,
        spreadFactor: CGFloat = 1.0
    ) {
        self.contentOffset = contentOffset
        self.elementCount = elementCount
        self.sizeRange = sizeRange
        self.spreadFactor = spreadFactor
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
                    let x = element.position.x - ((element.size * scale) / 4)
                    let y = wrappedY

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
                    red: Double.random(in: 0.6...1.0),
                    green: Double.random(in: 0.6...1.0),
                    blue: Double.random(in: 0.6...1.0)
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
