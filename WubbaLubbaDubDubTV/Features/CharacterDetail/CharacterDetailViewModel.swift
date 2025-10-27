import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class CharacterDetailViewModel {
    private let repo: CharactersRepository
    let id: Int

    var character: CharacterEntity? = nil
    var isLoading = false
    var error: String? = nil

    init(id: Int, repo: CharactersRepository) {
        self.id = id
        self.repo = repo
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            character = try await repo.character(id: id)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
