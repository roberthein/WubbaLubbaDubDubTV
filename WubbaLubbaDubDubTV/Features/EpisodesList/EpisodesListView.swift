import SwiftUI
import SwiftData

struct EpisodesListView: View {
    @Environment(\.app) private var app
    @Environment(\.modelContext) private var context
    @State private var scrollOffset = CGFloat.zero
    @Namespace private var episodeNamespace
    @State private var refreshId = UUID()

    @Query(sort: [SortDescriptor(\EpisodeEntity.id, order: .forward)])
    private var episodes: [EpisodeEntity]
    
    @State private var viewModel: EpisodesListViewModel?

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

                if (viewModel?.isLoading ?? false) {
                    Placeholder.LoadingView()
                } else if (viewModel?.isAtEnd ?? false) {
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
        ForEach(Array(episodes.enumerated()), id: \.element.id) { index, episode in
            NavigationLink {
                EpisodeDetailView(episodeID: episode.id)
                    .navigationTransition(.zoom(sourceID: "episode_\(episode.id)", in: episodeNamespace))
            } label: {
                EpisodeView(episode: episode, namespace: episodeNamespace)
                    .onAppear {
                        if index >= episodes.count - 1 {
                            Task { await viewModel?.loadNextPageIfNeeded() }
                        }
                    }
                    .padding(.horizontal, Padding.outer)
            }
        }
        .listRowBackground(Color.clear)
    }

    private func setupViewModel() async {
        if viewModel == nil {
            viewModel = EpisodesListViewModel(repo: app.episodesRepository)
        }
        if episodes.isEmpty {
            let checker = APIInfoChecker()
            _ = try? await checker.checkTotalEpisodes()
            await viewModel?.loadNextPageIfNeeded()
        }
    }

    private func refreshData() async {
        await MainActor.run {
            do {
                let eps = try context.fetch(FetchDescriptor<EpisodeEntity>())
                for e in eps { context.delete(e) }
                let chars = try context.fetch(FetchDescriptor<CharacterEntity>())
                for c in chars { context.delete(c) }
                try context.save()
            } catch {
#if DEBUG
                print("Refresh reset failed:", error)
#endif
            }
        }
        app.episodesRepository.reset()
        await viewModel?.loadNextPageIfNeeded()
        
        await MainActor.run {
            refreshId = UUID()
        }
    }
}
