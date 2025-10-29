import SwiftUI
import simd
import CoreGraphics

/// A custom view that renders animated portal effects using Metal shaders.
///
/// This view creates dynamic, time-based portal animations by:
/// - Using Metal shaders for high-performance GPU rendering
/// - Animating color gradients and patterns at 60fps
/// - Supporting customizable color schemes and animation speeds
/// - Leveraging `TimelineView` for smooth time-based updates
///
/// The portal effect is achieved through a custom Metal shader that creates
/// swirling, pulsing patterns reminiscent of Rick and Morty's portal technology.
public struct RMPortalView: View {
    public var c0: Color
    public var c1: Color
    public var c2: Color
    public var c3: Color
    public var speed: Float
    
    @State private var startDate = Date()
    
    public init(
        c0: Color = Color(.sRGB, red: 82/255, green: 189/255, blue: 144/255, opacity: 1),
        c1: Color = Color(.sRGB, red: 155/255, green: 205/255, blue: 117/255, opacity: 1),
        c2: Color = Color(.sRGB, red: 200/255, green: 221/255, blue: 116/255, opacity: 1),
        c3: Color = Color(.sRGB, red: 0.921, green: 0.980, blue: 0.847, opacity: 1),
        speed: Float = 1
    ) {
        self.c0 = c0
        self.c1 = c1
        self.c2 = c2
        self.c3 = c3
        self.speed = speed
    }
    
    public var body: some View {
        TimelineView(.periodic(from: startDate, by: 1/60)) { context in
            Canvas { ctx, size in
                let shader = self.makeRMPortalShader(size: size, date: context.date)
                let rect = CGRect(origin: .zero, size: size)
                ctx.fill(Path(rect), with: .shader(shader))
            }
        }
    }
    
    /// Creates a Metal shader with the current time and color parameters.
    ///
    /// This method configures the Metal shader by:
    /// - Converting SwiftUI colors to sRGB float3 values for the shader
    /// - Passing time-based animation parameters
    /// - Setting up the shader function from the app bundle
    ///
    /// - Parameters:
    ///   - size: The current size of the view for proper shader scaling
    ///   - date: The current date for time-based animation calculations
    /// - Returns: A configured Metal shader ready for rendering
    private func makeRMPortalShader(size: CGSize, date: Date) -> Shader {
        let t = Float(date.timeIntervalSince(startDate))
        let res = CGPoint(x: size.width, y: size.height)
        return Shader(
            function: .init(library: .bundle(.main), name: "RMPortalShader"),
            arguments: [
                .float(t),
                .float(speed),
                .float2(res),
                .float3(c0._srgbFloat3.x, c0._srgbFloat3.y, c0._srgbFloat3.z),
                .float3(c1._srgbFloat3.x, c1._srgbFloat3.y, c1._srgbFloat3.z),
                .float3(c2._srgbFloat3.x, c2._srgbFloat3.y, c2._srgbFloat3.z),
                .float3(c3._srgbFloat3.x, c3._srgbFloat3.y, c3._srgbFloat3.z)
            ]
        )
    }
}

private extension Color {
    var _srgbFloat3: simd_float3 {
        let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!
        if let cg = self.cgColor?.converted(to: sRGB, intent: .relativeColorimetric, options: nil),
           let comps = cg.components {
            if comps.count >= 3 {
                return simd_float3(Float(comps[0]), Float(comps[1]), Float(comps[2]))
            } else if comps.count == 2 {
                return simd_float3(Float(comps[0]), Float(comps[0]), Float(comps[0]))
            }
        }
        return simd_float3(0, 0, 0)
    }
}

#Preview {
    RMPortalView()
        .ignoresSafeArea()
}
