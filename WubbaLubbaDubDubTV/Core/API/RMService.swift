import Foundation
import RickMortySwiftApi

/// A protocol defining the interface for Rick and Morty API operations.
///
/// This protocol abstracts the API service layer, enabling easy testing and mocking.
/// All methods are designed to work with async/await and are marked as `Sendable`
/// for safe concurrent usage.
public protocol RMServicing: Sendable {
    func pagedEpisodes(page: Int) async throws -> (episodes: [RMEpisodeModel], hasNext: Bool)
    func episode(id: Int) async throws -> RMEpisodeModel
    func pagedCharacters(page: Int) async throws -> (characters: [RMCharacterModel], hasNext: Bool)
    func characters(ids: [Int]) async throws -> [RMCharacterModel]
    func character(id: Int) async throws -> RMCharacterModel
}

public final class RMService: RMServicing {
    private let client = RMClient()
    private let pageSize = 20

    public init() {}

    public func pagedEpisodes(page: Int) async throws -> (episodes: [RMEpisodeModel], hasNext: Bool) {
        let models: [RMEpisodeModel] = try await client.episode().getEpisodesByPageNumber(pageNumber: page)
        let hasNext = models.count >= pageSize
        return (models, hasNext)
    }

    public func episode(id: Int) async throws -> RMEpisodeModel {
        try await client.episode().getEpisodeByID(id: id)
    }

    /// Fetches multiple characters concurrently using TaskGroup for optimal performance.
    ///
    /// This method demonstrates advanced Swift concurrency patterns by:
    /// - Using `withThrowingTaskGroup` to fetch characters in parallel
    /// - Preserving the original order of character IDs in the result
    /// - Handling potential failures gracefully with proper error propagation
    ///
    /// - Parameter ids: An array of character IDs to fetch.
    /// - Returns: An array of character models in the same order as the input IDs.
    /// - Throws: Any error that occurs during the API calls.
    public func characters(ids: [Int]) async throws -> [RMCharacterModel] {
        guard !ids.isEmpty else { return [] }
        return try await withThrowingTaskGroup(of: (Int, RMCharacterModel).self) { group in
            for id in ids {
                group.addTask { [client] in
                    let model = try await client.character().getCharacterByID(id: id)
                    return (id, model)
                }
            }
            var byID: [Int: RMCharacterModel] = [:]
            byID.reserveCapacity(ids.count)
            for try await (id, model) in group { byID[id] = model }
            return ids.compactMap { byID[$0] }
        }
    }

    public func character(id: Int) async throws -> RMCharacterModel {
        try await client.character().getCharacterByID(id: id)
    }
    
    public func pagedCharacters(page: Int) async throws -> (characters: [RMCharacterModel], hasNext: Bool) {
        let models: [RMCharacterModel] = try await client.character().getCharactersByPageNumber(pageNumber: page)
        let hasNext = models.count >= pageSize
        return (models, hasNext)
    }
}
