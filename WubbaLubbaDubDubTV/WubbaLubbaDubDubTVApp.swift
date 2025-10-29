import SwiftUI
import SwiftData
import Observation

@main
struct WubbaLubbaDubDubTVApp: App {
    @State private var container = AppContainer.bootstrap()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                EpisodesListView()
                    .environment(container)
                    .preferredColorScheme(.dark)
            }
        }
        .modelContainer(container.modelContainer)
    }
}

@Observable
final class AppContainer {
    let rmService: RMServicing
    let episodesRepository: EpisodesRepository
    let charactersRepository: CharactersRepository
    let modelContainer: ModelContainer
    
    private(set) var episodesListViewModel: EpisodesListViewModel?
    private(set) var characterDetailViewModels: [Int: CharacterDetailViewModel] = [:]
    private(set) var episodeDetailViewModels: [Int: EpisodeDetailViewModel] = [:]

    init(
        rmService: RMServicing,
        episodesRepository: EpisodesRepository,
        charactersRepository: CharactersRepository,
        modelContainer: ModelContainer
    ) {
        self.rmService = rmService
        self.episodesRepository = episodesRepository
        self.charactersRepository = charactersRepository
        self.modelContainer = modelContainer
    }
    
    func getEpisodesListViewModel() -> EpisodesListViewModel {
        if episodesListViewModel == nil {
            episodesListViewModel = EpisodesListViewModel(repo: episodesRepository, context: modelContainer.mainContext)
        }
        return episodesListViewModel!
    }
    
    func getCharacterDetailViewModel(id: Int) -> CharacterDetailViewModel {
        if characterDetailViewModels[id] == nil {
            characterDetailViewModels[id] = CharacterDetailViewModel(id: id, repo: charactersRepository)
        }
        return characterDetailViewModels[id]!
    }
    
    func getEpisodeDetailViewModel(id: Int, context: ModelContext) -> EpisodeDetailViewModel {
        if episodeDetailViewModels[id] == nil {
            episodeDetailViewModels[id] = EpisodeDetailViewModel(
                episodeID: id,
                charactersRepo: charactersRepository,
                context: context
            )
        }
        return episodeDetailViewModels[id]!
    }

    static func bootstrap() -> AppContainer {
        let schema = Schema([EpisodeEntity.self, CharacterEntity.self])
        let mc = try! ModelContainer(for: schema)
        let rm = RMService()
        let episodes = EpisodesRepository(rmService: rm, modelContext: mc.mainContext)
        let characters = CharactersRepository(rmService: rm, modelContext: mc.mainContext)
        return AppContainer(
            rmService: rm,
            episodesRepository: episodes,
            charactersRepository: characters,
            modelContainer: mc
        )
    }
}

private struct AppContainerKey: EnvironmentKey {
    static let defaultValue: AppContainer = .bootstrap()
}

extension EnvironmentValues {
    var app: AppContainer {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}

extension View {
    func environment(_ app: AppContainer) -> some View {
        environment(\.app, app)
    }
}
