import Foundation
import SwiftData
import RickMortySwiftApi

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
