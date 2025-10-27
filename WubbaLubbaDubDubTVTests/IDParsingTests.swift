import Foundation
import Testing
@testable import WubbaLubbaDubDubTV

@Test
func idParsing_extracts_last_path_component_as_int() {
    #expect(IDParsing.intID(from: "https://rickandmortyapi.com/api/character/361") == 361)
    #expect(IDParsing.intID(from: "https://rickandmortyapi.com/api/character/xyz") == nil)
}
