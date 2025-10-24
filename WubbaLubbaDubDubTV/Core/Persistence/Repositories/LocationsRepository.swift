// WubbaLubbaDubDubTV/Core/Persistence/Repositories/LocationsRepository.swift
import Foundation
import SwiftData
import RickMortySwiftApi

@MainActor
final class LocationsRepository {
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
        guard !isLoading, hasNextPage else { return }
        isLoading = true
        defer { isLoading = false }
        
        try? await Task.sleep(for: .milliseconds(500))
        
        let next = currentPage + 1
        do {
            let response = try await rmService.pagedLocations(page: next)
            try upsert(locations: response.locations)
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
    
    func location(id: Int) async throws -> LocationEntity {
        if let cached = try fetchEntity(id: id) {
            return cached
        }
        let model = try await rmService.location(id: id)
        let entity = try upsert(location: model)
        return entity
    }
    
    private func fetchEntity(id: Int) throws -> LocationEntity? {
        var fd = FetchDescriptor<LocationEntity>(predicate: #Predicate<LocationEntity> { $0.id == id })
        fd.fetchLimit = 1
        return try context.fetch(fd).first
    }
    
    @discardableResult
    private func upsert(location: RMLocationModel) throws -> LocationEntity {
        let id = location.id
        let existing = try fetchEntity(id: id)
        let residentIDs = location.residents.compactMap { IDParsing.intID(from: $0) }
        
        let e: LocationEntity
        if let ex = existing {
            e = ex
            e.name = location.name
            e.type = location.type
            e.dimension = location.dimension
            e.residentIDs = residentIDs
            e.updatedAt = Date.now
        } else {
            e = LocationEntity(
                id: id,
                name: location.name,
                type: location.type,
                dimension: location.dimension,
                residentIDs: residentIDs
            )
            context.insert(e)
        }
        
        try context.save()
        return e
    }
    
    private func upsert(locations: [RMLocationModel]) throws {
        for loc in locations {
            _ = try upsert(location: loc)
        }
    }
}

