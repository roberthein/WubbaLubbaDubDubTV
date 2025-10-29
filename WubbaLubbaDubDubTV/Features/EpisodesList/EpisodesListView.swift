import SwiftUI
import SwiftData

struct EpisodesListView: View {
    @Environment(\.app) private var app
    @State private var scrollOffset = CGFloat.zero
    @Namespace private var episodeNamespace
    @State private var refreshId = UUID()
    @State private var hasTriggeredInitialLoad = false
    @State private var lastLoadedPage = 0
    @State private var showLoadMoreTrigger = false

    private var viewModel: EpisodesListViewModel {
        app.getEpisodesListViewModel()
    }

    var body: some View {
        ZStack {
            RepeatingPatternView()
                .ignoresSafeArea()

            backgroundParallax()

            listView()
                .task { await setupViewModel() }
                .id(refreshId)

            foregroundParallax()
        }
    }

    @ViewBuilder
    private func headerView() -> some View {
        Image("rm-header")
            .resizable()
            .scaledToFit()
            .padding([.horizontal, .top], Padding.outer)
            .padding(.bottom, -Padding.outer)
    }

    @ViewBuilder
    private func listView() -> some View {
        ScrollView {
            headerView()

            LazyVStack(spacing: Padding.innerHalf) {
                episodeList()
                
                loadMoreTrigger()

                if viewModel.isLoading {
                    Placeholder.LoadingView()
                } else if viewModel.isAtEnd {
                    Placeholder.EndReachedView()
                }
            }
        }
        .customRefresh {
            await refreshData()
        }
        .onScrollGeometryChange(for: CGFloat.self) { proxy in
            proxy.contentOffset.y + proxy.contentInsets.top
        } action: { oldValue, newValue in
            scrollOffset = newValue
            checkScrollPosition()
        }
    }

    @ViewBuilder
    private func backgroundParallax() -> some View {
        ParallaxView(
            contentOffset: scrollOffset,
            elementCount: 80,
            sizeRange: 150...300,
            spreadFactor: 2
        )
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func foregroundParallax() -> some View {
        ParallaxView(
            contentOffset: scrollOffset,
            elementCount: 50,
            sizeRange: 50...120,
            spreadFactor: 2,
            clearCenter: true
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func episodeList() -> some View {
        ForEach(Array(viewModel.episodes.enumerated()), id: \.element.id) { index, episode in
            NavigationLink {
                EpisodeDetailView(episodeID: episode.id)
                    .navigationTransition(.zoom(sourceID: "episode_\(episode.id)", in: episodeNamespace))
            } label: {
                EpisodeView(episode: episode, namespace: episodeNamespace)
                    .padding(.horizontal, Padding.outer)
            }
        }
        .listRowBackground(Color.clear)
    }

    @ViewBuilder
    private func loadMoreTrigger() -> some View {
        if !viewModel.episodes.isEmpty && !viewModel.isAtEnd && !viewModel.isLoading && showLoadMoreTrigger {
            Color.clear
                .frame(height: 1)
                .onAppear {
                    Task { await loadNextPageIfNeeded() }
                }
        }
    }
    
    private func checkScrollPosition() {
        guard hasTriggeredInitialLoad else { return }
        
        let threshold: CGFloat = 1000
        showLoadMoreTrigger = scrollOffset > threshold
    }
    
    private func loadNextPageIfNeeded() async {
        guard !viewModel.isLoading && !viewModel.isAtEnd else { return }
        
        let currentPage = viewModel.episodes.count / 20 + 1
        guard currentPage > lastLoadedPage else { return }
        
        showLoadMoreTrigger = false
        lastLoadedPage = currentPage
        
        await viewModel.loadNextPageIfNeeded()
    }
    
    private func setupViewModel() async {
        if viewModel.episodes.isEmpty {
            await viewModel.loadNextPageIfNeeded()
            hasTriggeredInitialLoad = true
            lastLoadedPage = 1
        }
    }

    private func refreshData() async {
        await viewModel.refreshData()
        
        await MainActor.run {
            refreshId = UUID()
            hasTriggeredInitialLoad = true
            lastLoadedPage = 1
            showLoadMoreTrigger = false
        }
    }
}
