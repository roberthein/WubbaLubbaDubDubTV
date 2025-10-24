// WubbaLubbaDubDubTV/Core/API/RMService.swift
import Foundation
import RickMortySwiftApi

public protocol RMServicing: Sendable {
    func pagedEpisodes(page: Int) async throws -> (episodes: [RMEpisodeModel], hasNext: Bool)
    func episode(id: Int) async throws -> RMEpisodeModel
    func pagedCharacters(page: Int) async throws -> (characters: [RMCharacterModel], hasNext: Bool)
    func characters(ids: [Int]) async throws -> [RMCharacterModel]
    func character(id: Int) async throws -> RMCharacterModel
    func pagedLocations(page: Int) async throws -> (locations: [RMLocationModel], hasNext: Bool)
    func location(id: Int) async throws -> RMLocationModel
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
    
    public func pagedLocations(page: Int) async throws -> (locations: [RMLocationModel], hasNext: Bool) {
        let models: [RMLocationModel] = try await client.location().getLocationsByPageNumber(pageNumber: page)
        let hasNext = models.count >= pageSize
        return (models, hasNext)
    }
    
    public func location(id: Int) async throws -> RMLocationModel {
        try await client.location().getLocationByID(id: id)
    }
}
