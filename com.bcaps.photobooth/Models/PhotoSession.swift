import Foundation

struct PhotoSession: Codable {
    let id: UUID
    let photos: [Photo]
    let timestamp: Date
    let isComplete: Bool

    init(id: UUID = UUID(), photos: [Photo] = [], timestamp: Date = Date(), isComplete: Bool = false) {
        self.id = id
        self.photos = photos
        self.timestamp = timestamp
        self.isComplete = isComplete
    }
}