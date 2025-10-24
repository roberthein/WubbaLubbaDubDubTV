// WubbaLubbaDubDubTV/WubbaLubbaDubDubTVApp.swift
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
            }
                .preferredColorScheme(.dark)
        }
        .modelContainer(container.modelContainer)
    }
}

@Observable
final class AppContainer {
    let rmService: RMServicing
    let episodesRepository: EpisodesRepository
    let charactersRepository: CharactersRepository
    let locationsRepository: LocationsRepository
    let modelContainer: ModelContainer

    init(rmService: RMServicing,
         episodesRepository: EpisodesRepository,
         charactersRepository: CharactersRepository,
         locationsRepository: LocationsRepository,
         modelContainer: ModelContainer) {
        self.rmService = rmService
        self.episodesRepository = episodesRepository
        self.charactersRepository = charactersRepository
        self.locationsRepository = locationsRepository
        self.modelContainer = modelContainer
    }

    static func bootstrap() -> AppContainer {
        let schema = Schema([EpisodeEntity.self, CharacterEntity.self, LocationEntity.self])
        let mc = try! ModelContainer(for: schema)
        let rm = RMService()
        let episodes = EpisodesRepository(rmService: rm, modelContext: mc.mainContext)
        let characters = CharactersRepository(rmService: rm, modelContext: mc.mainContext)
        let locations = LocationsRepository(rmService: rm, modelContext: mc.mainContext)
        return AppContainer(rmService: rm,
                            episodesRepository: episodes,
                            charactersRepository: characters,
                            locationsRepository: locations,
                            modelContainer: mc)
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
