import SwiftUI

struct RepeatingPatternView: View {
    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("rm-pattern")
                    .resizable(resizingMode: .tile)
                    .frame(
                        width: geometry.size.width + 120,
                        height: geometry.size.height + 120
                    )
                    .offset(x: offset - 120, y: -offset)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                offset = 120
            }
        }
    }
}
