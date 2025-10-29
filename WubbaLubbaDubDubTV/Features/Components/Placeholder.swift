import SwiftUI

struct Placeholder {
    struct LoadingView: View {
        var body: some View {
            ZStack {
                Image("cell-1")
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(Color.rmYellow)
                    .padding(.horizontal, Padding.outer)

                LoadingIndicator(color: Color.rmBlueDark)
            }
        }
    }

    struct EndReachedView: View {
        var body: some View {
            ZStack {
                Image("cell-1")
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(Color.rmYellow)
                    .padding(.horizontal, Padding.outer)

                Text("the end".uppercased())
                    .font(CustomFont.primaryTitle)
                    .foregroundStyle(Color.rmBlueDark)
                    .lineLimit(1)
            }
            .padding(.top, Padding.outer)
        }
    }

    struct LoadingIndicator: View {
        let color: Color
        var body: some View {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .tint(color)
                .scaleEffect(1.5)
        }
    }
}
