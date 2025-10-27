import Foundation
import UIKit

class SessionManager {

    static let shared = SessionManager()

    private let sessionStorage = SessionStorage.shared
    private let photoStorage = PhotoStorage.shared

    private init() {}

    func createNewSession() -> PhotoSession {
        return PhotoSession()
    }

    func addPhotoToSession(_ photo: Photo, session: PhotoSession) -> PhotoSession {
        var updatedPhotos = session.photos
        updatedPhotos.append(photo)

        return PhotoSession(
            id: session.id,
            photos: updatedPhotos,
            timestamp: session.timestamp,
            isComplete: false
        )
    }

    func completeSession(_ session: PhotoSession) throws -> PhotoSession {
        let completedSession = PhotoSession(
            id: session.id,
            photos: session.photos,
            timestamp: session.timestamp,
            isComplete: true
        )

        try sessionStorage.saveSession(completedSession)
        return completedSession
    }

    func deleteSession(_ session: PhotoSession) throws {
        for photo in session.photos {
            try? photoStorage.deletePhoto(id: photo.id)
        }

        try sessionStorage.deleteSession(id: session.id)
    }

    func getAllSessions() -> [PhotoSession] {
        return sessionStorage.loadSessions()
    }

    func getCompletedSessions() -> [PhotoSession] {
        return sessionStorage.loadSessions().filter { $0.isComplete }
    }

    func getIncompleteSessions() -> [PhotoSession] {
        return sessionStorage.loadSessions().filter { !$0.isComplete }
    }

    func saveSession(_ session: PhotoSession) throws {
        try sessionStorage.saveSession(session)
    }

    func getSessionById(_ id: UUID) -> PhotoSession? {
        return sessionStorage.loadSessions().first { $0.id == id }
    }

    func getSessionPhotos(_ session: PhotoSession) -> [UIImage] {
        return session.photos.compactMap { photo in
            photoStorage.loadPhoto(id: photo.id)
        }
    }

    func exportSession(_ session: PhotoSession, to layout: LayoutTemplate) -> UIImage? {
        let photos = getSessionPhotos(session)
        guard !photos.isEmpty else { return nil }

        return PhotoStripComposer.shared.createPhotoStrip(from: photos, layout: layout)
    }

    // MARK: - PhotoBooth Session Management

    func createPhotoBoothSession() -> PhotoSession {
        let session = PhotoSession()
        return session
    }

    func addPhotoToPhotoBoothSession(_ image: UIImage, session: PhotoSession) throws -> PhotoSession {
        let photo = Photo()

        // Save the photo to storage
        _ = try photoStorage.savePhoto(image, id: photo.id)

        // Add to session
        return addPhotoToSession(photo, session: session)
    }

    func completePhotoBoothSession(_ session: PhotoSession) throws -> PhotoSession {
        let completedSession = PhotoSession(
            id: session.id,
            photos: session.photos,
            timestamp: session.timestamp,
            isComplete: true
        )

        try sessionStorage.saveSession(completedSession)
        return completedSession
    }

    func getPhotoBoothSessionProgress(_ session: PhotoSession, targetCount: Int = 4) -> (current: Int, target: Int, isComplete: Bool) {
        let current = session.photos.count
        return (current: current, target: targetCount, isComplete: current >= targetCount)
    }

    func generatePhotoStrip(for session: PhotoSession, layout: LayoutTemplate? = nil) -> UIImage? {
        // Always use photo strip layout - simplified
        let photoStripLayout = LayoutTemplate(name: "Photo Strip", description: "3 photos + text strip", photoCount: 3, aspectRatio: CGSize(width: 2, height: 6))
        return exportSession(session, to: photoStripLayout)
    }

    func cleanupIncompleteSessions(olderThan timeInterval: TimeInterval = 3600) {
        let cutoffDate = Date().addingTimeInterval(-timeInterval)
        let incompleteSessions = getIncompleteSessions()

        for session in incompleteSessions {
            if session.timestamp < cutoffDate {
                try? deleteSession(session)
            }
        }
    }

    func getSessionStats() -> (totalSessions: Int, totalPhotos: Int, completedSessions: Int) {
        let allSessions = getAllSessions()
        let completedSessions = allSessions.filter { $0.isComplete }
        let totalPhotos = allSessions.reduce(0) { $0 + $1.photos.count }

        return (
            totalSessions: allSessions.count,
            totalPhotos: totalPhotos,
            completedSessions: completedSessions.count
        )
    }
}