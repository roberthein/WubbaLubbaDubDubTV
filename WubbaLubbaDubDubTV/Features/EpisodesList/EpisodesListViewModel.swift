import Foundation
import Observation

@MainActor
@Observable
final class EpisodesListViewModel {
    private let repo: EpisodesRepository

    var errorMessage: String? = nil

    init(repo: EpisodesRepository) { self.repo = repo }

    var isLoading: Bool { repo.isLoading }
    var isAtEnd: Bool { !repo.hasNextPage && repo.currentPage > 0 }

    func loadNextPageIfNeeded() async {
        await repo.loadNextPageIfNeeded()
    }
    
    func loadAllEpisodes() async {
        await repo.loadPages([1, 2, 3])
    }
}
