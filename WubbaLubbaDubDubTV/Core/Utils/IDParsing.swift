import Foundation

/// A utility enum for parsing character IDs from Rick and Morty API URLs.
///
/// The Rick and Morty API returns character references as full URLs like:
/// `https://rickandmortyapi.com/api/character/1`
///
/// This utility extracts the numeric ID from these URLs for use in database
/// operations and API calls.
enum IDParsing {
    /// Extracts a numeric ID from a Rick and Morty API URL.
    ///
    /// - Parameter urlString: The URL string containing the character ID
    /// - Returns: The extracted integer ID, or `nil` if the URL is invalid
    static func intID(from urlString: String) -> Int? {
        guard let url = URL(string: urlString) else { return nil }
        return Int(url.lastPathComponent)
    }
}
