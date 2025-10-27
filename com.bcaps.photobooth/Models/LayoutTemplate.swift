import Foundation
import UIKit

struct LayoutTemplate: Codable {
    let id: UUID
    let name: String
    let description: String
    let photoCount: Int
    let aspectRatio: CGSize

    init(id: UUID = UUID(), name: String, description: String, photoCount: Int, aspectRatio: CGSize) {
        self.id = id
        self.name = name
        self.description = description
        self.photoCount = photoCount
        self.aspectRatio = aspectRatio
    }

    static let defaultLayouts: [LayoutTemplate] = [
        LayoutTemplate(
            name: "Single Photo",
            description: "One large photo",
            photoCount: 1,
            aspectRatio: CGSize(width: 4, height: 6)
        ),
        LayoutTemplate(
            name: "Photo Strip",
            description: "3 photos + text strip",
            photoCount: 3,
            aspectRatio: CGSize(width: 2, height: 6)
        ),
        LayoutTemplate(
            name: "2x2 Grid",
            description: "Four photos in a grid",
            photoCount: 4,
            aspectRatio: CGSize(width: 4, height: 4)
        ),
        LayoutTemplate(
            name: "Collage",
            description: "Multiple photos collage",
            photoCount: 6,
            aspectRatio: CGSize(width: 6, height: 4)
        )
    ]
}