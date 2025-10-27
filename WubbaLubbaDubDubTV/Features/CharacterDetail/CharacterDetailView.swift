import SwiftUI

struct CharacterDetailView: View {
    @Environment(\.app) private var app
    let characterID: Int
    @State private var vm: CharacterDetailViewModel?
    @Namespace private var characterNamespace

    var body: some View {
        ZStack {
            RMPortalView(speed: 0.5)
                .ignoresSafeArea()

            VStack {
                characterTitle()

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
            .padding([.horizontal, .top], Padding.outer)
        }
        .navigationBarBackButtonHidden()
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
            VStack(spacing: .zero) {
                Spacer()
                VStack(spacing: -Padding.outerDouble) {
                    characterImage(character)
                    characterInfo(character)
                }
                Spacer()
            }
            .frame(maxHeight: .infinity)
        }
        .scrollClipDisabled()
    }

    @ViewBuilder
    private func characterTitle() -> some View {
        CharacterView(
            characterID: characterID,
            namespace: characterNamespace
        )
    }

    @ViewBuilder
    private func characterImage(_ character: CharacterEntity) -> some View {
        AsyncImage(url: character.imageURL) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(.secondary.opacity(0.2))
                    .aspectRatio(1, contentMode: .fill)
                    .redacted(reason: .placeholder)
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Image(systemName: "person.crop.square")
                    .resizable()
                    .scaledToFit()
            @unknown default:
                EmptyView()
            }
        }
        .mask {
            Image("blob-1")
        }
        .frame(width: 320, height: 335)
    }

    @ViewBuilder
    private func characterInfo(_ character: CharacterEntity) -> some View {
        Color.rmPinkLight
            .frame(width: 320, height: 240)
            .mask {
                Image("blob-2")
            }
            .overlay {
                VStack(spacing: Padding.inner) {
                    Text(character.name)
                        .font(CustomFont.secondaryTitle)
                        .foregroundStyle(Color.rmBlueDark)

                    Text("\(character.species) • \(character.status)")
                        .font(CustomFont.secondarySubtitle)
                        .foregroundStyle(Color.rmBlueDark)

                    Divider()

                    LabeledContent("Origin", value: character.originName)
                        .font(CustomFont.secondarySubtitle)
                        .foregroundStyle(Color.rmBlueDark)
                    LabeledContent("Episodes", value: "\(character.episodeCount)")
                        .font(CustomFont.secondarySubtitle)
                        .foregroundStyle(Color.rmBlueDark)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, Padding.outerDouble)
                .padding(.horizontal, Padding.outer)
            }
    }

    @ViewBuilder
    private func loadingState() -> some View {
        Placeholder.LoadingView()
    }

    @ViewBuilder
    private func errorState(_ error: String, vm: CharacterDetailViewModel) -> some View {
        VStack(spacing: 12) {
            Text("Failed to load")
                .font(CustomFont.secondaryTitle)
                .foregroundStyle(Color.rmPink)

            Text(error)
                .font(CustomFont.secondarySubtitle)
                .foregroundStyle(Color.rmPink)

            Button {
                Task { await vm.load() }
            } label: {
                Text("Retry")
                    .font(CustomFont.secondaryTitle)
                    .foregroundStyle(Color.rmPink)
            }
        }
        .padding()
    }

    @ViewBuilder
    private func emptyState() -> some View {
        Text("No data available")
            .font(CustomFont.secondaryTitle)
            .foregroundStyle(Color.rmPink)
    }

    @ViewBuilder
    private func initializingState() -> some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .tint(Color.rmPinkLight)
            .scaleEffect(1.5)
    }
}
