import Foundation

struct Photo: Codable {
    let id: UUID
    let timestamp: Date
    let filename: String

    init(id: UUID = UUID(), timestamp: Date = Date()) {
        self.id = id
        self.timestamp = timestamp
        self.filename = "\(id.uuidString).jpg"
    }
}