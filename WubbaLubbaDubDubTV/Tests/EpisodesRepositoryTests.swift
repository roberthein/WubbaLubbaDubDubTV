//import Foundation
//import SwiftData
//import Testing
//@testable import WubbaLubbaDubDubTV
//
//@MainActor
//@Test
//func episodes_pagination_loads_all_and_sets_end_flag() async throws {
//    let schema = Schema([EpisodeEntity.self, CharacterEntity.self])
//    let mc = try ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
//    let mock = MockRMService()
//    let repo = EpisodesRepository(rmService: mock, modelContext: mc.mainContext)
//
//    await repo.loadNextPageIfNeeded()
//    #expect(repo.currentPage == 1)
//    #expect(repo.hasNextPage == true)
//
//    await repo.loadNextPageIfNeeded()
//    #expect(repo.currentPage == 2)
//    #expect(repo.hasNextPage == true)
//
//    await repo.loadNextPageIfNeeded()
//    #expect(repo.currentPage == 3)
//    #expect(repo.hasNextPage == false)
//
//    let all = try mc.mainContext.fetch(FetchDescriptor<EpisodeEntity>())
//    #expect(all.count == 51)
//}
