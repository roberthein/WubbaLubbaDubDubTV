import Foundation

enum AirDateFormatter {
    static let input: DateFormatter = {
        let df = DateFormatter()
        df.locale = .init(identifier: "en_US_POSIX")
        df.dateFormat = "MMMM d, yyyy"
        return df
    }()

    static let output: DateFormatter = {
        let df = DateFormatter()
        df.locale = .init(identifier: "en_US_POSIX")
        df.dateFormat = "dd/MM/yyyy"
        return df
    }()

    static func parse(_ string: String) -> Date? { input.date(from: string) }
    static func format(_ date: Date?) -> String {
        guard let date else { return "—" }
        return output.string(from: date)
    }
}
