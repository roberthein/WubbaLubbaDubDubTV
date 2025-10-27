import SwiftUI

public extension ScrollView {
    func customRefresh(onRefresh: @escaping RefreshAction) -> some View {
        ScrollWithRefreshView(
            content: { self },
            onRefresh: onRefresh
        )
    }
}

public typealias RefreshAction = () async -> ()

public struct ScrollWithRefreshView<Content: View>: View {
    let content: Content
    let onRefresh: RefreshAction
    @State private var isRefreshing: Bool = false
    @State private var scrollOffset = CGFloat.zero

    public init(
        @ViewBuilder content: () -> Content,
        onRefresh: @escaping RefreshAction
    ) {
        self.onRefresh = onRefresh
        self.content = content()
    }

    private let amountToPullBeforeRefreshing: CGFloat = 180

    public var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                refreshView()
                content
            }
        }
        .onScrollGeometryChange(for: CGFloat.self) { proxy in
            proxy.contentOffset.y + proxy.contentInsets.top
        } action: { oldValue, newValue in
            scrollOffset = min(amountToPullBeforeRefreshing, min(0, newValue) * -1)
            if newValue < -amountToPullBeforeRefreshing && !isRefreshing {
                isRefreshing = true
                Task {
                    await onRefresh()
                    isRefreshing = false
                }
            }
        }
        .sensoryFeedback(.selection, trigger: isRefreshing)
    }

    @ViewBuilder
    private func refreshView() -> some View {
        Capsule(style: .continuous)
            .foregroundStyle(.white)
            .frame(width: 50 - (scrollOffset / 5), height: scrollOffset)
            .offset(x: 0, y: -scrollOffset)
            .opacity(isRefreshing ? 0 : 1)
    }
}
