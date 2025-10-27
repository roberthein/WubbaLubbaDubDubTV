import Foundation
import SwiftData

@Model
final class EpisodeEntity {
    @Attribute(.unique) var id: Int
    var name: String
    var airDate: Date?
    var code: String
    var characterIDs: [Int]
    var updatedAt: Date

    init(id: Int, name: String, airDate: Date?, code: String, characterIDs: [Int], updatedAt: Date = .now) {
        self.id = id
        self.name = name
        self.airDate = airDate
        self.code = code
        self.characterIDs = characterIDs
        self.updatedAt = updatedAt
    }

    var cellId: String {
        "cell-\(mapToOneToFour(id))"
    }

    func mapToOneToFour(_ value: Int) -> Int {
        return ((value - 1) % 4 + 4) % 4 + 1
    }
}
