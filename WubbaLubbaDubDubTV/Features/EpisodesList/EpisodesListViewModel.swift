import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class EpisodesListViewModel {
    private let repo: EpisodesRepository
    private let context: ModelContext

    var errorMessage: String? = nil
    var episodes: [EpisodeEntity] = []
    var isLoading: Bool = false
    var isAtEnd: Bool = false

    init(repo: EpisodesRepository, context: ModelContext) { 
        self.repo = repo
        self.context = context
        loadEpisodesFromContext()
    }
    
    private func loadEpisodesFromContext() {
        do {
            let descriptor = FetchDescriptor<EpisodeEntity>(
                sortBy: [SortDescriptor(\EpisodeEntity.id, order: .forward)]
            )
            episodes = try context.fetch(descriptor)
        } catch {
            errorMessage = "Failed to load episodes: \(error.localizedDescription)"
        }
    }

    func loadNextPageIfNeeded() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        await repo.loadNextPageIfNeeded()
        loadEpisodesFromContext()
        isAtEnd = !repo.hasNextPage && repo.currentPage > 0
    }
    
    func loadAllEpisodes() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        await repo.loadPages([1, 2, 3])
        loadEpisodesFromContext()
        isAtEnd = !repo.hasNextPage && repo.currentPage > 0
    }
    
    func refreshData() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let eps = try context.fetch(FetchDescriptor<EpisodeEntity>())
            for e in eps { context.delete(e) }
            let chars = try context.fetch(FetchDescriptor<CharacterEntity>())
            for c in chars { context.delete(c) }
            try context.save()
        } catch {
            errorMessage = "Failed to clear data: \(error.localizedDescription)"
        }
        
        repo.reset()
        episodes = []
        isAtEnd = false
        
        await loadNextPageIfNeeded()
    }
}
