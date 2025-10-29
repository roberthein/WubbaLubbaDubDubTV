import Foundation
import SwiftData
import RickMortySwiftApi

/// A repository that manages episode data persistence and API synchronization.
///
/// This repository handles:
/// - Paginated episode loading from the Rick and Morty API
/// - Local data persistence using SwiftData
/// - Upsert operations to prevent duplicate data
/// - Character ID extraction and parsing from episode URLs
///
/// The repository acts as a bridge between the API service and the local database,
/// ensuring data consistency and providing efficient caching mechanisms.
@MainActor
final class EpisodesRepository {
    private let rmService: RMServicing
    private let context: ModelContext
    
    private(set) var currentPage: Int = 0
    private(set) var hasNextPage: Bool = true
    private(set) var isLoading: Bool = false
    
    init(rmService: RMServicing, modelContext: ModelContext) {
        self.rmService = rmService
        self.context = modelContext
    }
    
    func reset() {
        currentPage = 0
        hasNextPage = true
        isLoading = false
    }
    
    func loadNextPageIfNeeded() async {
        guard !isLoading, hasNextPage else { 
            return 
        }
        isLoading = true
        defer { isLoading = false }
        
        let next = currentPage + 1
        
        try? await Task.sleep(for: .milliseconds(1000))
        
        do {
            let response = try await rmService.pagedEpisodes(page: next)
            try upsert(episodes: response.episodes)
            currentPage = next
            hasNextPage = response.hasNext
        } catch {
        }
    }
    
    /// Performs upsert operations on episode data to prevent duplicates.
    ///
    /// This method handles the complex logic of:
    /// - Checking for existing episodes by ID
    /// - Extracting character IDs from episode character URLs
    /// - Parsing air dates using the custom `AirDateFormatter`
    /// - Updating existing episodes or creating new ones as needed
    ///
    /// - Parameter episodes: An array of episode models from the API to upsert
    /// - Throws: Any error that occurs during the database operations
    private func upsert(episodes: [RMEpisodeModel]) throws {
        for ep in episodes {
            let id = ep.id
            var fd = FetchDescriptor<EpisodeEntity>(
                predicate: #Predicate<EpisodeEntity> { $0.id == id }
            )
            fd.fetchLimit = 1
            let existing = try context.fetch(fd).first
            let characterIDs = ep.characters.compactMap { IDParsing.intID(from: $0) }
            let air = AirDateFormatter.parse(ep.airDate)
            if let e = existing {
                e.name = ep.name
                e.airDate = air
                e.code = ep.episode
                e.characterIDs = characterIDs
                e.updatedAt = Date.now
            } else {
                let e = EpisodeEntity(id: id, name: ep.name, airDate: air, code: ep.episode, characterIDs: characterIDs)
                context.insert(e)
            }
        }
        try context.save()
    }
}
