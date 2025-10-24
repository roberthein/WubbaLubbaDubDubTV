// WubbaLubbaDubDubTV/Core/Persistence/Models/EpisodeEntity.swift
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
}
