import Foundation
import SwiftData
import Testing
@testable import WubbaLubbaDubDubTV

@MainActor
@Test
func character_details_upsert_and_episodeCount() async throws {
    let schema = Schema([EpisodeEntity.self, CharacterEntity.self])
    let mc = try ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let mock = MockRMService()
    let repo = CharactersRepository(rmService: mock, modelContext: mc.mainContext)

    let c = try await repo.character(id: 1)
    #expect(c.id == 1)
    #expect(c.name == "Character 1")
    #expect(c.episodeCount == 2)
    #expect(c.originName == "Earth")

    let c2 = try await repo.character(id: 1)
    #expect(c2.persistentModelID == c.persistentModelID)
}
