import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class EpisodeDetailViewModel {
    private let charactersRepo: CharactersRepository
    let episodeID: Int
    
    var episode: EpisodeEntity?
    var isPrefetching = false
    
    init(episodeID: Int, charactersRepo: CharactersRepository, context: ModelContext) {
        self.episodeID = episodeID
        self.charactersRepo = charactersRepo
        var fd = FetchDescriptor<EpisodeEntity>(
            predicate: #Predicate<EpisodeEntity> { $0.id == episodeID }
        )
        fd.fetchLimit = 1
        self.episode = try? context.fetch(fd).first
    }
    
    func prefetch() async {
        guard !isPrefetching else { return }
        isPrefetching = true
        defer { isPrefetching = false }
        await charactersRepo.prefetchCharacters(for: episodeID)
    }
}
