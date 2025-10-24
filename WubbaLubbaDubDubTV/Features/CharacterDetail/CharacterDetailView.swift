// WubbaLubbaDubDubTV/Features/CharacterDetail/CharacterDetailView.swift
import SwiftUI

struct CharacterDetailView: View {
    @Environment(\.app) private var app
    let characterID: Int
    @State private var vm: CharacterDetailViewModel?

    var body: some View {
        Group {
            if let vm = vm {
                if let c = vm.character {
                    characterContent(c)
                } else if vm.isLoading {
                    loadingState()
                } else if let err = vm.error {
                    errorState(err, vm: vm)
                } else {
                    emptyState()
                }
            } else {
                initializingState()
            }
        }
        .navigationTitle("Character #\(characterID)")
        .task {
            if vm == nil {
                vm = CharacterDetailViewModel(id: characterID, repo: app.charactersRepository)
                await vm?.load()
            }
        }
    }

    @ViewBuilder
    private func characterContent(_ character: CharacterEntity) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                characterImage(character)
                characterInfo(character)
            }
            .padding()
        }
    }

    @ViewBuilder
    private func characterImage(_ character: CharacterEntity) -> some View {
        AsyncImage(url: character.imageURL) { phase in
            switch phase {
            case .empty:
                Rectangle().fill(.secondary.opacity(0.2)).aspectRatio(1, contentMode: .fit).redacted(reason: .placeholder)
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fit).clipShape(RoundedRectangle(cornerRadius: 12))
            case .failure:
                Image(systemName: "person.crop.square").resizable().scaledToFit()
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxWidth: 300)
    }

    @ViewBuilder
    private func characterInfo(_ character: CharacterEntity) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(character.name).font(.title.bold())
            Text("\(character.species) • \(character.status)").font(.subheadline).foregroundStyle(.secondary)
            Divider()
            LabeledContent("Origin", value: character.originName)
            LabeledContent("Episodes", value: "\(character.episodeCount)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func loadingState() -> some View {
        VStack(spacing: 12) {
            ForEach(0..<6, id: \.self) { _ in SkeletonRow() }
        }
        .padding()
    }

    @ViewBuilder
    private func errorState(_ error: String, vm: CharacterDetailViewModel) -> some View {
        VStack(spacing: 12) {
            Text("Failed to load").font(.headline)
            Text(error).font(.footnote).foregroundStyle(.secondary)
            Button("Retry") { Task { await vm.load() } }
        }
        .padding()
    }

    @ViewBuilder
    private func emptyState() -> some View {
        Text("No data available")
            .foregroundStyle(.secondary)
            .padding()
    }

    @ViewBuilder
    private func initializingState() -> some View {
        ProgressView("Initializing...")
            .padding()
    }
}
