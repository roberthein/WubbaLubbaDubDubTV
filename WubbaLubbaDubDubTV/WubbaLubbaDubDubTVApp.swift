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

/// A dependency injection container that manages the app's core services and view models.
///
/// The `AppContainer` follows the singleton pattern and provides centralized access to:
/// - API services for Rick and Morty data
/// - Repository layers for data persistence
/// - View model instances with lazy initialization
/// - SwiftData model container for local storage
///
/// This container ensures proper dependency management and enables easy testing by allowing
/// mock services to be injected during initialization.
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
    
    /// Returns the episodes list view model, creating it lazily if needed.
    ///
    /// This method implements lazy initialization to ensure the view model is only created
    /// when actually needed, improving app startup performance.
    ///
    /// - Returns: The shared `EpisodesListViewModel` instance.
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

    /// Creates and configures a new `AppContainer` with all required dependencies.
    ///
    /// This factory method sets up the complete dependency graph:
    /// 1. Creates SwiftData model container with episode and character schemas
    /// 2. Initializes the Rick and Morty API service
    /// 3. Creates repository instances with proper dependencies
    /// 4. Returns a fully configured container ready for use
    ///
    /// - Returns: A fully configured `AppContainer` instance.
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
