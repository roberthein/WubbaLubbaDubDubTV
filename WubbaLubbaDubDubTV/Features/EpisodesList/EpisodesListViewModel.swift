import Foundation
import Observation
import SwiftData

/// A view model that manages the episodes list state and data operations.
///
/// This view model handles:
/// - Paginated episode loading with infinite scroll support
/// - Local data persistence using SwiftData
/// - Loading states and error handling
/// - Data refresh operations that clear and reload all episodes
///
/// The view model follows the MVVM pattern and uses `@Observable` for
/// reactive UI updates when the underlying data changes.
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
    
    /// Refreshes all episode data by clearing the local cache and reloading from the API.
    ///
    /// This method performs a complete data refresh by:
    /// 1. Clearing all existing episodes and characters from SwiftData
    /// 2. Resetting the repository's pagination state
    /// 3. Loading the first page of episodes from the API
    ///
    /// This is typically called when the user performs a pull-to-refresh gesture.
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
