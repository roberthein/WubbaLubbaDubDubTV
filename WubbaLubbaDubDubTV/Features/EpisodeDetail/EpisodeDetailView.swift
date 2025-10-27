import SwiftUI
import SwiftData

struct EpisodeDetailView: View {
    @Environment(\.app) private var app
    @Environment(\.modelContext) private var context
    @Namespace private var episodeNamespace
    @Namespace private var characterNamespace
    @State private var scrollOffset = CGFloat.zero

    let episodeID: Int
    @State private var viewModel: EpisodeDetailViewModel?

    var body: some View {
        ZStack {
            RepeatingPatternView()
                .ignoresSafeArea()

            backgroundParallax()

            ScrollView {
                LazyVStack(spacing: Padding.innerHalf) {
                    if let episode = viewModel?.episode {
                        episodeSection(episode)
                        charactersSection(episode)
                    } else {
                        Placeholder.LoadingView()
                    }
                }
                .padding(.horizontal, Padding.outer)
            }
            .onScrollGeometryChange(for: CGFloat.self) { proxy in
                proxy.contentOffset.y + proxy.contentInsets.top
            } action: { oldValue, newValue in
                scrollOffset = newValue
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            if viewModel == nil {
                viewModel = EpisodeDetailViewModel(
                    episodeID: episodeID,
                    charactersRepo: app.charactersRepository,
                    context: context
                )
                await viewModel?.prefetch()
            }
        }
    }

    @ViewBuilder
    private func backgroundParallax() -> some View {
        ParallaxView(
            contentOffset: scrollOffset,
            elementCount: 30,
            sizeRange: 50...150,
            spreadFactor: 2
        )
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func episodeSection(_ episode: EpisodeEntity) -> some View {
        EpisodeView(episode: episode, namespace: episodeNamespace)
            .padding(.vertical, 8)
    }

    @ViewBuilder
    private func charactersSection(_ episode: EpisodeEntity) -> some View {
        if !episode.characterIDs.isEmpty {
            ForEach(episode.characterIDs, id: \.self) { id in
                NavigationLink {
                    CharacterDetailView(characterID: id)
                        .navigationTransition(.zoom(sourceID: "character_\(id)", in: characterNamespace))
                } label: {
                    CharacterView(characterID: id, namespace: characterNamespace)
                }
            }
        }
    }
}

