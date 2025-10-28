import Foundation

struct Photo: Codable {
    let id: UUID
    let timestamp: Date
    let filename: String
    let appliedFilter: FilterType?

    init(id: UUID = UUID(), timestamp: Date = Date(), appliedFilter: FilterType? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.filename = "\(id.uuidString).jpg"
        self.appliedFilter = appliedFilter
    }
}