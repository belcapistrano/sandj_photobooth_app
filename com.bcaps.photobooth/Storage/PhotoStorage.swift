import Foundation
import UIKit

class PhotoStorage {
    static let shared = PhotoStorage()

    private let documentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentsURL = urls.first else {
            fatalError("Could not find documents directory")
        }
        return documentsURL
    }()

    private init() {}

    func savePhoto(_ image: UIImage, id: UUID) throws -> URL {
        let filename = "\(id.uuidString).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(filename)

        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.compressionFailed
        }

        try data.write(to: fileURL)
        return fileURL
    }

    func loadPhoto(id: UUID) -> UIImage? {
        let filename = "\(id.uuidString).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(filename)

        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        return UIImage(data: data)
    }

    func deletePhoto(id: UUID) throws {
        let filename = "\(id.uuidString).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        try FileManager.default.removeItem(at: fileURL)
    }

    func getAllPhotoURLs() -> [URL] {
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: documentsDirectory,
                includingPropertiesForKeys: nil
            )
            return contents.filter { $0.pathExtension == "jpg" }
        } catch {
            return []
        }
    }
}