// WubbaLubbaDubDubTV/Features/EpisodeDetail/EpisodeDetailView.swift
import SwiftUI
import SwiftData

struct EpisodeDetailView: View {
    @Environment(\.app) private var app
    @Environment(\.modelContext) private var context
    @Namespace private var episodeNamespace

    let episodeID: Int
    @State private var viewModel: EpisodeDetailViewModel?

    var body: some View {
        ZStack {
            RMPortalView(speed: 0.5)
                .ignoresSafeArea()
            
            List {
                if let episode = viewModel?.episode {
                    episodeSection(episode)
                    charactersSection(episode)
                } else {
                    loadingState()
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationBarBackButtonHidden()
        .task {
            if viewModel == nil {
                viewModel = EpisodeDetailViewModel(episodeID: episodeID,
                                                   charactersRepo: app.charactersRepository,
                                                   context: context)
                await viewModel?.prefetch()
            }
        }
    }

    @ViewBuilder
    private func episodeSection(_ episode: EpisodeEntity) -> some View {
        Section {
            EpisodeView(episode: episode, namespace: episodeNamespace)
                .padding(.vertical, 8)
        }
        .listRowBackground(Color.clear)
    }

    @ViewBuilder
    private func charactersSection(_ episode: EpisodeEntity) -> some View {
        if !episode.characterIDs.isEmpty {
            Section("Characters") {
                ForEach(episode.characterIDs, id: \.self) { id in
                    NavigationLink {
                        CharacterDetailView(characterID: id)
                    } label: {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundStyle(.blue)
                            Text("Character #\(id)")
                        }
                    }
                }
            }
            .listRowBackground(Color.clear)
        }
    }

    @ViewBuilder
    private func loadingState() -> some View {
        ForEach(0..<6, id: \.self) { _ in SkeletonRow() }
    }
}
