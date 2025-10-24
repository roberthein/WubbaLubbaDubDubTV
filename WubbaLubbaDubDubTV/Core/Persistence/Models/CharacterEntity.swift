// WubbaLubbaDubDubTV/Core/Persistence/Models/CharacterEntity.swift
import Foundation
import SwiftData

@Model
final class CharacterEntity {
    @Attribute(.unique) var id: Int
    var name: String
    var status: String
    var species: String
    var originName: String
    var imageURL: URL?
    var episodeCount: Int
    var updatedAt: Date

    init(id: Int,
         name: String,
         status: String,
         species: String,
         originName: String,
         imageURL: URL?,
         episodeCount: Int,
         updatedAt: Date = .now) {
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.originName = originName
        self.imageURL = imageURL
        self.episodeCount = episodeCount
        self.updatedAt = updatedAt
    }
}
