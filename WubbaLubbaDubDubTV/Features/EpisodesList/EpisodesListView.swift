// WubbaLubbaDubDubTV/Features/EpisodesList/EpisodesListView.swift
import SwiftUI
import SwiftData

struct EpisodesListView: View {
    @Environment(\.app) private var app
    @Environment(\.modelContext) private var context
    @State private var scrollOffset = CGFloat.zero
    @Namespace private var episodeNamespace

    @Query(sort: [SortDescriptor(\EpisodeEntity.id, order: .forward)])
    private var episodes: [EpisodeEntity]
    
    @State private var viewModel: EpisodesListViewModel?

    var body: some View {
        ZStack {
            backgroundParallax()
            
            List {
                episodeList()
                
                if (viewModel?.isLoading ?? false) {
                    SkeletonRow()
                } else if (viewModel?.isAtEnd ?? false) {
                    endReachedMessage()
                }
            }
            .scrollContentBackground(.hidden)
            .onScrollGeometryChange(for: CGFloat.self) { proxy in
                proxy.contentOffset.y + proxy.contentInsets.top
            } action: { oldValue, newValue in
                scrollOffset = newValue
            }
            .task {
                await setupViewModel()
            }
            .refreshable {
                await refreshData()
            }
            
            foregroundParallax()
        }
    }

    @ViewBuilder
    private func backgroundParallax() -> some View {
        ParallaxView(
            contentOffset: scrollOffset,
            elementCount: 80,
            sizeRange: 150...300,
            spreadFactor: 2.0
        )
        .ignoresSafeArea()
        .background(Color(.rmBlueDark))
    }

    @ViewBuilder
    private func foregroundParallax() -> some View {
        ParallaxView(
            contentOffset: scrollOffset,
            elementCount: 30,
            sizeRange: 50...150,
            spreadFactor: 2
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
                    .padding(5)
                    .padding(5)
            }
        }
        .listRowBackground(Color.clear)
    }

    @ViewBuilder
    private func endReachedMessage() -> some View {
        HStack {
            Spacer()
            VStack(spacing: 4) {
                Text("You've reached the end.")
                    .font(.footnote).foregroundStyle(.secondary)
                Text("\(episodes.count) episodes loaded")
                    .font(.caption2).foregroundStyle(.tertiary)
                Text("⚠️ API only has seasons 1-5")
                    .font(.caption2).foregroundStyle(.orange)
            }
            Spacer()
        }
        .padding(.vertical, 8)
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
    }
}
