import Foundation
import UIKit

class ReviewViewModel: ObservableObject {

    private let photoStorage = PhotoStorage.shared
    private let sessionManager = SessionManager.shared

    @Published var photos: [Photo] = []
    @Published var images: [UIImage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadPhotos(_ photos: [Photo]) {
        self.photos = photos
        loadImages()
    }

    private func loadImages() {
        isLoading = true
        var loadedImages: [UIImage] = []

        for photo in photos {
            if let image = photoStorage.loadPhoto(id: photo.id) {
                loadedImages.append(image)
            }
        }

        DispatchQueue.main.async { [weak self] in
            self?.images = loadedImages
            self?.isLoading = false
        }
    }

    func sharePhotos(completion: @escaping (UIActivityViewController?) -> Void) {
        guard !images.isEmpty else {
            errorMessage = "No photos to share"
            completion(nil)
            return
        }

        let activityController = UIActivityViewController(
            activityItems: images,
            applicationActivities: nil
        )
        completion(activityController)
    }

    func savePhotosToLibrary(completion: @escaping (Bool, String?) -> Void) {
        guard !images.isEmpty else {
            completion(false, "No photos to save")
            return
        }

        let savedCount = images.count

        for image in images {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }

        completion(true, "Saved \(savedCount) photos to your photo library")
    }

    func deleteSession(completion: @escaping (Bool, Error?) -> Void) {
        for photo in photos {
            do {
                try photoStorage.deletePhoto(id: photo.id)
            } catch {
                completion(false, error)
                return
            }
        }

        completion(true, nil)
    }

    var photoCount: Int {
        return photos.count
    }

    var hasPhotos: Bool {
        return !photos.isEmpty
    }
}