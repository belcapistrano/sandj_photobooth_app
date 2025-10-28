import Foundation

struct PhotoSession: Codable {
    let id: UUID
    let photos: [Photo]
    let timestamp: Date
    let isComplete: Bool
    let selectedFilter: FilterType
    let isWeddingTheme: Bool

    init(
        id: UUID = UUID(),
        photos: [Photo] = [],
        timestamp: Date = Date(),
        isComplete: Bool = false,
        selectedFilter: FilterType = .original,
        isWeddingTheme: Bool = true
    ) {
        self.id = id
        self.photos = photos
        self.timestamp = timestamp
        self.isComplete = isComplete
        self.selectedFilter = selectedFilter
        self.isWeddingTheme = isWeddingTheme
    }
}