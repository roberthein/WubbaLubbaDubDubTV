import Foundation
import RickMortySwiftApi

final class MockRMService: RMServicing {
    func pagedEpisodes(page: Int) async throws -> (episodes: [RMEpisodeModel], hasNext: Bool) {
        let pageSize = 20
        let total = 51
        let start = (page - 1) * pageSize + 1
        guard start <= total else { return ([], false) }
        let end = min(page * pageSize, total)
        let eps = try decodeEpisodes(ids: Array(start...end))
        let hasNext = end < total
        return (eps, hasNext)
    }

    func episode(id: Int) async throws -> RMEpisodeModel {
        try decodeEpisodes(ids: [id]).first!
    }

    func characters(ids: [Int]) async throws -> [RMCharacterModel] {
        try decodeCharacters(ids: ids)
    }

    func character(id: Int) async throws -> RMCharacterModel {
        try decodeCharacters(ids: [id]).first!
    }
    
    func pagedCharacters(page: Int) async throws -> (characters: [RMCharacterModel], hasNext: Bool) {
        let pageSize = 20
        let total = 826
        let start = (page - 1) * pageSize + 1
        guard start <= total else { return ([], false) }
        let end = min(page * pageSize, total)
        let chars = try decodeCharacters(ids: Array(start...end))
        let hasNext = end < total
        return (chars, hasNext)
    }


    private func decodeEpisodes(ids: [Int]) throws -> [RMEpisodeModel] {
        let items = ids.map { id in
            """
            {
              "id": \(id),
              "name": "Episode \(id)",
              "air_date": "April 7, 2014",
              "episode": "S01E\(String(format: "%02d", id))",
              "characters": ["https://rickandmortyapi.com/api/character/1","https://rickandmortyapi.com/api/character/2"],
              "url": "https://rickandmortyapi.com/api/episode/\(id)",
              "created": "2017-11-10T12:56:34.747Z"
            }
            """
        }.joined(separator: ",")
        let json = "[\(items)]".data(using: .utf8)!
        return try JSONDecoder().decode([RMEpisodeModel].self, from: json)
    }

    private func decodeCharacters(ids: [Int]) throws -> [RMCharacterModel] {
        let items = ids.map { id in
            """
            {
              "id": \(id),
              "name": "Character \(id)",
              "status": "Alive",
              "species": "Human",
              "type": "",
              "gender": "Male",
              "origin": { "name": "Earth", "url": "https://rickandmortyapi.com/api/location/1" },
              "location": { "name": "Earth", "url": "https://rickandmortyapi.com/api/location/20" },
              "image": "https://rickandmortyapi.com/api/character/avatar/\(id).jpeg",
              "episode": ["https://rickandmortyapi.com/api/episode/1","https://rickandmortyapi.com/api/episode/2"],
              "url": "https://rickandmortyapi.com/api/character/\(id)",
              "created": "2018-01-10T18:20:41.703Z"
            }
            """
        }.joined(separator: ",")
        let json = "[\(items)]".data(using: .utf8)!
        return try JSONDecoder().decode([RMCharacterModel].self, from: json)
    }
}
