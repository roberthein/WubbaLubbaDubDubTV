// WubbaLubbaDubDubTV/Core/Persistence/Repositories/CharactersRepository.swift
import Foundation
import SwiftData
import RickMortySwiftApi

@MainActor
final class CharactersRepository {
    private let rmService: RMServicing
    private let context: ModelContext
    private let cache = FetchCache<Int, CharacterEntity>()
    
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

    func prefetchCharacters(for episodeID: Int) async {
        var fd = FetchDescriptor<EpisodeEntity>(predicate: #Predicate<EpisodeEntity> { $0.id == episodeID })
        fd.fetchLimit = 1
        guard let episode = try? context.fetch(fd).first else { return }
        let ids = episode.characterIDs
        guard !ids.isEmpty else { return }
        do {
            let models = try await rmService.characters(ids: ids)
            try upsert(characters: models)
        } catch {
        }
    }

    func character(id: Int) async throws -> CharacterEntity {
        if let cached = try fetchEntity(id: id) {
            return cached
        }
        let model = try await rmService.character(id: id)
        let entity = try upsert(character: model)
        return entity
    }
    
    func loadNextPageIfNeeded() async {
        guard !isLoading, hasNextPage else { return }
        isLoading = true
        defer { isLoading = false }
        
        try? await Task.sleep(for: .milliseconds(500))
        
        let next = currentPage + 1
        do {
            let response = try await rmService.pagedCharacters(page: next)
            try upsert(characters: response.characters)
            currentPage = next
            hasNextPage = response.hasNext
        } catch {
        }
    }
    
    func loadAllPages() async {
        while hasNextPage {
            await loadNextPageIfNeeded()
        }
    }

    private func fetchEntity(id: Int) throws -> CharacterEntity? {
        var fd = FetchDescriptor<CharacterEntity>(predicate: #Predicate<CharacterEntity> { $0.id == id })
        fd.fetchLimit = 1
        return try context.fetch(fd).first
    }

    @discardableResult
    private func upsert(character: RMCharacterModel) throws -> CharacterEntity {
        let id = character.id
        let existing = try fetchEntity(id: id)
        let e: CharacterEntity
        if let ex = existing {
            e = ex
        } else {
            e = CharacterEntity(
                id: id,
                name: "",
                status: "",
                species: "",
                originName: "",
                imageURL: nil,
                episodeCount: 0
            )
            context.insert(e)
        }

        e.name = character.name
        e.status = character.status
        e.species = character.species
        e.originName = character.origin.name
        e.imageURL = URL(string: character.image)
        e.episodeCount = character.episode.count
        e.updatedAt = Date.now
        try context.save()
        return e
    }

    private func upsert(characters: [RMCharacterModel]) throws {
        for c in characters { _ = try upsert(character: c) }
    }
}
