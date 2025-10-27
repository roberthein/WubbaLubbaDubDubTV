import Foundation

enum IDParsing {
    static func intID(from urlString: String) -> Int? {
        guard let url = URL(string: urlString) else { return nil }
        return Int(url.lastPathComponent)
    }
}
