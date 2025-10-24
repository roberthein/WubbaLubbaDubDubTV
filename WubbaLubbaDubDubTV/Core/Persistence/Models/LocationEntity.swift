// WubbaLubbaDubDubTV/Core/Persistence/Models/LocationEntity.swift
import Foundation
import SwiftData

@Model
final class LocationEntity {
    @Attribute(.unique) var id: Int
    var name: String
    var type: String
    var dimension: String
    var residentIDs: [Int]
    var updatedAt: Date

    init(id: Int,
         name: String,
         type: String,
         dimension: String,
         residentIDs: [Int],
         updatedAt: Date = .now) {
        self.id = id
        self.name = name
        self.type = type
        self.dimension = dimension
        self.residentIDs = residentIDs
        self.updatedAt = updatedAt
    }
}

