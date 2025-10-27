import Foundation
import RickMortySwiftApi

@MainActor
final class APIInfoChecker {
    private let client = RMClient()
    
    func checkTotalEpisodes() async throws -> Int {
        var totalCount = 0
        var page = 1
        var hasMore = true
        
        while hasMore {
            let episodes = try await client.episode().getEpisodesByPageNumber(pageNumber: page)
            let count = episodes.count
            totalCount += count
            
            hasMore = count >= 20
            page += 1
            
            if page > 10 {
                break
            }
        }
        
        return totalCount
    }
}

