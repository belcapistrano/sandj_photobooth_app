import Foundation
import UIKit

class CameraViewModel: ObservableObject {

    private let cameraManager = CameraManager.shared
    private let sessionManager = SessionManager.shared
    private let photoStorage = PhotoStorage.shared

    @Published var isFlashEnabled = false
    @Published var isGridEnabled = false
    @Published var capturedPhotos: [Photo] = []
    @Published var currentSession: PhotoSession?
    @Published var errorMessage: String?

    init() {
        loadSettings()
        startNewSession()
    }

    func startNewSession() {
        currentSession = PhotoSession()
        capturedPhotos.removeAll()
    }

    func capturePhoto(completion: @escaping (Result<UIImage, Error>) -> Void) {
        cameraManager.capturePhoto { [weak self] result in
            switch result {
            case .success(let image):
                self?.handleCapturedPhoto(image, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func handleCapturedPhoto(_ image: UIImage, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let photo = Photo()

        do {
            _ = try photoStorage.savePhoto(image, id: photo.id)
            capturedPhotos.append(photo)

            if var session = currentSession {
                session = PhotoSession(
                    id: session.id,
                    photos: capturedPhotos,
                    timestamp: session.timestamp,
                    isComplete: false
                )
                currentSession = session
                try SessionStorage.shared.saveSession(session)
            }

            completion(.success(image))

        } catch {
            errorMessage = error.localizedDescription
            completion(.failure(error))
        }
    }

    func finishSession() throws {
        guard var session = currentSession else {
            throw StorageError.invalidData
        }

        session = PhotoSession(
            id: session.id,
            photos: capturedPhotos,
            timestamp: session.timestamp,
            isComplete: true
        )

        try SessionStorage.shared.saveSession(session)
        startNewSession()
    }

    func deleteCurrentSession() throws {
        guard let session = currentSession else { return }

        for photo in capturedPhotos {
            try? photoStorage.deletePhoto(id: photo.id)
        }

        try SessionStorage.shared.deleteSession(id: session.id)
        startNewSession()
    }

    func toggleFlash() {
        isFlashEnabled.toggle()
        cameraManager.setFlashMode(isFlashEnabled)
        saveSettings()
    }

    func toggleGrid() {
        isGridEnabled.toggle()
        saveSettings()
    }

    func switchCamera() {
        cameraManager.switchCamera()
    }

    private func loadSettings() {
        let settings = SettingsStorage.shared
        isFlashEnabled = settings.getBool(for: .flashEnabled, default: false)
        isGridEnabled = settings.getBool(for: .gridEnabled, default: false)
    }

    private func saveSettings() {
        let settings = SettingsStorage.shared
        settings.set(isFlashEnabled, for: .flashEnabled)
        settings.set(isGridEnabled, for: .gridEnabled)
    }

    var photoCount: Int {
        return capturedPhotos.count
    }

    var canReview: Bool {
        return !capturedPhotos.isEmpty
    }

    var sessionTitle: String {
        return photoCount > 0 ? "Photo \(photoCount + 1)" : "Photo Booth"
    }
}